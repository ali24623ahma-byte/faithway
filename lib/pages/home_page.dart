import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'login_page.dart';
import '../services/notification_service.dart';
import 'search.dart';
import 'qibla_page.dart';
import 'profile_page.dart';
import 'prayer_time_box.dart';
import 'special_prayer_page.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/menu_box.dart';
import 'tasbeeh_page.dart';
import 'name_of_allah.dart';
import 'name_of_muhammad.dart';
import 'ayat_ul_kursi.dart';
import 'rakat_page.dart';
import 'prayer_timing_page.dart';
import 'duas_page.dart';
import 'hadith_page.dart';
import 'namaz_record_page.dart';
import '../screens/surah_list_page.dart';
import 'kalmas_page.dart';
import '../services/prayer_service.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _notificationsInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🔔 TEST: Run Feature Reminders IMMEDIATELY (No location needed)
      debugPrint("🚀 FORCING Feature Reminders Schedule NOW...");
      NotificationService.scheduleFeatureReminders();
      
      _checkLocationAndInit();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationAndInit();
    }
  }

  Future<void> _checkLocationAndInit() async {
    // If already successfully initialized, don't run again unless needed
    // if (_notificationsInitialized) return; 

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (mounted) _showLocationDialog();
    } else {
      // 🚀 Service enabled, Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return;
      }

      // ✅ Location available, Initialize PRAYER Notifications
      await _initPrayerNotifications();
    }
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/location_icon.png', height: 150),
            const SizedBox(height: 20),
            const Text(
              "Location Service Disabled",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
               "Please enable your location to get accurate prayer times.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await Geolocator.openLocationSettings();
                },
                child: const Text(
                  "Enable Location",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initPrayerNotifications() async {
    debugPrint("🏠 HomePage: Initializing PRAYER Notifications...");
    // 🔥 Auto-schedule prayer notifications
    await PrayerService.refreshAndScheduleNotifications();
    
    setState(() {
      _notificationsInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return StreamBuilder<UserProfile?>(
      stream: UserService().getUserProfileStream(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final displayName = profile?.name ?? user['username'] ?? 'User';
        final displayEmail = profile?.email ?? user['email'] ?? '';
        final displayImage = profile?.profilePhotoUrl ?? user['image'] ?? '';

        return Scaffold(
          extendBodyBehindAppBar: true,

          /// 🔹 DRAWER
          drawer: Drawer(
            child: Column(
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Colors.yellow.shade700),
                  accountName: Text(displayName),
                  accountEmail: Text(displayEmail),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: displayImage.isNotEmpty
                        ? (displayImage.startsWith('assets/') 
                            ? AssetImage(displayImage) 
                            : NetworkImage(displayImage) as ImageProvider)
                        : null,
                    child: displayImage.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home, color: Colors.yellow.shade700),
                  title: const Text('Home'),
                  onTap: () => Navigator.pop(context),
                ),
                const Spacer(),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.yellow.shade700),
                  title: const Text('Logout'),
                  onTap: () async {
                    await NotificationService.logout();
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                ),
              ],
            ),
          ),

          /// 🔹 APP BAR
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.mosque, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'FaithWay',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.white), // 🔊 Sound Test
                  onPressed: () {
                    NotificationService.testAzanSound();
                  },
                ),
              ),
            ],
          ),

          /// 🔹 BODY
          body: Stack(
            children: [
              SizedBox(
                height: 360,
                width: double.infinity,
                child: Image.asset("assets/mosque_background.png", fit: BoxFit.cover),
              ),
              Container(color: Colors.black.withOpacity(0.3)),

              Positioned(
                left: 20,
                top: kToolbarHeight + 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome,',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(0, 2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

          Positioned(
            top: 240,
            left: 20,
            right: 20,
            child: PrayerTimeBox(boxColor: Colors.yellow.shade700),
          ),

          Positioned(
            top: 330,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  MenuBox(
                    iconPath: 'assets/icons/quran.png',
                    title: "Holy Quran",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SurahListPage()),
                      );
                    },
                  ),
                  MenuBox(
                    iconPath: 'assets/icons/hadith.png',
                    title: "Hadith",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => HadithPage()),
                      );
                    },
                  ),
                  MenuBox(
                    iconPath: 'assets/icons/dua.png',
                    title: "Duas",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DuasPage()),
                      );
                    },
                  ),
                  MenuBox(
                    iconPath: 'assets/icons/prayer_times.png',
                    title: "Prayer Times",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PrayerTimingPage()),
                      );
                    },
                  ),
                  MenuBox(
                    iconPath: 'assets/icons/qibla.png',
                    title: "Qibla Finder",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => QiblaPage()),
                      );
                    },
                  ),
                  MenuBox(
                    iconPath: 'assets/icons/tasbeeh.png',
                    title: "Tasbeeh",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TasbeehPage()),
                      );
                    },
                  ),
                  MenuBox(
                    iconPath: 'assets/icons/name_allah.png',
                    title: "Name of Allah",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NameOfAllah()),
                      );
                    },
                  ),
                  MenuBox(
                    iconPath: 'assets/icons/name_muhammad.png',
                    title: "Name of Muhammad",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NameOfMuhammad(),
                        ),
                      );
                    },
                  ),
                  MenuBox(
                    iconPath: 'assets/icons/namaz_record.png',
                    title: "Namaz Record",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NamazRecordPage()),
                      );
                    },
                  ),
                  MenuBox(
                    iconPath: 'assets/icons/special_prayer.png',
                    title: "Special Prayer",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SpecialPrayerPage()),
                      );
                    },
                  ),
                  MenuBox(
                    iconPath: 'assets/icons/ayal_kursi.png',
                    title: "Ayat al kursi",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AyatUlKursi()),
                      );
                    },
                  ),
                  MenuBox(
                    iconPath: 'assets/icons/prayer_rakats.png',
                    title: "Prayer Rakats",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RakatPage()),
                      );
                    },
                  ),
                  MenuBox(
                    iconPath: 'assets/icons/kalmas.png',
                    title: "Kalmas",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const KalmasPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      /// 🔹 BOTTOM NAV BAR
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Qibla"),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: "Prayers",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (index) {
          setState(() => _selectedIndex = index);

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => QiblaPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PrayerTimingPage()),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfilePage(
                  user: user,
                ),
              ),
            );
          }
        },
      ),
        );
      },
    );
  }
}

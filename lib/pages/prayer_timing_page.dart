import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/notification_service.dart';
import '../services/prayer_service.dart';

class PrayerTimingPage extends StatefulWidget {
  const PrayerTimingPage({super.key});

  @override
  State<PrayerTimingPage> createState() => _PrayerTimingPageState();
}

class _PrayerTimingPageState extends State<PrayerTimingPage> {
  Map<String, dynamic>? timings;
  Map<String, dynamic>? hijriData;
  bool loading = true;
  String errorMessage = "";
  String currentPrayer = "";
  String nextPrayer = "";
  String nextPrayerTime = "";

  @override
  void initState() {
    super.initState();
    getLocationAndTimings();
  }

  // 🔹 Clean API time
  String cleanTime(String time) {
    return time.split(" ").first;
  }

  Future<void> getLocationAndTimings() async {
    setState(() {
      loading = true;
      errorMessage = "";
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          errorMessage = "Location services are disabled";
          loading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          errorMessage = "Location permission denied";
          loading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final url =
          "https://api.aladhan.com/v1/timings?latitude=${position.latitude}&longitude=${position.longitude}&method=2";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        setState(() {
          errorMessage = "Failed to load prayer timings";
          loading = false;
        });
        return;
      }

      final data = json.decode(response.body);
      timings = data['data']['timings'];
      hijriData = data['data']['date']['hijri'];

      detectCurrentAndNextPrayer();
      
      // 🔥 Schedule notifications for the next 7 days
      if (!kIsWeb) {
        try {
          await PrayerService.refreshAndScheduleNotifications();
        } catch (e) {
          debugPrint("Failed to schedule notifications: $e");
        }
      }

      setState(() => loading = false);
    } catch (e) {
      setState(() {
        errorMessage = "Something went wrong: $e";
        loading = false;
      });
    }
  }

  // 🔹 Detect current & next prayer
  void detectCurrentAndNextPrayer() {
    final now = DateTime.now();
    final todayStr = DateFormat("yyyy-MM-dd").format(now);

    final List<Map<String, String>> prayerList = [
      {"name": "Fajr", "time": cleanTime(timings!['Fajr'])},
      {"name": "Sunrise", "time": cleanTime(timings!['Sunrise'])},
      {"name": "Dhuhr", "time": cleanTime(timings!['Dhuhr'])},
      {"name": "Asr", "time": cleanTime(timings!['Asr'])},
      {"name": "Maghrib", "time": cleanTime(timings!['Maghrib'])},
      {"name": "Isha", "time": cleanTime(timings!['Isha'])},
    ];

    bool found = false;
    for (int i = 0; i < prayerList.length; i++) {
      final prayerTime = DateTime.parse("$todayStr ${prayerList[i]['time']}:00");
      if (now.isBefore(prayerTime)) {
        nextPrayer = prayerList[i]['name']!;
        nextPrayerTime = prayerList[i]['time']!;
        currentPrayer = i == 0 ? "Tahajjud" : prayerList[i - 1]['name']!;
        found = true;
        break;
      }
    }

    if (!found) {
      currentPrayer = "Isha";
      nextPrayer = "Fajr";
      nextPrayerTime = cleanTime(timings!['Fajr']);
    }
  }

  // 🔹 Remove redundant local scheduling (Handled by PrayerService)

  // 🔥 TOP HEADER CARD (DYNAMIC)
  Widget topPrayerHeader() {
    final day = DateFormat("dd").format(DateTime.now());
    final date = DateFormat("dd MMM yyyy").format(DateTime.now());
    
    String hijriString = "Loading...";
    if (hijriData != null) {
      hijriString = "${hijriData!['day']} ${hijriData!['month']['en']} ${hijriData!['year']}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [Colors.yellow.shade700, Colors.orange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // LEFT DATE
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                day,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(hijriString, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              Text(
                date,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),

          const Spacer(),

          // RIGHT NEXT PRAYER
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Next prayer time",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 6),
              Text(
                nextPrayerTime,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                nextPrayer,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget prayerCard(String name, String time, IconData icon, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(22),
        border: isCurrent ? Border.all(color: Colors.yellow, width: 2) : null,
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.4),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: isCurrent ? Colors.yellow : Colors.grey.shade800,
            child: Icon(
              icon,
              color: isCurrent ? Colors.black : Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.yellow.shade700,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade700,
        title: const Text(
          "Prayer Timing",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.yellow),
            onPressed: () {
              NotificationService.showInstantNotification(
                  "Test Notification", 
                  "If you see this, notifications are working! 🔔"
              );
            },
          ),
          IconButton(
            onPressed: getLocationAndTimings,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/mosque_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.7),
          padding: const EdgeInsets.all(16),
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.yellow),
                )
              : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: getLocationAndTimings,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow.shade700),
                        child: const Text("Retry", style: TextStyle(color: Colors.black)),
                      )
                    ],
                  ),
                )
              : ListView(
                  children: [
                    topPrayerHeader(), 

                    prayerCard(
                      "Fajr",
                      cleanTime(timings!['Fajr']),
                      Icons.wb_twilight,
                      currentPrayer == "Fajr",
                    ),
                    prayerCard(
                      "Sunrise",
                      cleanTime(timings!['Sunrise']),
                      Icons.wb_sunny_outlined,
                      currentPrayer == "Sunrise",
                    ),
                    prayerCard(
                      "Dhuhr",
                      cleanTime(timings!['Dhuhr']),
                      Icons.wb_sunny,
                      currentPrayer == "Dhuhr",
                    ),
                    prayerCard(
                      "Asr",
                      cleanTime(timings!['Asr']),
                      Icons.sunny,
                      currentPrayer == "Asr",
                    ),
                    prayerCard(
                      "Maghrib",
                      cleanTime(timings!['Maghrib']),
                      Icons.nightlight_round,
                      currentPrayer == "Maghrib",
                    ),
                    prayerCard(
                      "Isha",
                      cleanTime(timings!['Isha']),
                      Icons.nights_stay,
                      currentPrayer == "Isha",
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}


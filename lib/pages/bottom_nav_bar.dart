import 'package:flutter/material.dart';
import 'home_page.dart';
import 'search.dart';
import 'qibla_page.dart';
import 'prayer_timing_page.dart';
import 'profile_page.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Map<String, dynamic>? user;

  const BottomNavBar({super.key, required this.currentIndex, this.user});

  @override
  Widget build(BuildContext context) {
    final userData = user ?? {};

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.yellow.shade700,
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
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
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage(user: userData)),
            );
            break;

          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SearchPage()),
            );
            break;

          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => QiblaPage()),
            );
            break;

          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PrayerTimingPage()),
            );
            break;

          case 4:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => ProfilePage(user: userData)),
            );
            break;
        }
      },
    );
  }
}

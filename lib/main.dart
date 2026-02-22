import 'package:flutter/material.dart';

import 'pages/splash_screen.dart';
import 'services/quran_api.dart';
import 'services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';
import 'services/theme_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase initialization
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  // 🗂 Local storage (Hive)
  await QuranApi.initHive();

  // ⏰ Init Alarm Manager
  await AndroidAlarmManager.initialize();

  // 🔔 Notification service init
  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint("❌ Notification service initialization failed: $e");
  }

  debugPrint("🚀 Starting FaithWay App...");
  runApp(const FaithWayApp());
}

class FaithWayApp extends StatelessWidget {
  const FaithWayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeMode,
      builder: (context, currentMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FaithWay',
          themeMode: currentMode,
          theme: ThemeData(
            primaryColor: Colors.yellow.shade700,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.black),
              titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            colorScheme: ColorScheme.light(
              primary: Colors.yellow.shade700,
              secondary: const Color(0xFF0F766E), // Teal
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.yellow.shade700,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF121212),
              iconTheme: const IconThemeData(color: Colors.white),
              titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            colorScheme: ColorScheme.dark(
              primary: Colors.yellow.shade700,
              secondary: const Color(0xFF0F766E),
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'notification_service.dart';

class PrayerService {
  /// 🔹 Main function to refresh and schedule all prayer notifications
  static Future<void> refreshAndScheduleNotifications() async {
    try {
      // 1. Get position
      Position? position = await _getCurrentPosition();
      if (position == null) return;

      // 2. Clear all existing prayer notifications first
      await NotificationService.cancelPrayerNotifications();

      // 3. Schedule for today and the next 6 days (Total 7 days)
      final now = DateTime.now();
      for (int i = 0; i < 7; i++) {
        final date = now.add(Duration(days: i));
        final dateStr = DateFormat("dd-MM-yyyy").format(date);
        
        final url = "https://api.aladhan.com/v1/timings/$dateStr?latitude=${position.latitude}&longitude=${position.longitude}&method=2";
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final Map<String, dynamic> timings = data['data']['timings'];
          await _schedulePrayersForDate(timings, date, dayOffset: i);
        }
      }
      
      debugPrint("✅ Prayer notifications for the next 7 days auto-scheduled.");
    } catch (e) {
      debugPrint("❌ PrayerService Error: $e");
    }
  }

  static Future<Position?> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
  }

  static Future<void> _schedulePrayersForDate(Map<String, dynamic> timings, DateTime date, {required int dayOffset}) async {
    final List<String> prayerNames = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];
    final now = DateTime.now();
    final dateStr = DateFormat("yyyy-MM-dd").format(date);

    for (int i = 0; i < prayerNames.length; i++) {
      final name = prayerNames[i];
      final String fullTimeStr = timings[name];
      final String cleanTime = fullTimeStr.split(" ").first;
      
      final prayerDateTime = DateTime.parse("$dateStr $cleanTime:00");

      // Unique ID calculation: 100 + (dayOffset * 10) + i
      // This ensures unique IDs for each prayer across 7 days (IDs will be 100-169 for Azan, 200-269 for reminders)
      final azanId = 100 + (dayOffset * 10) + i;
      final reminderId = 200 + (dayOffset * 10) + i;

      // Only schedule if the time hasn't passed
      if (prayerDateTime.isAfter(now)) {
        // 🕌 Exact time Azan
        await NotificationService.scheduleAzan(
          id: azanId,
          prayerName: name,
          time: prayerDateTime,
        );

        // 🔔 5 minutes before reminder
        final reminderTime = prayerDateTime.subtract(const Duration(minutes: 5));
        if (reminderTime.isAfter(now)) {
          await NotificationService.scheduleReminder(
            id: reminderId,
            prayerName: name,
            time: reminderTime,
          );
        }
      }
    }
  }
}

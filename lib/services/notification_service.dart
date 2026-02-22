import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

// ⏰ TOP-LEVEL Background Alarm Callback (Required by Android Alarm Manager)
@pragma('vm:entry-point')
void fireAlarmCallback() async {
  debugPrint("🔥 ALARM FIRED IN BACKGROUND! Playing Sound...");
  
  // Play alarm for 30 seconds (non-looping to make it stoppable)
  FlutterRingtonePlayer().playAlarm(
    looping: false, // ✅ Changed to false so it can be stopped
    volume: 1.0,
    asAlarm: true,
  );
  
  // Auto-stop after 30 seconds
  await Future.delayed(const Duration(seconds: 30));
  FlutterRingtonePlayer().stop();
  debugPrint("⏰ Alarm auto-stopped after 30 seconds");
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    debugPrint("🔔 NotificationService: Initializing...");
    // 🔔 OneSignal Initialization (Mobile Only)
    if (!kIsWeb) {
      try {
        OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
        OneSignal.initialize("3b96e829-1dca-4d79-93d9-7aa86ea549b9");
        
        // 📢 Request OneSignal Permission
        OneSignal.Notifications.requestPermission(true);

        // 🎯 Notification Click Listener
        OneSignal.Notifications.addClickListener((event) {
          debugPrint("OneSignal Notification Clicked: ${event.notification.jsonRepresentation()}");
        });

      } catch (e) {
        debugPrint("OneSignal init failed: $e");
      }
    }

    if (!kIsWeb) {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: android);
      
      try {
        await _plugin.initialize(
          settings,
          onDidReceiveNotificationResponse: (NotificationResponse response) async {
            debugPrint("🔔 Notification tapped! Stopping alarm...");
            
            // 1. Stop the ringtone player
            await stopRingtone();
            
            // 2. Cancel all pending notifications
            await _plugin.cancelAll();
            
            debugPrint("✅ Alarm stopped successfully!");
          },
        );
        debugPrint("✅ FlutterLocalNotifications initialized.");
      } catch (e) {
        debugPrint("❌ FlutterLocalNotifications init failed: $e");
      }

      // 🚨 Request Flutter Local Notifications permissions for Android 13+
      final platform = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (platform != null) {
        debugPrint("📢 Requesting Android Permissions...");
        await platform.requestNotificationsPermission();
        await platform.requestExactAlarmsPermission();

        // 🆕 Explicitly Create Alarm Channel (v3)
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'special_prayer_channel_v3',
          'Special Prayer Alarms',
          description: 'Alarms for Special Prayers that play even in Silent Mode',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('azan'),
          enableVibration: true,
          audioAttributesUsage: AudioAttributesUsage.alarm, // 🚨 Force Alarm Stream
        );
        await platform.createNotificationChannel(channel);
        debugPrint("✅ Alarm Channel Created: ${channel.id}");
      }
    }

    tz.initializeTimeZones();
    
    try {
      // 🌍 Best-effort local timezone detection
      final String timeZoneName = DateTime.now().timeZoneName;
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint("🌍 Timezone set to detected: $timeZoneName");
      } catch (e) {
        // Fallback: Find a matching timezone by offset
        final int offsetInHours = DateTime.now().timeZoneOffset.inHours;
        final locations = tz.timeZoneDatabase.locations.values;
        tz.Location? bestMatch;
        
        for (final loc in locations) {
          if (loc.currentTimeZone.offset == DateTime.now().timeZoneOffset.inMilliseconds) {
            bestMatch = loc;
            break;
          }
        }

        if (bestMatch != null) {
           tz.setLocalLocation(bestMatch);
           debugPrint("🌍 Timezone set by offset to: ${bestMatch.name}");
        } else {
           // Last resort: UTC
           tz.setLocalLocation(tz.getLocation('UTC'));
           debugPrint("🌍 Timezone fallback to UTC");
        }
      }
    } catch (e) {
      debugPrint("❌ Timezone init error: $e");
    }
    debugPrint("🌍 Timezones initialized.");
  }

  /// 👤 Link User Email/UID to OneSignal for targeted notifications
  static Future<void> setExternalId(String id) async {
    if (kIsWeb) return;
    try {
      OneSignal.login(id);
      debugPrint("OneSignal External ID set: $id");
    } catch (e) {
      debugPrint("Failed to set OneSignal ID: $e");
    }
  }

  /// 🔓 Unlink User on Logout
  static Future<void> logout() async {
    if (kIsWeb) return;
    try {
      OneSignal.logout();
      debugPrint("OneSignal Logged Out");
    } catch (e) {
      debugPrint("Failed OneSignal logout: $e");
    }
  }

  // 🔔 Reminder (5 min before)
  static Future<void> scheduleReminder({
    required int id,
    required String prayerName,
    required DateTime time,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        'Prayer Reminder',
        '$prayerName prayer in 5 minutes',
        tz.TZDateTime.from(time, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel_v2', // Updated Channel ID
            'Prayer Reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, // ✅ Changed for compatibility
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint("❌ Failed to schedule reminder: $e");
    }
  }

  // 🕌 Exact time Azan
  static Future<void> scheduleAzan({
    required int id,
    required String prayerName,
    required DateTime time,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        'Prayer Time',
        'It is time for $prayerName prayer',
        tz.TZDateTime.from(time, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'azan_channel',
            'Prayer Notifications',
            importance: Importance.max,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound('azan'),
            playSound: true,
            enableVibration: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, // ✅ Changed for compatibility
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint("❌ Failed to schedule Azan (Possible exact alarm permission issue): $e");
    }
  }

  /// ⚡ Show Instant Notification (Debug/Test)
  static Future<void> showInstantNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'Instant Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      888, // Unique ID for test
      title,
      body,
      details,
    );
  }

  /// 🔊 Test Azan Sound
  static Future<void> testAzanSound() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'azan_channel',
      'Prayer Notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('azan'), // Points to azan.wav
      playSound: true,
      enableVibration: true,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      999, // Unique ID for sound test
      "🔊 Azan Sound Test",
      "Alliance of Faith - Azan Test",
      details,
    );
  }

  /// ⏰ Schedule Special Prayer Alarm (with Azan Sound & Exact Mode)
  static Future<void> scheduleSpecialPrayerAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

      // Don't schedule if time is in the past
      if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) {
        debugPrint("⚠️ Special Prayer: Skipping past time $tzTime");
        return;
      }

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'special_prayer_channel_v3', // 🆕 Matches Explicit Channel
            'Special Prayer Alarms',
            channelDescription: 'Alarms for Special Prayers that play even in Silent Mode',
            importance: Importance.max,
            priority: Priority.max,
            sound: RawResourceAndroidNotificationSound('azan'),
            playSound: true,
            enableVibration: true,
            audioAttributesUsage: AudioAttributesUsage.alarm,
            category: AndroidNotificationCategory.alarm,
            fullScreenIntent: true,
            additionalFlags: Int32List.fromList(<int>[4]), // Insistent
          ),
          iOS: DarwinNotificationDetails(
            sound: 'azan.caf',
            presentSound: true,
            interruptionLevel: InterruptionLevel.critical, // iOS Critical Alert (if permitted)
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.alarmClock, // ⏰ Shows as Alarm Clock on Android
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      // 2. Schedule BACKGROUND SOUND (The "Nuclear" option) ☢️
      // This runs pure Dart code at the exact time to play the ringtone
      // independent of the notification system's restrictions.
      await AndroidAlarmManager.oneShotAt(
        scheduledTime,
        id, 
        fireAlarmCallback,
        exact: true,
        wakeup: true, // Wakes up CPU
        alarmClock: true, // Shows as Alarm in system
        rescheduleOnReboot: true,
      );

      debugPrint("✅ Special Prayer Scheduled as ALARM: $title at $tzTime (ID: $id)");
    } catch (e) {
      debugPrint("❌ Failed to schedule Special Prayer: $e");
    }
  }

  /// 🧪 Debug: Schedule a test alarm with DEFAULT system sound (to rule out file size issues)
  static Future<void> scheduleTestAlarm() async {
    final now = DateTime.now().add(const Duration(seconds: 15));
    final tzTime = tz.TZDateTime.from(now, tz.local);
   
    await _plugin.zonedSchedule(
      777,
      '🧪 Silent Mode Test',
      'This uses the DEFAULT system alarm sound. Does it ring?',
      tzTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'debug_channel_v2', // 🧪 CLEAN Channel v2
          'Debug Alarms',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          audioAttributesUsage: AudioAttributesUsage.alarm, // 🚨 Back to Alarm standard
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          additionalFlags: Int32List.fromList(<int>[4]), // Insistent
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    
    // 🔔 FORCE PLAY ALARM SOUND IMMEDIATELY (For testing)
    FlutterRingtonePlayer().playAlarm(
      looping: true, 
      volume: 1.0,   
      asAlarm: true, 
    );
    
    debugPrint("✅ Test Alarm Scheduled + Forced Ringtone Play!");
  }

  // 🛑 STOP EVERYTHING (Sound + Vibration)
  static Future<void> stopRingtone() async {
    debugPrint("🛑 Stopping Alarm Sound & Vibration...");
    
    // 1. Stop Audio Player
    await FlutterRingtonePlayer().stop();
    
    // 2. Cancel Notification (stops native vibration)
    await _plugin.cancelAll();
  }

  /// 🛠️ Request Permissions manually
  static Future<void> requestPermissions() async {
    final platform = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
    if (platform != null) {
      await platform.requestNotificationsPermission();
      await platform.requestExactAlarmsPermission();
    }
  }

  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// 🧹 Cancel only Prayer and Reminder notifications (IDs 100-299)
  static Future<void> cancelPrayerNotifications() async {
    for (int i = 0; i < 70; i++) {
       await _plugin.cancel(100 + i); 
       await _plugin.cancel(200 + i); 
    }
  }

  /// 🧹 Cancel only Feature Reminders (IDs 300-305)
  static Future<void> cancelFeatureNotifications() async {
    for (int i = 0; i < 10; i++) {
       await _plugin.cancel(300 + i);
    }
  }

  /// 🌐 Send Global Notification (Option 2 - Direct API Trigger)
  static Future<void> sendGlobalNotification({
    required String title,
    required String message,
  }) async {
    const String appId = "3b96e829-1dca-4d79-93d9-7aa86ea549b9";
    const String restApiKey = "os_v2_app_holoqki5zjgxte6zpkug5jkjxhqxewjewunuywmejh6ipbsgjuwmzy67bgues5bpofdonhcmqeez45jkahydew5yi3wbeiirtxed4ha";

    if (restApiKey == "YOUR_REST_API_KEY_HERE") {
      debugPrint("❌ Cannot send global notification: REST API Key is missing.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "Authorization": "Basic $restApiKey"
        },
        body: jsonEncode({
          "app_id": appId,
          "included_segments": ["All"], 
          "headings": {"en": title},
          "contents": {"en": message},
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Global Notification sent successfully!");
      } else {
        debugPrint("❌ Failed to send notification: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Error sending global notification: $e");
    }
  }

  /// 🚶‍♂️ Schedule Feature Reminders (Sequence every 3 hours)
  static Future<void> scheduleFeatureReminders() async {
    final List<Map<String, String>> features = [
      {"title": "Holy Quran", "msg": "Listen and Read the Holy Quran 📖"},
      {"title": "Daily Hadith", "msg": "Read today's Hadith and gain knowledge 🌙"},
      {"title": "Duas & Azkar", "msg": "Don't forget your daily Duas 🤲"},
      {"title": "Tasbeeh Counter", "msg": "Keep your Zikr alive with Tasbeeh 📿"},
      {"title": "Qibla Finder", "msg": "Accurately find Qibla direction anywhere 🕋"},
      {"title": "Names of Allah", "msg": "Learn the beautiful 99 Names of Allah ✨"},
    ];

    final now = DateTime.now();
    debugPrint("🕒 Scheduling Feature Reminders starting from: $now");

    for (int i = 0; i < features.length; i++) {
      // ⏱️ Production Interval: 5 Minutes
      final scheduledTime = now.add(Duration(minutes: (i + 1) * 5));
      
      try {
        await _plugin.zonedSchedule(
          300 + i, 
          features[i]['title']!,
          features[i]['msg']!,
          tz.TZDateTime.from(scheduledTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'feature_channel_v3', // Fresh Clean Channel
              'Feature Reminders',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true, 
              enableVibration: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, // ✅ Proven Working Mode
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint("✅ Scheduled Feature ${i+1} for $scheduledTime");
      } catch (e) {
        debugPrint("❌ Failed to schedule feature $i: $e");
      }
    }
  }
}

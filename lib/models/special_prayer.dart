import 'package:cloud_firestore/cloud_firestore.dart';

class SpecialPrayer {
  final String id;
  final String prayerName;
  final String title;
  final DateTime dateTime;
  final bool isEnabled;

  SpecialPrayer({
    required this.id,
    required this.prayerName,
    required this.title,
    required this.dateTime,
    this.isEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'prayerName': prayerName,
      'title': title,
      'dateTime': Timestamp.fromDate(dateTime),
      'isEnabled': isEnabled,
    };
  }

  factory SpecialPrayer.fromMap(Map<String, dynamic> map, String id) {
    return SpecialPrayer(
      id: id,
      prayerName: map['prayerName'] ?? '',
      title: map['title'] ?? '',
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      isEnabled: map['isEnabled'] ?? true,
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class PrayerTimeBox extends StatefulWidget {
  final Color boxColor;

  const PrayerTimeBox({super.key, required this.boxColor});

  @override
  State<PrayerTimeBox> createState() => _PrayerTimeBoxState();
}

class _PrayerTimeBoxState extends State<PrayerTimeBox> {
  PrayerTimes? prayerTimes;
  String nowPrayer = '';
  String nextPrayer = '';
  String nextPrayerTime = '';

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
    Timer.periodic(const Duration(minutes: 1), (_) {
      _loadPrayerTimes();
    });
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );

      final coordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.karachi.getParameters();
      params.madhab = Madhab.hanafi;

      final today = DateComponents.from(DateTime.now());
      final times = PrayerTimes(coordinates, today, params);

      final now = DateTime.now();

      Prayer? current;
      Prayer? next;
      DateTime? nextPrayerDateTime;

      // Iterate through prayers to find current and next
      for (var i = 0; i < Prayer.values.length; i++) {
        final prayer = Prayer.values[i];
        final time = times.timeForPrayer(prayer);
        if (time != null && now.isBefore(time)) {
          next = prayer;
          nextPrayerDateTime = time;
          if (i == 0) {
            // If now is before Fajr, current = Isha (previous day)
            current = Prayer.isha;
          } else {
            current = Prayer.values[i - 1];
          }
          break;
        }
      }

      // If all today's prayers are over, current = Isha, next = Fajr (next day)
      if (next == null) {
        current = Prayer.isha;
        next = Prayer.fajr;
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final tomorrowTimes = PrayerTimes(
          coordinates,
          DateComponents.from(tomorrow),
          params,
        );
        nextPrayerDateTime = tomorrowTimes.timeForPrayer(Prayer.fajr);
      }

      setState(() {
        prayerTimes = times;
        nowPrayer = _formatPrayerName(current!);
        nextPrayer = _formatPrayerName(next!);
        nextPrayerTime = DateFormat.jm().format(nextPrayerDateTime!);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        nowPrayer = 'Error';
        nextPrayer = '';
        nextPrayerTime = '';
      });
    }
  }

  String _formatPrayerName(Prayer prayer) {
    return prayer.name[0].toUpperCase() + prayer.name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    if (prayerTimes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: widget.boxColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Now prayer is",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                nowPrayer,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Next prayer in",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                nextPrayerTime,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(nextPrayer, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}

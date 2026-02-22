import 'dart:math';
import 'dart:ui';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compass_v2/flutter_compass_v2.dart';
import 'package:geolocator/geolocator.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  double? _qiblaAngle; // Qibla direction (0–360)
  double? _deviceHeading; // Device heading (0–360)
  bool _loading = true;
  String? _error;

  StreamSubscription<CompassEvent>? _compassSub;

  @override
  void initState() {
    super.initState();
    _calculateQibla();
    _listenCompass();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  /// 📍 Calculate Qibla angle
  Future<void> _calculateQibla() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() {
          _error = "Please enable location services";
          _loading = false;
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
          _error = "Location permission denied";
          _loading = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 🕋 Kaaba coordinates
      const kaabaLat = 21.4225;
      const kaabaLng = 39.8262;

      final lat1 = pos.latitude * pi / 180;
      final lon1 = pos.longitude * pi / 180;
      final lat2 = kaabaLat * pi / 180;
      final lon2 = kaabaLng * pi / 180;

      final angle = atan2(
        sin(lon2 - lon1),
        cos(lat1) * tan(lat2) - sin(lat1) * cos(lon2 - lon1),
      );

      setState(() {
        _qiblaAngle = (angle * 180 / pi + 360) % 360;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = "Unable to calculate Qibla direction";
        _loading = false;
      });
    }
  }

  /// 🧭 Compass listener
  void _listenCompass() {
    _compassSub = FlutterCompass.events?.listen((event) {
      if (!mounted || event.heading == null) return;
      setState(() {
        _deviceHeading = event.heading;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade700,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: const Text(
          "Qibla Direction",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          // 🌄 Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/mosque_background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🌫 Blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),

          // 📍 Main content
          Center(
            child: _loading
                ? CircularProgressIndicator(color: Colors.yellow.shade700)
                : _error != null
                ? Text(
                    _error!,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  )
                : _deviceHeading == null
                ? const Text(
                    "Compass not available",
                    style: TextStyle(color: Colors.white),
                  )
                : _buildCompass(),
          ),
        ],
      ),
    );
  }

  /// 🧭 Compass UI
  Widget _buildCompass() {
    final rotation = (_qiblaAngle! - _deviceHeading!) * pi / 180;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // 🧭 Compass needle layer (contains the compass face in this project)
            Transform.rotate(
              angle: rotation,
              child: Image.asset("assets/qibla_needle.png", width: 300),
            ),

            // 🕋 Kaaba icon at Qibla direction
            Transform.rotate(
              angle: rotation,
              child: Transform.translate(
                offset: const Offset(0, -135),
                child: Image.asset("assets/kaaba_icon.png", width: 32),
              ),
            ),

            // 🎯 Center dot
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.yellow.shade700,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 🔄 Instruction text
        const Text(
          "Rotate your phone to get\n the correct direction",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}

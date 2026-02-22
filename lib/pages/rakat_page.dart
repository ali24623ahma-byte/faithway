import 'package:flutter/material.dart';

class RakatPage extends StatelessWidget {
  const RakatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prayer Rakats"),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: Stack(
        children: [
          // 🔹 Background Mosque Image
          Positioned.fill(
            child: Image.asset(
              'assets/mosque_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // 🔹 Dark Overlay (optional but recommended)
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          // 🔹 Zoomable Rakat Image
          Center(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Image.asset(
                'assets/prayer_rakat.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

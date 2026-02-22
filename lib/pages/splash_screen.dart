import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Navigate to AuthWrapper after 4 seconds
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Elegant dark background
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🏷️ Centered Logo
            Container(
              width: 300, // Increased from 240
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/splash_logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // 🔄 Rotating Circular Text Loader
            RotationTransition(
              turns: _controller,
              child: CustomPaint(
                size: const Size(320, 320), // Increased to 320 to fit close to 300 logo
                painter: CircularTextPainter(
                  text: "Path of Faith • Peace • Guidance • Light • FaithWay • Path of Faith • Peace • Guidance • Light • FaithWay • ", 
                  textStyle: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 14, // Slightly smaller
                    fontWeight: FontWeight.w600, // Slightly bolder for visibility
                    letterSpacing: 1.0, // Reduced spacing
                    fontFamily: 'Serif', 
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularTextPainter extends CustomPainter {
  final String text;
  final TextStyle textStyle;

  CircularTextPainter({required this.text, required this.textStyle});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    final double charAngle = (2 * math.pi) / text.length;

    for (int i = 0; i < text.length; i++) {
      final double angle = i * charAngle;
      
      // Calculate position
      final double x = centerX + radius * math.cos(angle);
      final double y = centerY + radius * math.sin(angle);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + math.pi / 2); // Rotate each character to face center

      final TextPainter tp = TextPainter(
        text: TextSpan(text: text[i], style: textStyle),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

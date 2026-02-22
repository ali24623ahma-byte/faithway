import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../services/notification_service.dart';
import '../services/prayer_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While waiting for auth state, show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          // Set OneSignal ID 🔔
          NotificationService.setExternalId(user.uid);

          return HomePage(user: {
            'username': user.displayName ?? 'User',
            'email': user.email ?? '',
            'uid': user.uid,
            'image': user.photoURL ?? '',
          });
        }

        // Not logged in → Login Page
        return const LoginPage();
      },
    );
  }
}

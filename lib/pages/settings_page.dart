import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/theme_service.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  final UserProfile userProfile;

  const SettingsPage({super.key, required this.userProfile});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _notificationsEnabled;
  late bool _darkMode;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = widget.userProfile.settings['notificationsEnabled'] ?? true;
    _darkMode = widget.userProfile.settings['darkMode'] ?? true;
  }

  void _updateSetting(String key, bool value) async {
    setState(() {
      if (key == 'notificationsEnabled') _notificationsEnabled = value;
      if (key == 'darkMode') {
        _darkMode = value;
        ThemeService.toggleTheme(value);
      }
    });

    Map<String, dynamic> newSettings = {
      'notificationsEnabled': _notificationsEnabled,
      'darkMode': _darkMode,
    };

    await _userService.updateSettings(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark Background
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔔 Notifications
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active, color: Color(0xFFFFC107)), // Amber
            title: const Text("Notifications", style: TextStyle(color: Colors.white)),
            value: _notificationsEnabled,
            activeColor: const Color(0xFFFFC107), // Amber Toggle
            tileColor: const Color(0xFF1E1E1E), // Card BG
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            onChanged: (val) => _updateSetting('notificationsEnabled', val),
          ),
          
          const SizedBox(height: 15),

          // 🌙 Dark Mode
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode, color: Colors.indigoAccent),
            title: const Text("Dark Mode", style: TextStyle(color: Colors.white)),
            value: _darkMode,
            activeColor: Colors.indigoAccent,
            tileColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            onChanged: (val) => _updateSetting('darkMode', val),
          ),

          const SizedBox(height: 30),
          const Divider(color: Colors.white24, indent: 20, endIndent: 20),
          const SizedBox(height: 10),

          // ⭐ Rate App
          _buildSettingsTile(
            icon: Icons.star, 
            color: Colors.orangeAccent, 
            title: "Rate App",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coming Soon!")));
            }
          ),

          // 📤 Share App
          _buildSettingsTile(
            icon: Icons.share, 
            color: Colors.blueAccent, 
            title: "Share App",
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sharing link...")));
            }
          ),

          const SizedBox(height: 10),
          const Divider(color: Colors.white24, indent: 20, endIndent: 20),
          const SizedBox(height: 10),

          // 🔒 Privacy Policy
          _buildSettingsTile(
            icon: Icons.verified_user, 
            color: Colors.greenAccent, 
            title: "Privacy Policy",
            onTap: () {}
          ),

          // 📄 Terms & Conditions
          _buildSettingsTile(
            icon: Icons.description, 
            color: Colors.grey, 
            title: "Terms & Conditions",
            onTap: () {}
          ),

          // 🔑 Change Password
          _buildSettingsTile(
            icon: Icons.lock_reset, 
            color: Colors.redAccent, 
            title: "Change Password",
            onTap: () async {
              if (widget.userProfile.email.isNotEmpty) {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: widget.userProfile.email);
                if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reset link sent to your email!")));
                }
              }
            }
          ),
          
          const SizedBox(height: 30),

          // 🚪 Logout
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.redAccent),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required Color color, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

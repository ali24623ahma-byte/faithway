import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import 'bottom_nav_bar.dart';
import 'settings_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> user; // Keeping for compatibility with bottom nav

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  late Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = _userService.getUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 280;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () async {
              final profile = await _profileFuture;
              if (profile != null && mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsPage(userProfile: profile)),
                ).then((_) => _refreshProfile());
              }
            },
          )
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 4, user: widget.user),
      body: FutureBuilder<UserProfile?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: const Color(0xFF121212), // Dark BG
              child: const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107))), // Amber
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Scaffold(
              body: Stack(
                children: [
                   Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/mosque_background.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(color: Colors.black.withOpacity(0.6)),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white, size: 50),
                        const SizedBox(height: 10),
                        const Text("Failed to load profile", style: TextStyle(color: Colors.white)),
                        TextButton(
                          onPressed: _refreshProfile, 
                          child: const Text("Retry", style: TextStyle(color: Color(0xFFFFC107)))
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          final profile = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // 🕌 Header Section (Mosque BG + Avatar)
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Background Image
                    Container(
                      height: headerHeight,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/mosque_background.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Dark Overlay
                    Container(
                      height: headerHeight,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    
                    // Profile Info
                    Positioned(
                      bottom: 40, 
                      child: Column(
                        children: [
                          // 🖼️ Avatar with Border
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFFC107), width: 3), // Amber Border
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.grey.shade800,
                              backgroundImage: profile.profilePhotoUrl.isNotEmpty 
                                  ? AssetImage(profile.profilePhotoUrl)
                                  : const AssetImage('assets/profile_dummy.png'),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // 👤 Name
                          Text(
                            profile.name,
                            style: const TextStyle(
                              fontSize: 24, 
                              fontWeight: FontWeight.bold, 
                              color: Colors.white,
                              shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                            ),
                          ),
                          
                          // 📧 Email
                           Text(
                            profile.email,
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 📄 Bio & Details Section
                Container(
                  transform: Matrix4.translationValues(0, -20, 0), // Pull up slightly
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E1E1E), // Dark Surface
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Bio Quote Style
                      if (profile.bio.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 25),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2C), // Slightly Lighter Dark
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Text(
                            "\"${profile.bio}\"",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade400, 
                              fontStyle: FontStyle.italic,
                              fontSize: 15,
                            ),
                          ),
                        ),

                      // 🛠️ Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFC107), // Amber
                                foregroundColor: Colors.black, // Dark Text
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => EditProfilePage(userProfile: profile)),
                                ).then((updated) {
                                  if (updated == true) _refreshProfile();
                                });
                              },
                              icon: const Icon(Icons.edit, size: 18, color: Colors.black),
                              label: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // ℹ️ Information Tiles
                      _buildInfoTile(Icons.location_on, "Location", profile.location.isEmpty ? "Not set" : profile.location),
                      _buildInfoTile(Icons.person, "Gender", profile.gender.isEmpty ? "Not set" : profile.gender),
                      _buildInfoTile(Icons.calendar_today, "Member Since", "January 2026"), // Placeholder date
                      
                      const SizedBox(height: 20),
                      
                      // Theme Divider
                      const Divider(color: Colors.white12),
                      
                      const SizedBox(height: 10),
                      
                      Text(
                        "FaithWay App v1.0.0",
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107).withOpacity(0.1), // Amber Tint
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFFFC107), size: 22), // Amber Icon
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white, // White Text
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

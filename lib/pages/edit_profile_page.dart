import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'login_page.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfilePage({super.key, required this.userProfile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  String? _selectedGender;
  String _selectedAvatar = '';
  final UserService _userService = UserService();
  bool _isLoading = false;

  final List<String> _avatars = [
    'assets/profile_dummy.png',
    // In future, you can add more avatar assets here like:
    // 'assets/avatars/avatar1.png',
    // 'assets/avatars/avatar2.png',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile.name);
    _bioController = TextEditingController(text: widget.userProfile.bio);
    _locationController = TextEditingController(text: widget.userProfile.location);
    _selectedGender = widget.userProfile.gender.isNotEmpty ? widget.userProfile.gender : null;
    _selectedAvatar = widget.userProfile.profilePhotoUrl.isNotEmpty 
        ? widget.userProfile.profilePhotoUrl 
        : 'assets/profile_dummy.png';
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      UserProfile updatedProfile = widget.userProfile.copyWith(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        location: _locationController.text.trim(),
        gender: _selectedGender,
        profilePhotoUrl: _selectedAvatar,
      );

      await _userService.updateUserProfile(updatedProfile);

      setState(() => _isLoading = false);
      
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate update
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated Successfully!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF121212),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFFC107), width: 2), // Amber
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade800,
                            backgroundImage: AssetImage(_selectedAvatar),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            // onTap: _showAvatarPicker, // Re-enable when ready
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC107), // Amber
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, size: 16, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text("Personal Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),

                  // 📝 Name
                  _buildLabel("Full Name"),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Enter your name", Icons.person_outline),
                    validator: (val) => val!.isEmpty ? "Name Required" : null,
                  ),
                  const SizedBox(height: 20),

                  // 📧 Email
                  _buildLabel("Email Address"),
                  TextFormField(
                    initialValue: widget.userProfile.email,
                    readOnly: true,
                    style: TextStyle(color: Colors.grey.shade400),
                    decoration: _inputDecoration("Email", Icons.email_outlined).copyWith(
                      fillColor: const Color(0xFF2C2C2C),
                      suffixIcon: const Icon(Icons.lock_outline, size: 18, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ⚤ Gender
                  _buildLabel("Gender"),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Select Gender", Icons.people_outline),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    items: const [
                      DropdownMenuItem(value: "Male", child: Text("Male")),
                      DropdownMenuItem(value: "Female", child: Text("Female")),
                    ],
                    onChanged: (val) => setState(() => _selectedGender = val),
                  ),
                  const SizedBox(height: 20),

                  // 📍 Location
                  _buildLabel("Location"),
                  TextFormField(
                    controller: _locationController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("City, Country", Icons.location_on_outlined),
                  ),
                  const SizedBox(height: 20),

                  // 🗒️ Bio
                  _buildLabel("Bio"),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Tell us about yourself...", null).copyWith(
                      alignLabelWithHint: true,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 💾 Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107), // Amber
                        foregroundColor: Colors.black, // Dark Text
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 2,
                      ),
                      onPressed: _saveProfile,
                      child: const Text(
                        "Save Changes", 
                        style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ❌ Delete Account
                  Center(
                    child: TextButton.icon(
                      onPressed: _confirmDelete,
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      label: const Text("Delete Account", style: TextStyle(color: Colors.redAccent)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label, 
        style: TextStyle(
          color: Colors.grey.shade400, 
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData? icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey.shade500, size: 22) : null,
      filled: true,
      fillColor: const Color(0xFF1E1E1E), // Dark Field
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFFFC107), width: 1.5), // Amber Focus
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account?"),
        content: const Text("This action cannot be undone. You will lose all your data."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              await _userService.deleteAccount();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

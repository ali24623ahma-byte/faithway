import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/special_prayer.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';

class SpecialPrayerPage extends StatefulWidget {
  const SpecialPrayerPage({super.key});

  @override
  State<SpecialPrayerPage> createState() => _SpecialPrayerPageState();
}

class _SpecialPrayerPageState extends State<SpecialPrayerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final UserService _userService = UserService();
  bool _isSaving = false;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF0F766E), // Teal
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _setAlarm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      debugPrint("🕐 Scheduled Time: $scheduledDateTime");

      if (scheduledDateTime.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a future time")),
        );
        setState(() => _isSaving = false);
        return;
      }

      final prayerId = const Uuid().v4();
      final notificationId = scheduledDateTime.millisecondsSinceEpoch ~/ 10000;

      debugPrint("🆔 Prayer ID: $prayerId, Notification ID: $notificationId");

      final newPrayer = SpecialPrayer(
        id: prayerId,
        prayerName: _nameController.text.trim(),
        title: _titleController.text.trim(),
        dateTime: scheduledDateTime,
      );

      debugPrint("💾 Saving to Firestore...");
      // 1. Save to Firestore (with timeout to prevent hanging)
      try {
        await _userService.saveSpecialPrayer(newPrayer).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint("⚠️ Firestore save timed out (offline?), continuing anyway...");
          },
        );
        debugPrint("✅ Firestore save complete!");
      } catch (firestoreError) {
        debugPrint("⚠️ Firestore save failed: $firestoreError (continuing anyway)");
      }

      debugPrint("⏰ Scheduling alarm...");
      // 2. Schedule Notification with Azan Sound
      await NotificationService.scheduleSpecialPrayerAlarm(
        id: notificationId,
        title: "⏰ Special Prayer: ${newPrayer.prayerName}",
        body: "It is time for: ${newPrayer.title}",
        scheduledTime: scheduledDateTime,
      );
      debugPrint("✅ Alarm scheduled!");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Special Prayer Alarm Set Successfully! 🔔"),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _nameController.clear();
      _titleController.clear();
      
    } catch (e) {
      debugPrint("❌ ERROR in _setAlarm: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/mosque_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.7),
          child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // --- Header with Back Button ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white54, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      // Glowing Dot Indicator
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFC107), // Amber
                          boxShadow: [
                            BoxShadow(color: const Color(0xFFFFC107).withOpacity(0.6), blurRadius: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // --- Stylish Title ---
                  const Text(
                    "Divine\nConnection",
                    style: TextStyle(
                      fontFamily: 'Serif', 
                      fontSize: 42,
                      height: 1.1,
                      color: Colors.white,
                      fontWeight: FontWeight.w300, 
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Sanctify your time with prayer.",
                    style: TextStyle(
                      color: const Color(0xFFFFC107).withOpacity(0.8), // Amber Text
                      fontSize: 14,
                      letterSpacing: 1.0,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // --- Open Layout Form (No Card) ---
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _minimalInput(
                          controller: _nameController,
                          label: "INTENTION", 
                          hint: "e.g., Tahajjud",
                          icon: Icons.edit_outlined,
                        ),
                        const SizedBox(height: 30),
                        
                        _minimalInput(
                          controller: _titleController,
                          label: "REFLECTION",
                          hint: "Add a personal note...",
                          icon: Icons.bubble_chart_outlined,
                        ),
                        const SizedBox(height: 40),

                        // Sleek Date/Time Pickers
                        Row(
                          children: [
                            Expanded(
                              child: _minimalPicker(
                                label: "DATE",
                                value: DateFormat('dd MMM').format(_selectedDate),
                                onTap: _pickDate,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _minimalPicker(
                                label: "TIME",
                                value: _selectedTime.format(context),
                                onTap: _pickTime,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 60),

                        // Stylish Button
                        InkWell(
                          onTap: _isSaving ? null : _setAlarm,
                          child: Container(
                            height: 60,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.5)),
                              color: const Color(0xFFFFC107).withOpacity(0.1),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFC107).withOpacity(0.15),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 20, width: 20,
                                      child: CircularProgressIndicator(color: Color(0xFFFFC107), strokeWidth: 2)
                                    )
                                  : const Text(
                                      "SCHEDULE DEVOTION",
                                      style: TextStyle(
                                        color: Color(0xFFFFC107),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 70),

                  // --- Minimal List ---
                  Text(
                    "ACTIVE PRAYERS",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildMinimalList(),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _minimalInput({required TextEditingController controller, required String label, required String hint, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Serif'),
          cursorColor: const Color(0xFFFFC107), // Amber Cursor
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontFamily: 'Sans'),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.5))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFC107))), // Amber Border
            suffixIcon: Icon(icon, color: Colors.white70, size: 20),
          ),
          validator: (val) => val!.isEmpty ? "" : null,
        ),
      ],
    );
  }

  Widget _minimalPicker({required String label, required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: const Color(0xFFFFC107).withOpacity(0.5))), // Amber Underline
            ),
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontFamily: 'Serif'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalList() {
    return StreamBuilder<List<SpecialPrayer>>(
      stream: _userService.getSpecialPrayersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox();
        final prayers = snapshot.data ?? [];
        if (prayers.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              "Your sanctuary is quiet.",
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontStyle: FontStyle.italic),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: prayers.length,
          itemBuilder: (context, index) {
            final p = prayers[index];
            final isPast = p.dateTime.isBefore(DateTime.now());

            return Container(
              margin: const EdgeInsets.only(bottom: 25),
              child: Row(
                children: [
                  // Vertical timeline line
                  Container(
                    height: 50,
                    width: 3,
                    decoration: BoxDecoration(
                      color: isPast ? Colors.white10 : const Color(0xFFFFC107), // Amber
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: isPast ? [] : [
                        BoxShadow(color: const Color(0xFFFFC107).withOpacity(0.6), blurRadius: 8),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.prayerName,
                          style: TextStyle(
                            fontSize: 18,
                            color: isPast ? Colors.white30 : Colors.white,
                            fontFamily: 'Serif',
                            decoration: isPast ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${DateFormat('EEEE, MMM dd').format(p.dateTime)} at ${DateFormat('h:mm a').format(p.dateTime)}",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: Colors.redAccent.withOpacity(0.5), size: 20),
                    onPressed: () => _userService.deleteSpecialPrayer(p.id),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

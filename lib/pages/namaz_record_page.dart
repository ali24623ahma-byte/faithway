import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NamazRecordPage extends StatefulWidget {
  const NamazRecordPage({super.key});

  @override
  State<NamazRecordPage> createState() => _NamazRecordPageState();
}

class _NamazRecordPageState extends State<NamazRecordPage> {
  DateTime selectedDate = DateTime.now();
  bool isSaved = false;
  bool isLoading = false;
  bool isRecordExist = false;
  String statusMessage = "";

  final String apiUrl =
      "https://buildshere.cc/Anishrah/ahmad.api/namaz_api.php";

  final String userToken = "USER_LOGIN_TOKEN";

  Map<String, bool> namaz = {
    "Fajr": false,
    "Zuhr": false,
    "Asr": false,
    "Maghrib": false,
    "Isha": false,
  };

  @override
  void initState() {
    super.initState();
    fetchNamazRecord();
  }

  // 🔹 DATE PICKER
  Future<void> pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
        isSaved = false;
        statusMessage = "";
      });
      fetchNamazRecord();
    }
  }

  // 🔹 FETCH RECORD
  Future<void> fetchNamazRecord() async {
    setState(() {
      isLoading = true;
      isRecordExist = false;
      statusMessage = "";
    });

    final date = selectedDate.toString().split(' ')[0];

    try {
      final response = await http.get(
        Uri.parse("$apiUrl?date=$date"),
        headers: {"Authorization": "Bearer $userToken"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          namaz["Fajr"] = data["fajr"] ?? false;
          namaz["Zuhr"] = data["zuhr"] ?? false;
          namaz["Asr"] = data["asr"] ?? false;
          namaz["Maghrib"] = data["maghrib"] ?? false;
          namaz["Isha"] = data["isha"] ?? false;
          isRecordExist = true;
        });
      } else {
        resetNamaz();
      }
    } catch (e) {
      resetNamaz();
    }

    setState(() => isLoading = false);
  }

  // 🔹 SAVE RECORD
  Future<void> saveNamazRecord() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $userToken",
        },
        body: jsonEncode(createBody()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          isSaved = true;
          isRecordExist = true;
          statusMessage = "Namaz record saved successfully";
        });
        clearStatusMessage();
      }
    } catch (_) {}

    setState(() => isLoading = false);
  }

  // 🔹 UPDATE RECORD
  Future<void> updateNamazRecord() async {
    setState(() => isLoading = true);

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $userToken",
        },
        body: jsonEncode(createBody()),
      );

      if (response.statusCode == 200) {
        setState(() {
          isSaved = true;
          statusMessage = "Namaz record updated successfully";
        });
        clearStatusMessage();
      }
    } catch (_) {}

    setState(() => isLoading = false);
  }

  // 🔹 HELPERS
  Map<String, dynamic> createBody() {
    return {
      "date": selectedDate.toString().split(' ')[0],
      "fajr": namaz["Fajr"],
      "zuhr": namaz["Zuhr"],
      "asr": namaz["Asr"],
      "maghrib": namaz["Maghrib"],
      "isha": namaz["Isha"],
    };
  }

  void resetNamaz() {
    namaz.updateAll((key, value) => false);
    isRecordExist = false;
    statusMessage = "";
  }

  void clearStatusMessage() {
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => statusMessage = "");
      }
    });
  }

  // 🔹 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Namaz Record",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.yellow.shade700,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Image.asset(
            "assets/mosque_background.png",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(color: Colors.black.withOpacity(0.5)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        "My Namaz Record",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (statusMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            statusMessage,
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),

                      ListTile(
                        tileColor: Colors.yellow.shade700.withOpacity(0.2),
                        title: Text(
                          selectedDate.toString().split(' ')[0],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: pickDate,
                      ),

                      const SizedBox(height: 16),

                      Column(
                        children: namaz.keys.map((name) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(name),
                                Row(
                                  children: [
                                    Radio<bool>(
                                      value: true,
                                      groupValue: namaz[name],
                                      activeColor: Colors.yellow.shade700,
                                      onChanged: (_) =>
                                          setState(() => namaz[name] = true),
                                    ),
                                    const Text("Yes"),
                                    Radio<bool>(
                                      value: false,
                                      groupValue: namaz[name],
                                      activeColor: Colors.yellow.shade700,
                                      onChanged: (_) =>
                                          setState(() => namaz[name] = false),
                                    ),
                                    const Text("No"),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow.shade700,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: isLoading
                              ? null
                              : isRecordExist
                              ? updateNamazRecord
                              : saveNamazRecord,
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.black,
                                )
                              : Text(
                                  isRecordExist
                                      ? "Update Record"
                                      : "Save Record",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

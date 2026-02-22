import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TasbeehPage extends StatefulWidget {
  const TasbeehPage({super.key});

  @override
  State<TasbeehPage> createState() => _TasbeehPageState();
}

class _TasbeehPageState extends State<TasbeehPage> {
  final tasbeehNameController = TextEditingController();
  final timesController = TextEditingController();

  String selectedType = "Daily";
  bool isLoading = false;
  bool isFetching = true;

  List tasbeehList = [];

  @override
  void initState() {
    super.initState();
    fetchTasbeehs();
  }

  /// 🔹 FETCH FROM DB
  Future<void> fetchTasbeehs() async {
    try {
      final res = await http.get(
        Uri.parse("https://buildshere.cc/Anishrah/ahmad.api/get_tasbeeh.php"),
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        setState(() {
          tasbeehList = decoded["data"] ?? [];
          isFetching = false;
        });
      } else {
        setState(() => isFetching = false);
      }
    } catch (e) {
      setState(() => isFetching = false);
    }
  }

  /// 🔹 ADD TASBEEH
  Future<void> addTasbeeh() async {
    if (tasbeehNameController.text.isEmpty || timesController.text.isEmpty) {
      return;
    }

    setState(() => isLoading = true);

    await http.post(
      Uri.parse("https://buildshere.cc/Anishrah/ahmad.api/add_tasbeeh.php"),
      body: {
        "tasbeeh_name": tasbeehNameController.text,
        "total_count": timesController.text,
        "type": selectedType,
      },
    );

    tasbeehNameController.clear();
    timesController.clear();

    fetchTasbeehs();
    setState(() => isLoading = false);
  }

  /// 🔹 COUNT INCREMENT
  Future<void> incrementCount(String id) async {
    await http.post(
      Uri.parse("https://buildshere.cc/Anishrah/ahmad.api/update_count.php"),
      body: {"id": id},
    );

    fetchTasbeehs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade700,
        title: const Text("Tasbeeh", style: TextStyle(color: Colors.black)),
      ),
      body: Stack(
        children: [
          // 🔹 Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/mosque_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // 🔹 Dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),

          // 🔹 Main Content
          Column(
            children: [
              /// 🔶 FORM
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.yellow.shade700, width: 2),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: tasbeehNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Tasbeeh Name",
                        labelStyle: TextStyle(color: Colors.yellow.shade700),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: timesController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Total Count",
                        labelStyle: TextStyle(color: Colors.yellow.shade700),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio(
                          value: "Daily",
                          groupValue: selectedType,
                          activeColor: Colors.yellow.shade700,
                          onChanged: (v) => setState(() => selectedType = v!),
                        ),
                        const Text(
                          "Daily",
                          style: TextStyle(color: Colors.white),
                        ),
                        Radio(
                          value: "Monthly",
                          groupValue: selectedType,
                          activeColor: Colors.yellow.shade700,
                          onChanged: (v) => setState(() => selectedType = v!),
                        ),
                        const Text(
                          "Monthly",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow.shade700,
                        ),
                        onPressed: addTasbeeh,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : const Text(
                                "Submit",
                                style: TextStyle(color: Colors.black),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              /// 🔶 LIST
              Expanded(
                child: isFetching
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.yellow.shade700,
                        ),
                      )
                    : tasbeehList.isEmpty
                    ? const Center(
                        child: Text(
                          "No Tasbeeh Found",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: tasbeehList.length,
                        itemBuilder: (context, index) {
                          final t = tasbeehList[index];
                          int total = int.parse(t["total_count"]);
                          int current = int.parse(t["current_count"]);

                          return Card(
                            color: Colors.grey[850],
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              title: Text(
                                t["tasbeeh_name"],
                                style: TextStyle(color: Colors.yellow.shade700),
                              ),
                              subtitle: Text(
                                "Count: $current / $total | ${t["type"]}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.yellow.shade700,
                                ),
                                onPressed: current >= total
                                    ? null
                                    : () => incrementCount(t["id"]),
                                child: const Text(
                                  "Count",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

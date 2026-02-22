import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Added
import '../services/quran_api.dart';

class SurahDetailPage extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahDetailPage({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  final ScrollController _scrollController = ScrollController();

  Timer? _autoScrollTimer;
  bool isAutoScrollOn = false;
  double scrollSpeed = 1.0;

  List arabicAyahs = [];
  List urduAyahs = [];

  @override
  void initState() {
    super.initState();
    saveLastRead(); // ✅ Save last read Surah when page opens
    fetchAyahs();
  }

  // 🔹 SAVE LAST READ
  Future<void> saveLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastSurahNumber', widget.surahNumber);
    await prefs.setString('lastSurahName', widget.surahName);
  }

  // 🔹 FETCH AYAH DATA
  Future<void> fetchAyahs() async {
    final arabic = await QuranApi.getAyahs(widget.surahNumber);
    final urdu = await QuranApi.getUrduTranslation(widget.surahNumber);

    setState(() {
      arabicAyahs = arabic;
      urduAyahs = urdu;
    });
  }

  // ---------------- AUTO SCROLL ----------------
  void startAutoScroll() {
    if (isAutoScrollOn) return;
    isAutoScrollOn = true;

    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.offset + scrollSpeed);
      }
    });
    setState(() {});
  }

  void stopAutoScroll() {
    isAutoScrollOn = false;
    _autoScrollTimer?.cancel();
    setState(() {});
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surahName),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: Stack(
        children: [
          // 🌙 Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/mosque_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Slight overlay
          Container(color: Colors.black.withOpacity(0.55)),

          arabicAyahs.isEmpty || urduAyahs.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: arabicAyahs.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.yellow.shade700,
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // 🔸 Arabic Ayah
                          Text(
                            arabicAyahs[index]['text'],
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 🔸 Urdu Translation
                          Text(
                            urduAyahs[index]['text'],
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

          // 🎚 Auto Scroll + Slider
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow.shade700,
                  ),
                  icon: Icon(
                    isAutoScrollOn ? Icons.pause : Icons.play_arrow,
                    color: Colors.black,
                  ),
                  label: Text(
                    isAutoScrollOn ? 'Stop Auto Scroll' : 'Auto Scroll',
                    style: const TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    isAutoScrollOn ? stopAutoScroll() : startAutoScroll();
                  },
                ),
                Row(
                  children: [
                    const Icon(Icons.slow_motion_video, color: Colors.white),
                    Expanded(
                      child: Slider(
                        min: 0.5,
                        max: 5,
                        value: scrollSpeed,
                        activeColor: Colors.yellow.shade700,
                        inactiveColor: Colors.white38,
                        onChanged: (v) {
                          setState(() => scrollSpeed = v);
                        },
                      ),
                    ),
                    const Icon(Icons.fast_forward, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

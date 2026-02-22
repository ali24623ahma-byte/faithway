import 'package:flutter/material.dart';

class AyatUlKursi extends StatelessWidget {
  const AyatUlKursi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ayatul Kursi",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellow.shade700,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Stack(
        children: [
          // 🌙 MOSQUE BACKGROUND
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/mosque_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🌙 DARK OVERLAY
          Container(color: Colors.black.withOpacity(0.65)),

          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 🔸 ARABIC AYAT BOX
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.yellow.shade700,
                      width: 1.2,
                    ),
                  ),
                  child: const Text(
                    "اللّٰهُ لَاۤ اِلٰهَ اِلَّا هُوَ ۚ الْحَيُّ الْقَيُّوْمُ ۚ\n"
                    "لَا تَاْخُذُهٗ سِنَةٌ وَّلَا نَوْمٌ ۚ\n"
                    "لَهٗ مَا فِي السَّمٰوٰتِ وَمَا فِي الْاَرْضِ ۗ\n"
                    "مَنْ ذَا الَّذِيْ يَشْفَعُ عِنْدَهٗ اِلَّا بِاِذْنِهٖ ۚ\n"
                    "يَعْلَمُ مَا بَيْنَ اَيْدِيْهِمْ وَمَا خَلْفَهُمْ ۚ\n"
                    "وَلَا يُحِيْطُوْنَ بِشَيْءٍ مِّنْ عِلْمِهٖ اِلَّا بِمَا شَآءَ ۚ\n"
                    "وَسِعَ كُرْسِيُّهُ السَّمٰوٰتِ وَالْاَرْضَ ۚ\n"
                    "وَلَا يَـُٔوْدُهٗ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيْمُ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      height: 1.9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔸 URDU TRANSLATION BOX
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "اللہ وہ ہے جس کے سوا کوئی معبود نہیں، "
                    "وہ زندہ ہے، سب کو قائم رکھنے والا ہے۔ "
                    "اسے نہ اونگھ آتی ہے نہ نیند۔ "
                    "آسمانوں اور زمین میں جو کچھ ہے سب اسی کا ہے۔ "
                    "کون ہے جو اس کی اجازت کے بغیر اس کے حضور سفارش کر سکے؟ "
                    "وہ جانتا ہے جو ان کے سامنے ہے اور جو ان کے پیچھے ہے۔ "
                    "اور وہ اس کے علم میں سے کسی چیز کا احاطہ نہیں کر سکتے "
                    "مگر جتنا وہ چاہے۔ "
                    "اس کی کرسی آسمانوں اور زمین پر حاوی ہے، "
                    "اور ان کی حفاظت اسے تھکاتی نہیں۔ "
                    "اور وہی بلند مرتبہ، عظمت والا ہے۔",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

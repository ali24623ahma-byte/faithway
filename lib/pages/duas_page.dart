import 'package:flutter/material.dart';

class DuasPage extends StatelessWidget {
  const DuasPage({super.key});

  final List<Map<String, String>> duas = const [
    {"name": "کھانے سے پہلے", "arabic": "بسم الله", "urdu": "اللہ کے نام سے"},
    {
      "name": "کھانے کے بعد",
      "arabic": "الحمد لله الذي أطعمنا هذا ورزقنيه من غير حول مني ولا قوة",
      "urdu": "شکریہ اللہ کا جس نے ہمیں کھلایا اور دیا، میری کوئی طاقت نہیں",
    },
    {
      "name": "دودھ پینے سے پہلے",
      "arabic": "اللهم بارك لنا فيه وزدنا منه",
      "urdu": "اے اللہ! اس میں برکت دے اور ہمیں مزید عطا فرما",
    },
    {"name": "دودھ پینے کے بعد", "arabic": "الحمد لله", "urdu": "اللہ کا شکر"},
    {
      "name": "سونے سے پہلے",
      "arabic": "باسمك اللهم أموت وأحيا",
      "urdu": "اللہ کے نام سے، میں مر اور جِیو",
    },
    {
      "name": "اٹھنے کے بعد",
      "arabic": "الحمد لله الذي أحيانا بعد ما أماتنا وإليه النشور",
      "urdu":
          "شکریہ اللہ کا جس نے ہمیں مرنے کے بعد زندہ کیا، اور ہم سب اسی کی طرف لوٹیں گے",
    },
    {
      "name": "بیت الخلا جاتے وقت",
      "arabic": "بسم الله، اللهم إني أعوذ بك من الخبث والخبائث",
      "urdu": "اللہ کے نام سے، شیطانی اور گندی چیزوں سے پناہ مانگتا ہوں",
    },
    {
      "name": "بیت الخلا سے واپس آتے وقت",
      "arabic": "غفرانك",
      "urdu": "مجھے معاف فرما",
    },
    {
      "name": "سفر کے وقت",
      "arabic":
          "سبحان الذي سخر لنا هذا وما كنا له مقرنين وإنا إلى ربنا لمنقلبون",
      "urdu":
          "جو چیز ہمارے لیے آسان کی، اس کے لیے شکریہ اللہ، اور ہم ہمیشہ اپنے رب کی طرف لوٹیں گے",
    },
    {
      "name": "مسجد میں جاتے وقت",
      "arabic": "اللهم افتح لي أبواب رحمتك",
      "urdu": "اے اللہ! اپنے رحمت کے دروازے میرے لیے کھول",
    },
    {
      "name": "مسجد سے نکلتے وقت",
      "arabic": "اللهم إني أسألك من فضلك",
      "urdu": "اے اللہ! اپنی فضل عطا فرما",
    },
    {
      "name": "روزہ رکھتے وقت (سحری/نیت)",
      "arabic": "وبصوم غدٍ نويت من شهر رمضان",
      "urdu": "کل رمضان کے روزے رکھنے کا ارادہ کیا",
    },
    {
      "name": "روزہ کھولتے وقت (افطار)",
      "arabic": "اللهم إني لك صمت وبك آمنت وعليك توكلت وعلى رزقك أفطرت",
      "urdu":
          "اے اللہ! تیرے لیے روزہ رکھا، تجھ پر ایمان لایا، تجھ پر توکل کیا اور تیرے رزق سے افطار کیا",
    },
    {
      "name": "کام شروع کرنے سے پہلے",
      "arabic": "بسم الله",
      "urdu": "اللہ کے نام سے",
    },
    {
      "name": "مشکل وقت / دکھ-سکھ میں",
      "arabic": "حسبي الله لا إله إلا هو",
      "urdu": "اللہ ہی کافی ہے، اس کے سوا کوئی معبود نہیں",
    },
    {
      "name": "دکھ-سکھ میں",
      "arabic": "ربي إني مسني الضر وأنت أرحم الراحمين",
      "urdu": "میرے ساتھ دکھ آیا، اور تو سب سے مہربان ہے",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Masnoon Duas",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellow.shade700,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/mosque_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.6),
          padding: const EdgeInsets.all(12),
          child: ListView.builder(
            itemCount: duas.length,
            itemBuilder: (context, index) {
              final dua = duas[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.yellow.shade700, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // <-- change yahan
                  children: [
                    // Urdu Name
                    Text(
                      dua["name"]!,
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center, // <-- center align
                    ),
                    const SizedBox(height: 8),
                    // Arabic Dua
                    Text(
                      dua["arabic"]!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center, // <-- center align
                    ),
                    const SizedBox(height: 8),
                    // Urdu Tarjuma
                    Text(
                      dua["urdu"]!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center, // <-- center align
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

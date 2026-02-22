import 'package:flutter/material.dart';


class KalmasPage extends StatelessWidget {
  const KalmasPage({super.key});

  final List<Map<String, String>> kalmas = const [
    {
      "title": "پہلا کلمہ: کلمہ طیبہ",
      "arabic": "لَا إِلٰهَ إِلَّا اللّٰهُ مُحَمَّدٌ رَسُوْلُ اللّٰهِ",
      "urdu": "اللہ کے سوا کوئی معبود نہیں، محمد ﷺ اللہ کے رسول ہیں۔",
    },
    {
      "title": "دوسرا کلمہ: کلمہ شہادت",
      "arabic":
          "أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا اللّٰهُ وَحْدَهُ لَا شَرِيْكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُوْلُهُ",
      "urdu":
          "میں گواہی دیتا ہوں کہ اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے، اس کا کوئی شریک نہیں، اور میں گواہی دیتا ہوں کہ محمد ﷺ اس کے بندے اور رسول ہیں۔",
    },
    {
      "title": "تیسرا کلمہ: کلمہ تمجید",
      "arabic":
          "سُبْحَانَ اللّٰهِ وَالْحَمْدُ لِلّٰهِ وَلَا إِلٰهَ إِلَّا اللّٰهُ وَاللّٰهُ أَكْبَرُ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللّٰهِ الْعَلِيِّ الْعَظِيمِ",
      "urdu":
          "اللہ پاک ہے، اور تمام تعریفیں اللہ ہی کے لیے ہیں، اور اللہ کے سوا کوئی معبود نہیں، اور اللہ سب سے بڑا ہے، اور گناہ سے بچنے اور نیکی کی طاقت نہیں مگر اللہ بلند و عظیم کی مدد سے۔",
    },
    {
      "title": "چوتھا کلمہ: کلمہ توحید",
      "arabic":
          "لَا إِلٰهَ إِلَّا اللّٰهُ وَحْدَهُ لَا شَرِيْكَ لَهُ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ يُحْيِيْ وَيُمِيْتُ وَهُوَ حَيٌّ لَا يَمُوْتُ أَبَدًا أَبَدًا ذُو الْجَلَالِ وَالْإِكْرَامِ بِيَدِهِ الْخَيْرُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ",
      "urdu":
          "اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے، اس کا کوئی شریک نہیں، بادشاہی اسی کی ہے اور تعریف بھی اسی کے لیے ہے، وہی زندہ کرتا ہے اور وہی مارتا ہے، اور وہ خود زندہ ہے، اسے کبھی موت نہیں آئے گی، وہ بزرگی اور عزت والا ہے، ہر بھلائی اسی کے ہاتھ میں ہے، اور وہ ہر چیز پر پوری قدرت رکھتا ہے۔",
    },
    {
      "title": "پانچواں کلمہ: کلمہ استغفار",
      "arabic":
          "أَسْتَغْفِرُ اللّٰهَ رَبِّيْ مِنْ كُلِّ ذَنْبٍ أَذْنَبْتُهُ عَمَدًا أَوْ خَطَأً سِرًّا أَوْ عَلَانِيَةً وَأَتُوْبُ إِلَيْهِ مِنَ الذَّنْبِ الَّذِيْ أَعْلَمُ وَمِنَ الذَّنْبِ الَّذِيْ لَا أَعْلَمُ إِنَّكَ أَنْتَ عَلَّامُ الْغُيُوْبِ وَسَتَّارُ الْعُيُوْبِ وَغَفَّارُ الذُّنُوْبِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللّٰهِ الْعَلِيِّ الْعَظِيمِ",
      "urdu":
          "میں اللہ سے، جو میرا رب ہے، ہر اس گناہ کی معافی مانگتا ہوں جو میں نے جان بوجھ کر یا غلطی سے، چھپ کر یا کھلے عام کیا، اور میں اس گناہ سے بھی توبہ کرتا ہوں جسے میں جانتا ہوں اور جسے نہیں جانتا، بے شک تو ہی غیبوں کو جاننے والا، عیبوں کو چھپانے والا اور گناہوں کو بخشنے والا ہے، اور گناہ سے بچنے اور نیکی کی طاقت نہیں مگر اللہ بلند و عظیم کی مدد سے۔",
    },
    {
      "title": "چھٹا کلمہ: کلمہ ردِّ کفر",
      "arabic":
          "اَللّٰهُمَّ إِنِّيْ أَعُوْذُ بِكَ مِنْ أَنْ أُشْرِكَ بِكَ شَيْئًا وَأَنَا أَعْلَمُ بِهِ وَأَسْتَغْفِرُكَ لِمَا لَا أَعْلَمُ بِهِ تُبْتُ عَنْهُ وَتَبَرَّأْتُ مِنَ الْكُفْرِ وَالشِّرْكِ وَالْكِذْبِ وَالْغِيْبَةِ وَالْبِدْعَةِ وَالنَّمِيْمَةِ وَالْفَوَاحِشِ وَالْبُهْتَانِ وَالْمَعَاصِي كُلِّهَا وَأَسْلَمْتُ وَأَقُوْلُ لَا إِلٰهَ إِلَّا اللّٰهُ مُحَمَّدٌ رَسُوْلُ اللّٰهِ",
      "urdu":
          "اے اللہ! میں تیری پناہ مانگتا ہوں اس بات سے کہ میں جان بوجھ کر کسی کو تیرا شریک ٹھہراؤں، اور میں تجھ سے اس شرک کی معافی مانگتا ہوں جسے میں نہیں جانتا، میں نے اس سے توبہ کی اور کفر، شرک، جھوٹ، غیبت، بدعت، چغلی، بے حیائی، بہتان اور تمام گناہوں سے بیزاری اختیار کی، میں اسلام لایا اور کہتا ہوں کہ اللہ کے سوا کوئی معبود نہیں، محمد ﷺ اللہ کے رسول ہیں۔",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "6 Kalmas",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellow.shade700,
        centerTitle: true,
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
            itemCount: kalmas.length,
            itemBuilder: (context, index) {
              final kalma = kalmas[index];
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      kalma["title"]!,
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      kalma["arabic"]!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "ترجمہ:",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      kalma["urdu"]!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
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

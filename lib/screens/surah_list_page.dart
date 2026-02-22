import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/quran_api.dart';
import '../pages/quran_reader_page.dart';

class SurahListPage extends StatefulWidget {
  const SurahListPage({super.key});

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  int? lastSurahNumber;
  String? lastSurahName;

  @override
  void initState() {
    super.initState();
    loadLastRead();
  }

  Future<void> loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lastSurahNumber = prefs.getInt('lastSurahNumber');
      lastSurahName = prefs.getString('lastSurahName');
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Quran',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.yellow.shade700,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {
                showSearch(context: context, delegate: SurahSearchDelegate());
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            // mosque background
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/mosque_background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // dark overlay
            Container(color: Colors.black.withOpacity(0.65)),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // LAST READ CARD
                    GestureDetector(
                      onTap: lastSurahNumber == null
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuranReaderPage(
                                    type: QuranReadType.surah,
                                    number: lastSurahNumber!,
                                    title: lastSurahName!,
                                  ),
                                ),
                              );
                            },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade700,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Last Read',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    lastSurahName != null
                                        ? 'Surah\n$lastSurahName'
                                        : 'No Surah Read Yet',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Image.asset('assets/quran.png', height: 80),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // TABS
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const TabBar(
                        indicatorColor: Colors.yellow,
                        labelColor: Colors.yellow,
                        unselectedLabelColor: Colors.white,
                        tabs: [
                          Tab(text: 'Surah'),
                          Tab(text: 'Para'),
                          Tab(text: 'Page'),
                          Tab(text: 'Hizb'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // TAB CONTENT
                    Expanded(
                      child: TabBarView(
                        children: [
                          surahList(),
                          paraList(),
                          pageList(),
                          hizbList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- CARD DESIGN FUNCTION ----------------
  Widget cardItem({
    required String leading,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Text(
          leading,
          style: TextStyle(
            color: Colors.yellow.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.yellow.shade700),
        ),
        trailing: Icon(Icons.play_arrow, color: Colors.yellow.shade700),
        onTap: onTap,
      ),
    );
  }

  // ---------------- SURAH LIST ----------------
  Widget surahList() {
    return FutureBuilder<List>(
      future: QuranApi.getSurahs(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.yellow),
          );
        }

        final surahs = snapshot.data!;
        return ListView.builder(
          itemCount: surahs.length,
          itemBuilder: (context, index) {
            final surah = surahs[index];
            return cardItem(
              leading: surah['number'].toString(),
              title: surah['englishName'],
              subtitle: surah['name'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuranReaderPage(
                      type: QuranReadType.surah,
                      number: surah['number'],
                      title: surah['englishName'],
                    ),
                  ),
                ).then((_) => loadLastRead());
              },
            );
          },
        );
      },
    );
  }

  // ---------------- PARA LIST ----------------
  Widget paraList() {
    final paraArabic = [
      'الم',
      'سيقول',
      'تلك الرسل',
      'لن تنالوا',
      'والمحصنات',
      'لا يحب الله',
      'وإذا سمعوا',
      'ولو أننا',
      'قال الملأ',
      'واعلموا',
      'يعتذرون',
      'وما من دابة',
      'وما أبرئ',
      'ربما',
      'سبحان الذي',
      'قال ألم',
      'اقترب',
      'قد أفلح',
      'وقال الذين',
      'أمن خلق',
      'اتل ما أوحي',
      'ومن يقنت',
      'ومالي',
      'فمن أظلم',
      'إليه يرد',
      'حم',
      'قال فما خطبكم',
      'قد سمع الله',
      'تبارك الذي',
      'عم يتساءلون',
    ];

    final paraEnglish = [
      'Alif Laam Meem',
      'Sayaqool',
      'Tilkal Rusul',
      'Lan Tana Loo',
      'Wal Mohsanat',
      'La Yuhibbullah',
      'Wa Iza Samiu',
      'Wa Lau Annana',
      'Qalal Malao',
      'Wa A’lamu',
      'Yatazeroon',
      'Wa Ma Min Da’abat',
      'Wa Ma Ubrioo',
      'Rubama',
      'Subhanallazi',
      'Qal Alam',
      'Aqtarabo',
      'Qadd Aflaha',
      'Wa Qalallazina',
      'A’man Khalaq',
      'Utl Ma Oohi',
      'Wa Man Yaqnut',
      'Wa Mali',
      'Faman Azlam',
      'Elahe Yuruddo',
      'Ha’a Meem',
      'Qala Fama Khatbukum',
      'Qadd Sami Allah',
      'Tabarakallazi',
      'Amma Yatasa’aloon',
    ];

    return ListView.builder(
      itemCount: 30,
      itemBuilder: (context, index) {
        final paraNo = index + 1;
        return cardItem(
          leading: paraNo.toString(),
          title: paraArabic[index],
          subtitle: paraEnglish[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuranReaderPage(
                  type: QuranReadType.para,
                  number: paraNo,
                  title: 'Para $paraNo • ${paraEnglish[index]}',
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------- PAGE GRID ----------------
  Widget pageList() {
    return ListView.builder(
      itemCount: 604,
      itemBuilder: (context, index) {
        final pageNo = index + 1;
        return cardItem(
          leading: 'P$pageNo',
          title: 'Page P$pageNo',
          subtitle: 'Click to read page $pageNo',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuranReaderPage(
                  type: QuranReadType.page,
                  number: pageNo,
                  title: 'Page P$pageNo',
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------- HIZB GRID ----------------
  Widget hizbList() {
    return ListView.builder(
      itemCount: 60,
      itemBuilder: (context, index) {
        final hizbNo = index + 1;
        return cardItem(
          leading: 'H $hizbNo',
          title: 'Hizb H$hizbNo',
          subtitle: 'Click to read Hizb $hizbNo',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuranReaderPage(
                  type: QuranReadType.hizb,
                  number: hizbNo,
                  title: 'Hizb H$hizbNo',
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------- SEARCH ----------------
class SurahSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => 'Search Surah';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List>(
      future: QuranApi.getSurahs(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data!
            .where(
              (s) =>
                  s['englishName'].toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  s['name'].contains(query),
            )
            .toList();

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final surah = results[index];
            return ListTile(
              title: Text(surah['englishName']),
              subtitle: Text(surah['name']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuranReaderPage(
                      type: QuranReadType.surah,
                      number: surah['number'],
                      title: surah['englishName'],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(child: Text('Type Surah name'));
  }
}

import '../models/search_item.dart';

// pages import
import '../pages/duas_page.dart';
import '../pages/hadith_page.dart';
import '../pages/tasbeeh_page.dart';
import '../pages/qibla_page.dart';
import '../pages/prayer_timing_page.dart';
import '../pages/ayat_ul_kursi.dart';
import '../pages/kalmas_page.dart';
import '../pages/namaz_record_page.dart';
import '../pages/name_of_allah.dart';
import '../pages/name_of_muhammad.dart';
import '../screens/surah_list_page.dart';

List<SearchItem> searchItems() => [
  SearchItem(
    title: "Quran",
    keywords: ["quran", "surah", "ayat", "para", "juz"],
    page: const SurahListPage(),
  ),

  SearchItem(
    title: "Hadith",
    keywords: ["hadith", "hadees", "sunnah"],
    page: const HadithPage(),
  ),

  SearchItem(
    title: "Duas",
    keywords: ["dua", "masnoon", "prayer"],
    page: const DuasPage(),
  ),

  SearchItem(
    title: "Prayer Times",
    keywords: ["namaz", "fajr", "zuhr", "asr", "maghrib", "isha"],
    page: const PrayerTimingPage(),
  ),

  SearchItem(
    title: "Qibla Finder",
    keywords: ["qibla", "direction", "kaaba"],
    page: QiblaPage(),
  ),

  SearchItem(
    title: "Tasbeeh",
    keywords: ["tasbeeh", "zikr", "counter"],
    page: const TasbeehPage(),
  ),

  SearchItem(
    title: "Names of Allah",
    keywords: ["allah", "99 names", "asma ul husna"],
    page: const NameOfAllah(),
  ),

  SearchItem(
    title: "Names of Muhammad ﷺ",
    keywords: ["muhammad", "prophet", "rasool"],
    page: const NameOfMuhammad(),
  ),

  SearchItem(
    title: "Ayat ul Kursi",
    keywords: ["ayat", "kursi", "protection"],
    page: const AyatUlKursi(),
  ),

  SearchItem(
    title: "Kalmas",
    keywords: [
      "kalma",
      "1st kalma",
      "2nd kalma",
      "3rd kalma",
      "4th kalma",
      "5th kalma",
      "6th kalma",
    ],
    page: const KalmasPage(),
  ),

  SearchItem(
    title: "Namaz Record",
    keywords: ["record", "attendance", "namaz record"],
    page: const NamazRecordPage(),
  ),
];

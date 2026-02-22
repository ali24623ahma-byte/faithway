import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

class QuranApi {
  static const String baseUrl = 'https://api.alquran.cloud/v1';
  static const String boxName = 'quranCache';

  // ---------------- Hive Initialization ----------------
  static Future<void> initHive() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  // ---------------- Get all Surahs ----------------
  static Future<List> getSurahs() async {
    final box = Hive.box(boxName);

    if (box.containsKey('surahs')) {
      return box.get('surahs');
    }

    final response = await http.get(Uri.parse('$baseUrl/surah'));
    final data = jsonDecode(response.body)['data'];

    await box.put('surahs', data);
    return data;
  }

  // ---------------- Get Ayahs (Surah) ----------------
  static Future<List> getAyahs(int surahNumber) async {
    final box = Hive.box(boxName);
    final key = 'ayahs_$surahNumber';

    if (box.containsKey(key)) {
      return box.get(key);
    }

    final response = await http.get(Uri.parse('$baseUrl/surah/$surahNumber'));
    final data = jsonDecode(response.body)['data']['ayahs'];

    await box.put(key, data);
    return data;
  }

  // ---------------- English Translation ----------------
  static Future<List> getTranslation(int surahNumber) async {
    final box = Hive.box(boxName);
    final key = 'en_$surahNumber';

    if (box.containsKey(key)) {
      return box.get(key);
    }

    final response = await http.get(
      Uri.parse('$baseUrl/surah/$surahNumber/en.asad'),
    );
    final data = jsonDecode(response.body)['data']['ayahs'];

    await box.put(key, data);
    return data;
  }

  // ---------------- Urdu Translation ----------------
  static Future<List> getUrduTranslation(int surahNumber) async {
    final box = Hive.box(boxName);
    final key = 'ur_$surahNumber';

    if (box.containsKey(key)) {
      return box.get(key);
    }

    final response = await http.get(
      Uri.parse('$baseUrl/surah/$surahNumber/ur.junagarhi'),
    );
    final data = jsonDecode(response.body)['data']['ayahs'];

    await box.put(key, data);
    return data;
  }

  // ====================================================
  // =============== NEW ADDITIONS ======================
  // ====================================================

  // ---------------- Page Wise Quran ----------------
  static Future<List> getPage(int pageNumber) async {
    final box = Hive.box(boxName);
    final key = 'page_$pageNumber';

    if (box.containsKey(key)) {
      return box.get(key);
    }

    final response = await http.get(
      Uri.parse('$baseUrl/page/$pageNumber/quran-uthmani'),
    );
    final data = jsonDecode(response.body)['data']['ayahs'];

    await box.put(key, data);
    return data;
  }

  // ---------------- Para / Juz Wise Quran ----------------
  static Future<List> getPara(int paraNumber) async {
    final box = Hive.box(boxName);
    final key = 'para_$paraNumber';

    if (box.containsKey(key)) {
      return box.get(key);
    }

    final response = await http.get(
      Uri.parse('$baseUrl/juz/$paraNumber/quran-uthmani'),
    );
    final data = jsonDecode(response.body)['data']['ayahs'];

    await box.put(key, data);
    return data;
  }

  // ---------------- Hizb Wise Quran ----------------
  // NOTE: API hizbQuarter = 1–60 (exact match with your grid)
  static Future<List> getHizb(int hizbNumber) async {
    final box = Hive.box(boxName);
    final key = 'hizb_$hizbNumber';

    if (box.containsKey(key)) {
      return box.get(key);
    }

    final response = await http.get(
      Uri.parse('$baseUrl/hizbQuarter/$hizbNumber/quran-uthmani'),
    );
    final data = jsonDecode(response.body)['data']['ayahs'];

    await box.put(key, data);
    return data;
  }

  // ---------------- Urdu Translation for Para ----------------
  static Future<List> getParaUrdu(int paraNumber) async {
    final box = Hive.box(boxName);
    final key = 'para_ur_$paraNumber';

    if (box.containsKey(key)) {
      return box.get(key);
    }

    final response = await http.get(
      Uri.parse('$baseUrl/juz/$paraNumber/ur.junagarhi'),
    );
    final data = jsonDecode(response.body)['data']['ayahs'];

    await box.put(key, data);
    return data;
  }

  // ---------------- Urdu Translation for Page ----------------
  static Future<List> getPageUrdu(int pageNumber) async {
    final box = Hive.box(boxName);
    final key = 'page_ur_$pageNumber';

    if (box.containsKey(key)) {
      return box.get(key);
    }

    final response = await http.get(
      Uri.parse('$baseUrl/page/$pageNumber/ur.junagarhi'),
    );
    final data = jsonDecode(response.body)['data']['ayahs'];

    await box.put(key, data);
    return data;
  }

  // ---------------- Urdu Translation for Hizb ----------------
  static Future<List> getHizbUrdu(int hizbNumber) async {
    final box = Hive.box(boxName);
    final key = 'hizb_ur_$hizbNumber';

    if (box.containsKey(key)) {
      return box.get(key);
    }

    final response = await http.get(
      Uri.parse('$baseUrl/hizbQuarter/$hizbNumber/ur.junagarhi'),
    );
    final data = jsonDecode(response.body)['data']['ayahs'];

    await box.put(key, data);
    return data;
  }
}

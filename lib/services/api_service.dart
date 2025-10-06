import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah.dart';
import '../models/ayah.dart';

class ApiService {
  static const String baseUrl = 'https://equran.id/api/surat';

  /// 🔹 Ambil semua daftar surah
  Future<List<Surah>> getAllSurah() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Surah.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat daftar surah');
    }
  }

  /// 🔹 Ambil detail 1 surah (nama, arti, tempat turun, dll)
  Future<Surah> getSurahDetail(int nomor) async {
    final response = await http.get(Uri.parse('$baseUrl/$nomor'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Surah.fromJson(data);
    } else {
      throw Exception('Gagal memuat detail surah');
    }
  }

  /// 🔹 Ambil daftar ayat dari 1 surah
 Future<List<Ayah>> getAyat(int surahId) async {
  final response = await http.get(
    Uri.parse("https://api.quran.gading.dev/surah/$surahId"),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List ayat = data['data']['verses'];
    return ayat.map((e) => Ayah.fromJson({
      'nomorAyat': e['number']['inSurah'],
      'teksArab': e['text']['arab'],
      'teksLatin': e['text']['transliteration']['en'],
      'teksIndonesia': e['translation']['id'],
      'audioUrl': e['audio']['primary'],
    })).toList();
  } else {
    throw Exception("Gagal memuat ayat");
  }
}

}

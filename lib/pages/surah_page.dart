import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/ayah.dart';
import '../services/api_service.dart';
import '../models/surah.dart'; // Pastikan kamu punya model Surah

class SurahPage extends StatefulWidget {
  final int surahId;
  final String surahName;
  final String arti;

  const SurahPage({
    super.key,
    required this.surahId,
    required this.surahName,
    required this.arti,
  });

  @override
  State<SurahPage> createState() => _SurahPageState();
}

class _SurahPageState extends State<SurahPage> {
  late Future<List<Ayah>> ayatList;
  late Future<List<Surah>> semuaSurah;
  final player = AudioPlayer();

  int currentSurahId = 0;
  String currentSurahName = "";
  String currentArti = "";

  @override
  void initState() {
    super.initState();
    currentSurahId = widget.surahId;
    currentSurahName = widget.surahName;
    currentArti = widget.arti;
    ayatList = ApiService().getAyat(currentSurahId);
    semuaSurah = ApiService().getAllSurah(); // Panggil semua daftar surat
  }

  void loadSurah(int newId) async {
    final list = await semuaSurah;
    final surahBaru = list.firstWhere((s) => s.nomor == newId);
    setState(() {
      currentSurahId = surahBaru.nomor;
      currentSurahName = surahBaru.namaLatin;
      currentArti = surahBaru.arti;
      ayatList = ApiService().getAyat(surahBaru.nomor);
    });
  }

  void nextSurah() async {
    final list = await semuaSurah;
    int nextId = currentSurahId == 114 ? 1 : currentSurahId + 1;
    loadSurah(nextId);
  }

  void previousSurah() async {
    final list = await semuaSurah;
    int prevId = currentSurahId == 1 ? 114 : currentSurahId - 1;
    loadSurah(prevId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: previousSurah,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    currentSurahName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    "($currentArti)",
                    style: const TextStyle(
                        fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: nextSurah,
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),
      body: FutureBuilder<List<Ayah>>(
        future: ayatList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Gagal memuat ayat"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada ayat"));
          }

          final ayat = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: ayat.length,
            itemBuilder: (context, index) {
              final a = ayat[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${a.nomorAyat}.",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          a.teksArab,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(a.teksLatin,
                          style: const TextStyle(fontStyle: FontStyle.italic)),
                      const SizedBox(height: 4),
                      Text(a.teksIndonesia),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_circle_fill,
                                color: Colors.green),
                            onPressed: () => player.play(UrlSource(a.audioUrl)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

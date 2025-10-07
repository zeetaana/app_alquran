import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/ayah.dart';
import '../services/api_service.dart';
import '../models/surah.dart';

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
    semuaSurah = ApiService().getAllSurah();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 🌙 Dark mode gradient & color palette
    final darkBgGradient = LinearGradient(
      colors: [const Color(0xFF0A1A1F), const Color(0xFF1A2F32)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    // ☀️ Light mode gradient & color palette
    final lightBgGradient = LinearGradient(
      colors: [Colors.teal.shade50, Colors.white],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
   appBar: AppBar(
  backgroundColor: isDark ? Colors.teal.shade900 : Colors.teal.shade600,
  iconTheme: const IconThemeData(color: Colors.white), // <- ini penting!
  title: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: previousSurah,
      ),
      Expanded(
        child: Column(
          children: [
            Text(
              currentSurahName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Text(
              "($currentArti)",
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      IconButton(
        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onPressed: nextSurah,
      ),
    ],
  ),
  centerTitle: true,
),


      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? darkBgGradient : lightBgGradient,
        ),
        child: FutureBuilder<List<Ayah>>(
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
              padding: const EdgeInsets.all(16),
              itemCount: ayat.length,
              itemBuilder: (context, index) {
                final a = ayat[index];

                final cardColor = isDark
                    ? Colors.teal.shade800.withOpacity(0.4)
                    : Colors.white;
                final textColor =
                    isDark ? Colors.white70 : Colors.grey.shade900;
                final arabColor =
                    isDark ? Colors.teal.shade100 : Colors.teal.shade900;
                final latinColor =
                    isDark ? Colors.teal.shade200 : Colors.grey.shade700;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nomor ayat
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.teal.shade700.withOpacity(0.5)
                                : Colors.teal.shade100,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 12),
                          child: Text(
                            "${a.nomorAyat}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : Colors.teal.shade900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Teks Arab
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            a.teksArab,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 26,
                              color: arabColor,
                              fontFamily: 'Amiri',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Transliterasi Latin
                        Text(
                          a.teksLatin,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: latinColor,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Terjemahan
                        Text(
                          a.teksIndonesia,
                          style: TextStyle(
                            color: textColor,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Tombol Audio
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () => player.play(UrlSource(a.audioUrl)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.teal.shade900.withOpacity(0.5)
                                    : Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.teal.shade700
                                      : Colors.teal.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.play_circle_fill,
                                    color: isDark
                                        ? Colors.teal.shade300
                                        : Colors.teal.shade700,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Putar",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.teal.shade100
                                          : Colors.teal.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

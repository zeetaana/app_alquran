import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/ayah.dart';
import '../services/api_service.dart';

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
  final player = AudioPlayer();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    ayatList = ApiService().getAyat(widget.surahId);
  }

  void playAudio(String url) async {
    await player.stop();
    await player.play(UrlSource(url));
  }

  void goToSurah(int newId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SurahPage(
          surahId: newId,
          surahName: "Surah ${newId == 1 ? 'Al-Fatihah' : 'Al-Baqarah'}", // contoh
          arti: newId == 1 ? "Pembukaan" : "Sapi Betina",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Al Qur'an"),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),
      body: Column(
        children: [
          // Deskripsi singkat di atas
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                Text(
                  widget.surahName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "(${widget.arti})",
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.green),
                      onPressed: widget.surahId > 1
                          ? () => goToSurah(widget.surahId - 1)
                          : null,
                    ),
                    Text(
                      "Daftar Ayat",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.green),
                      onPressed: () => goToSurah(widget.surahId + 1),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Pencarian ayat
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari ayat...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),

          // Daftar ayat
          Expanded(
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

                final filteredAyat = snapshot.data!
                    .where((a) =>
                        a.teksArab.contains(searchQuery) ||
                        a.teksIndonesia.contains(searchQuery) ||
                        a.teksLatin.contains(searchQuery))
                    .toList();

                return ListView.builder(
                  itemCount: filteredAyat.length,
                  itemBuilder: (context, index) {
                    final ayat = filteredAyat[index];
                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "${ayat.nomorAyat}.",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ayat.teksArab,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 22,
                                fontFamily: 'Amiri',
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(ayat.teksLatin,
                                style: const TextStyle(
                                    fontStyle: FontStyle.italic, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(ayat.teksIndonesia),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.play_circle_fill,
                                    color: Colors.green, size: 30),
                                onPressed: () => playAudio(ayat.audioUrl),
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
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/surah.dart';
import '../pages/surah_page.dart';

class SurahTile extends StatelessWidget {
  final Surah surah;
  final bool isBookmarked;

  const SurahTile({
    super.key,
    required this.surah,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004D40), Color(0xFF00796B)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          surah.namaLatin,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        subtitle: Text(
          '(${surah.arti}) • ${surah.jumlahAyat} ayat',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isBookmarked)
              const Icon(Icons.bookmark, color: Colors.yellowAccent),
            const SizedBox(width: 10),
            Text(
              surah.nama,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
       onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
     builder: (_) => SurahPage(
  surahId: surah.nomor,
  surahName: surah.namaLatin,
  arti: surah.arti,
),

    ),
  );
},

      ),
    );
  }
}

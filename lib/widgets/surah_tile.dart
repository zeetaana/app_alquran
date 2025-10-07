import 'package:flutter/material.dart';
import '../models/surah.dart';
import '../pages/surah_page.dart';

class SurahTile extends StatelessWidget {
  final Surah surah;
  final bool isBookmarked;
  final VoidCallback onBookmarkPressed;

  const SurahTile({
    super.key,
    required this.surah,
    required this.isBookmarked,
    required this.onBookmarkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        surah.namaLatin,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('Arti: ${surah.arti}  |  Ayat: ${surah.jumlahAyat}'),
      trailing: IconButton(
        icon: Icon(
          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          color: isBookmarked ? Colors.green : Colors.grey,
        ),
        onPressed: onBookmarkPressed,
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
    );
  }
}

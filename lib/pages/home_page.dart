import 'package:flutter/material.dart';
import '../models/surah.dart';
import '../services/api_service.dart';
import 'surah_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Surah>> surahList;
  List<Surah> bookmarked = [];
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    surahList = ApiService().getAllSurah();
  }

  void toggleBookmark(Surah surah) {
    setState(() {
      if (bookmarked.contains(surah)) {
        bookmarked.remove(surah);
      } else {
        bookmarked.add(surah);
      }
    });
  }

  void confirmDelete(Surah surah) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Penanda"),
        content: const Text("Apakah Anda yakin ingin menghapus penanda ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                bookmarked.remove(surah);
              });
              Navigator.pop(context);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(primary: Colors.green.shade700),
      ),
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.light(primary: Colors.green.shade700),
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.green.shade700,
            title: const Column(
              children: [
                Text("Al-Qur'an", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Bacalah Al-Qur'an walaupun satu ayat",
                    style: TextStyle(fontSize: 12)),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () {
                  setState(() => isDarkMode = !isDarkMode);
                },
              ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(text: "Daftar Surat"),
                Tab(text: "Penanda"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // ======= TAB DAFTAR SURAT =======
              FutureBuilder<List<Surah>>(
                future: surahList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Gagal memuat surat"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Tidak ada surat"));
                  } else {
                    final surah = snapshot.data!;
                    return ListView.builder(
                      itemCount: surah.length,
                      itemBuilder: (context, index) {
                        final s = surah[index];
                        final isBookmarked = bookmarked.contains(s);
                        return ListTile(
                          title: Text(
                            s.namaLatin,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              "Arti: ${s.arti}  |  Ayat: ${s.jumlahAyat}"),
                          trailing: IconButton(
                            icon: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: Colors.green,
                            ),
                            onPressed: () => toggleBookmark(s),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SurahPage(
                                  surahId: s.nomor,
                                  surahName: s.namaLatin,
                                  arti: s.arti,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),

              // ======= TAB PENANDA =======
              bookmarked.isEmpty
                  ? const Center(child: Text("Belum ada penanda"))
                  : ListView.builder(
                      itemCount: bookmarked.length,
                      itemBuilder: (context, index) {
                        final s = bookmarked[index];
                        return ListTile(
                          title: Text(
                            s.namaLatin,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Arti: ${s.arti}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => confirmDelete(s),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SurahPage(
                                  surahId: s.nomor,
                                  surahName: s.namaLatin,
                                  arti: s.arti,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

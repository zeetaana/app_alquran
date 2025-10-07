import 'dart:async';
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
  List<Surah> allSurah = [];
  List<Surah> filteredSurah = [];
  List<Surah> bookmarked = [];
  bool isDarkMode = false;
  String currentTime = "";
  String query = "";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    surahList = ApiService().getAllSurah();
    _loadSurah();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  Future<void> _loadSurah() async {
    final data = await ApiService().getAllSurah();
    setState(() {
      allSurah = data;
      filteredSurah = allSurah;
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      currentTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

  void _filterSurah(String keyword) {
    setState(() {
      query = keyword;
      filteredSurah = allSurah
          .where((s) =>
              s.namaLatin.toLowerCase().contains(keyword.toLowerCase()) ||
              s.arti.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lightGradient = const LinearGradient(
      colors: [Color(0xFFF9F9F9), Color(0xFFE8F5E9)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final darkGradient = const LinearGradient(
      colors: [Color(0xFF121212), Color(0xFF1B1B1B)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: const ColorScheme.dark(primary: Colors.teal),
      ),
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: const ColorScheme.light(primary: Colors.teal),
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [Colors.teal.shade900, Colors.black]
                        : [Colors.teal.shade400, Colors.teal.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  children: [
                    Text(
                      currentTime,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text("Al-Qur'an",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 2),
                    const Text("Bacalah Al-Qur'an walaupun satu ayat",
                        style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() => isDarkMode = !isDarkMode);
                  },
                ),
              ],
              bottom: const TabBar(
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: "Daftar Surat"),
                  Tab(text: "Penanda"),
                ],
              ),
            ),
          ),

          // BODY
          body: Container(
            decoration: BoxDecoration(
              gradient: isDarkMode ? darkGradient : lightGradient,
            ),
            child: TabBarView(
              children: [
                // ======= TAB DAFTAR SURAT =======
                Column(
                  children: [
                    const SizedBox(height: 160), // 🔽 lebih ke bawah dari sebelumnya
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10),
                      child: TextField(
                        onChanged: _filterSurah,
                        decoration: InputDecoration(
                          hintText: 'Cari surat...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: isDarkMode
                              ? Colors.grey.shade800
                              : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<List<Surah>>(
                        future: surahList,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(
                                child: Text("Gagal memuat surat"));
                          } else if (filteredSurah.isEmpty) {
                            return const Center(
                                child: Text("Surat tidak ditemukan"));
                          } else {
                            return ListView.builder(
                              padding: const EdgeInsets.only(
                                  left: 12, right: 12, bottom: 12),
                              itemCount: filteredSurah.length,
                              itemBuilder: (context, index) {
                                final s = filteredSurah[index];
                                final isBookmarked = bookmarked.contains(s);
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  elevation: 3,
                                  color: isDarkMode
                                      ? Colors.grey.shade900.withOpacity(0.95)
                                      : Colors.white.withOpacity(0.98),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.teal.shade100,
                                      child: Text(
                                        "${s.nomor}",
                                        style: const TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(
                                      s.namaLatin,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "${s.arti} • ${s.jumlahAyat} ayat",
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        isBookmarked
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        color: Colors.teal,
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
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),

                // ======= TAB PENANDA =======
                bookmarked.isEmpty
                    ? const Center(child: Text("Belum ada penanda"))
                    : Padding(
                        padding: const EdgeInsets.only(top: 160),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: bookmarked.length,
                          itemBuilder: (context, index) {
                            final s = bookmarked[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              elevation: 3,
                              color: isDarkMode
                                  ? Colors.grey.shade900.withOpacity(0.95)
                                  : Colors.white.withOpacity(0.98),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                title: Text(
                                  s.namaLatin,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  s.arti,
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
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
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

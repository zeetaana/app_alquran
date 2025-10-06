import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/surah.dart';
import '../services/api_service.dart';
import 'surah_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  late Future<List<Surah>> surahList;
  List<Surah> bookmarks = [];
  late TabController _tabController;
  String currentTime = DateFormat('HH:mm').format(DateTime.now());
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    surahList = ApiService().getAllSurah();
    _tabController = TabController(length: 2, vsync: this);
    updateTime();
  }

  void updateTime() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        currentTime = DateFormat('HH:mm').format(DateTime.now());
      });
      updateTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text('Al Qur\'an',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: Column(
            children: [
              const Text(
                'Bacalah Al-Qur\'an walaupun satu ayat',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari surat...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => searchQuery = value.toLowerCase());
                  },
                ),
              ),
              const SizedBox(height: 10),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Daftar Surat'),
                  Tab(text: 'Penanda'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                currentTime,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildDaftarSurat(),
          buildPenanda(),
        ],
      ),
    );
  }

  Widget buildDaftarSurat() {
    return FutureBuilder<List<Surah>>(
      future: surahList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Gagal memuat data'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada data'));
        } else {
          final filtered = snapshot.data!
              .where((s) => s.namaLatin.toLowerCase().contains(searchQuery))
              .toList();

          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final surah = filtered[index];
              return ListTile(
                title: Text(surah.namaLatin),
                subtitle: Text('Surat ke-${surah.nomor}'),
                onLongPress: () {
                  if (!bookmarks.contains(surah)) {
                    setState(() => bookmarks.add(surah));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${surah.namaLatin} ditambahkan ke penanda')),
                    );
                  }
                },
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
            },
          );
        }
      },
    );
  }

  Widget buildPenanda() {
    return bookmarks.isEmpty
        ? const Center(child: Text('Belum ada penanda'))
        : ListView.builder(
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final surah = bookmarks[index];
              return ListTile(
                title: Text(surah.namaLatin),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Hapus Penanda'),
                        content: Text(
                            'Apakah anda ingin menghapus penanda ${surah.namaLatin}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() => bookmarks.remove(surah));
                              Navigator.pop(context);
                            },
                            child: const Text('Hapus',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
  }
}

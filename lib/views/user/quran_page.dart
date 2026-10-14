import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  // Fetch Surah List
  Future<List<dynamic>> _getDaftarSurat() async {
    final response = await http.get(Uri.parse("https://equran.id/api/v2/surat"));
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Gagal load surat');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE7F6), // Background Ungu Sangat Muda
      appBar: AppBar(
        title: const Text("Al-Qur'an Digital", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF673AB7), // Ungu Tua
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _getDaftarSurat(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)));
          }
          if (snapshot.hasError) {
             return Center(child: Text("Gagal memuat data: ${snapshot.error}"));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var surat = snapshot.data![index];
              return _buildSuratCard(context, surat);
            },
          );
        },
      ),
    );
  }

  // WIDGET KARTU SURAT (LIST ITEM)
  Widget _buildSuratCard(BuildContext context, dynamic surat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF673AB7).withOpacity(0.1), // Shadow ungu halus
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Pindah ke Halaman Detail
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => DetailSuratPage(
                nomorSurat: surat['nomor'], 
                namaSurat: surat['namaLatin'],
                artiSurat: surat['arti'],
              )
            ));
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                // 1. Badge Nomor Surat (Segi 8 / Belah Ketupat Style)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.star_outline_rounded, size: 50, color: const Color(0xFF673AB7).withOpacity(0.4)),
                    Text(
                      "${surat['nomor']}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF512DA8)),
                    ),
                  ],
                ),
                
                const SizedBox(width: 15),
                
                // 2. Info Surat
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surat['namaLatin'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF311B92)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDE7F6),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              surat['tempatTurun'].toString().toUpperCase(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF7E57C2)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${surat['jumlahAyat']} Ayat",
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // 3. Nama Arab
                Text(
                  surat['nama'], // Teks Arab Nama Surat
                  style: const TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: Color(0xFF673AB7),
                    fontFamily: 'Amiri' // Opsional jika punya font arab
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

// --- HALAMAN DETAIL SURAT (LIST AYAT) ---
class DetailSuratPage extends StatelessWidget {
  final int nomorSurat;
  final String namaSurat;
  final String artiSurat;

  const DetailSuratPage({
    super.key, 
    required this.nomorSurat, 
    required this.namaSurat,
    this.artiSurat = '',
  });

  Future<List<dynamic>> _getDetailSurat() async {
    final response = await http.get(Uri.parse("https://equran.id/api/v2/surat/$nomorSurat"));
    if (response.statusCode == 200) {
      return json.decode(response.body)['data']['ayat'];
    } else {
      throw Exception('Gagal load ayat');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Background abu sangat muda agar teks jelas
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Surat $namaSurat", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            Text(artiSurat, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF673AB7),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Basmalah (Kecuali At-Taubah / Surat 9)
          if (nomorSurat != 9)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.fromLTRB(15, 15, 15, 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF7E57C2), Color(0xFF5E35B1)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
              ),
              child: const Text(
                "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.5),
              ),
            ),

          // List Ayat
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _getDetailSurat(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)));
                }
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var ayat = snapshot.data![index];
                    return _buildAyatCard(ayat);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyatCard(dynamic ayat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Toolbar Ayat (Nomor & Action)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5F5).withOpacity(0.5), // Header ungu pudar
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF673AB7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${ayat['nomorAyat']}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.share_rounded, size: 20, color: Colors.grey[400]),
                    const SizedBox(width: 15),
                    Icon(Icons.bookmark_border_rounded, size: 20, color: Colors.grey[400]),
                  ],
                )
              ],
            ),
          ),

          // 2. Isi Ayat
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Teks Arab
                Text(
                  ayat['teksArab'],
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 26, 
                    fontWeight: FontWeight.bold, 
                    height: 2.2, // Spasi antar baris arab
                    fontFamily: 'Amiri', // Jika ada
                    color: Colors.black87
                  ),
                ),
                const SizedBox(height: 15),
                
                // Teks Latin
                Text(
                  ayat['teksLatin'],
                  style: const TextStyle(
                    color: Color(0xFF5E35B1), // Ungu teks
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                
                // Terjemahan Indonesia
                Text(
                  ayat['teksIndonesia'],
                  style: TextStyle(
                    fontSize: 14, 
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
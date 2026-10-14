import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// --- IMPORT FILE PAGE ---
import 'wudhu_page.dart';
import 'gerakan_sholat_page.dart';
import 'sholat_wajib_page.dart';
import 'quran_page.dart';
import 'profile_page.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  Map<String, dynamic>? _jadwalSholat;
  bool _isLoadingJadwal = true;

  // --- PALET WARNA TEMA ---
  final Color mainColor = const Color(0xFF4FB3FF); // Biru Langit
  final Color secondaryColor = const Color(0xFFFFD54F); // Kuning
  final Color softBg = const Color(0xFFF4F8FB); // Background putih kebiruan (lebih bersih)
  final Color textDark = const Color(0xFF1A237E); // Teks Biru Tua

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      _getJadwalSholat();
    });
  }

  Future<void> _getJadwalSholat() async {
    String cityId = "0228"; // Medan
    DateTime now = DateTime.now();
    String year = now.year.toString();
    String month = now.month.toString();
    String day = now.day.toString();
    String url = "https://api.myquran.com/v2/sholat/jadwal/$cityId/$year/$month/$day";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _jadwalSholat = data['data']['jadwal'];
            _isLoadingJadwal = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingJadwal = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String tanggalHariIni = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      backgroundColor: softBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER & JADWAL SHOLAT (STACK) ---
            SizedBox(
              height: 330, // Tinggi total area Header + Card Mengambang
              child: Stack(
                clipBehavior: Clip.none, 
                children: [
                  // 1. Background Biru
                  Container(
                    height: 260, // Tinggi background biru
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                      boxShadow: [
                          BoxShadow(color: mainColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))
                      ]
                    ),
                  ),

                  // 2. Hiasan Awan
                  Positioned(
                    top: -30,
                    right: -40,
                    child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.1)),
                  ),
                  Positioned(
                    top: 80,
                    left: -30,
                    child: CircleAvatar(radius: 50, backgroundColor: Colors.white.withOpacity(0.1)),
                  ),

                  // 3. Konten Header (Teks & Tombol Profil) - WRAPPED IN SAFEAREA
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea( // INI YANG DITAMBAHKAN
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10), // Padding disesuaikan
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Assalamualaikum,",
                                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  "Anak Sholeh!", 
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            // Tombol Profil
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.white,
                                  backgroundImage: AssetImage('assets/logo.jpg'), // Pastikan ada atau ganti Icon
                                  child: Icon(Icons.person, color: Colors.grey), // Fallback jika gambar gagal
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 4. Card Jadwal Sholat (Floating)
                  Positioned(
                    bottom: 0, // Tempel di bagian bawah Stack
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(35), // Lebih bulat
                        boxShadow: [
                          BoxShadow(color: const Color(0xFFCFD8DC).withOpacity(0.6), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                                    child: const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Text("Medan", style: TextStyle(fontWeight: FontWeight.w800, color: textDark, fontSize: 16)),
                                ],
                              ),
                              Text(tanggalHariIni, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                          ),
                          
                          // List Waktu Sholat
                          _isLoadingJadwal
                              ? Center(child: CircularProgressIndicator(color: mainColor))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _itemJadwal("Subuh", _jadwalSholat?['subuh'], "🌅"),
                                    _itemJadwal("Dzuhur", _jadwalSholat?['dzuhur'], "☀️"),
                                    _itemJadwal("Ashar", _jadwalSholat?['ashar'], "🌤️"),
                                    _itemJadwal("Maghrib", _jadwalSholat?['maghrib'], "🌇"),
                                    _itemJadwal("Isya", _jadwalSholat?['isya'], "🌙"),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- MENU UTAMA ---
            // Langsung padding, tanpa SizedBox besar agar tidak renggang
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 0), // Top 25px cukup
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Mau Belajar Apa?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textDark)),
                  const SizedBox(height: 15),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.1, // Rasio diatur agar kartu padat
                    children: [
                      _buildImageMenuCard(context, "Wudhu", "assets/logo_wudhu.png", const Color(0xFFE0F7FA), const WudhuPage()),
                      _buildImageMenuCard(context, "Gerakan", "assets/logo_gerakan.png", const Color(0xFFFFF3E0), const GerakanSholatPage()),
                      _buildImageMenuCard(context, "Sholat", "assets/logo_sholat.png", const Color(0xFFEDE7F6), const SholatWajibPage()),
                      _buildImageMenuCard(context, "Al-Qur'an", "assets/logo_alquran.png", const Color(0xFFE8F5E9), const QuranPage()),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- MUTIARA HIKMAH ---
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFFFF9C4), const Color(0xFFFFF176).withOpacity(0.5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.orange.withOpacity(0.2), width: 1),
                boxShadow: [
                  BoxShadow(color: Colors.orange.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.lightbulb_rounded, color: Colors.orange, size: 24),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Pesan Hari Ini",
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF5D4037)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "\"Sesungguhnya sholat itu mencegah dari perbuatan keji dan mungkar.\"",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFF5D4037).withOpacity(0.8),
                            height: 1.5,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
                            child: Text("QS. Al-'Ankabut: 45", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5D4037))),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER: JAM SHOLAT ---
  Widget _itemJadwal(String nama, String? jam, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)), 
        const SizedBox(height: 6),
        Text(nama, style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(
          jam ?? "-", 
          style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 14)
        ),
      ],
    );
  }

  // --- WIDGET HELPER: CARD MENU ---
  Widget _buildImageMenuCard(BuildContext context, String title, String imagePath, Color bgColor, Widget page) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
               BoxShadow(
                 color: const Color(0xFF90A4AE).withOpacity(0.15), 
                 blurRadius: 15, 
                 offset: const Offset(0, 8)
               ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LINGKARAN BACKGROUND GAMBAR
              Container(
                height: 85, // Diperbesar
                width: 85,  // Diperbesar
                padding: const EdgeInsets.all(20), // Padding besar agar gambar tidak "kejepit" (pas)
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle, // Pasti bulat
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain, // Memastikan gambar proporsional di dalam padding
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.image, color: Colors.grey[400]),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
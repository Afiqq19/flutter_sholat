import 'package:flutter/material.dart';
import 'sholat_steps_page.dart'; // Pastikan file ini ada

class SholatWajibPage extends StatelessWidget {
  const SholatWajibPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background Ungu Sangat Muda (Konsisten dengan tema, tapi bersih)
      backgroundColor: const Color(0xFFEDE7F6), 
      appBar: AppBar(
        // Judul berwarna Ungu Tua agar kontras dengan background terang
        title: const Text(
          "Pilih Sholat", 
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            color: Color(0xFF512DA8), 
            fontSize: 24
          )
        ),
        backgroundColor: Colors.transparent, // AppBar menyatu dengan background
        elevation: 0, // Hilangkan bayangan di bawah AppBar
        centerTitle: true,
        // Tombol Back berwarna Ungu Tua
        iconTheme: const IconThemeData(color: Color(0xFF512DA8)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          // Langsung Daftar Kartu Sholat
          _buildSholatCard(context, "Sholat Subuh", "2 Rakaat", "sholat_subuh", Icons.wb_twilight_rounded, const Color(0xFF42A5F5)), // Biru Pagi
          _buildSholatCard(context, "Sholat Dzuhur", "4 Rakaat", "sholat_dzuhur", Icons.wb_sunny_rounded, const Color(0xFFFFCA28)), // Kuning Siang
          _buildSholatCard(context, "Sholat Ashar", "4 Rakaat", "sholat_ashar", Icons.wb_cloudy_rounded, const Color(0xFFFFA726)), // Oranye Sore
          _buildSholatCard(context, "Sholat Maghrib", "3 Rakaat", "sholat_maghrib", Icons.nights_stay_rounded, const Color(0xFFEF5350)), // Merah Senja
          _buildSholatCard(context, "Sholat Isya", "4 Rakaat", "sholat_isya", Icons.bedtime_rounded, const Color(0xFF5C6BC0)), // Indigo Malam
        ],
      ),
    );
  }

  Widget _buildSholatCard(BuildContext context, String title, String subtitle, String categoryId, IconData icon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Sudut bulat
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB39DDB).withOpacity(0.15), // Shadow ungu tipis
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
            // Navigasi ke Halaman Detail Langkah Sholat
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SholatStepsPage(
                  categoryId: categoryId,
                  title: title,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Padding disesuaikan
            child: Row(
              children: [
                // 1. IKON DALAM KOTAK
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                
                const SizedBox(width: 20),
                
                // 2. TEKS JUDUL & RAKAAT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF4527A0), // Ungu Tua
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Badge Rakaat
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5F5), // Ungu pudar
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7E57C2), // Ungu sedang
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. PANAH BULAT KECIL
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
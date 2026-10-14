import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WudhuPage extends StatelessWidget {
  const WudhuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE), // Background Biru Sangat Muda
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Tata Cara Wudhu", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 22)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- HEADER GAMBAR ---
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 250, 
                decoration: const BoxDecoration(
                  color: Color(0xFF4FB3FF),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                  child: Image.asset(
                    'assets/header_wudhu.png', // Pastikan gambar ada
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(color: const Color(0xFF4FB3FF)),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- LIST KONTEN ---
          Expanded(
            child: _buildContentList('wudhu'),
          ),
        ],
      ),
    );
  }

  Widget _buildContentList(String category) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('contents')
          .where('category', isEqualTo: category)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        var docs = snapshot.data!.docs;
        
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            return _buildExpandableCard(context, index + 1, data);
          },
        );
      },
    );
  }

  // --- WIDGET KARTU BISA DIBUKA (EXPANDABLE) ---
  Widget _buildExpandableCard(BuildContext context, int number, Map<String, dynamic> data) {
    String imgUrl = data['imageUrl'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 15), // Jarak antar kartu
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Sudut bulat
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      // Theme digunakan untuk menghilangkan garis border bawaan ExpansionTile
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
          
          // 1. HEADER (Nomor Bintang & Judul)
          leading: SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 50), // Bintang Kuning
                Text(
                  "$number",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    shadows: [Shadow(color: Colors.orange, blurRadius: 2, offset: Offset(1, 1))]
                  ),
                ),
              ],
            ),
          ),
          title: Text(
            data['title'] ?? 'Judul Langkah',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0), // Biru Tua
            ),
          ),
          // Ikon panah (otomatis berputar saat diklik)
          trailing: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF4FB3FF), size: 30),

          // 2. ISI KONTEN (Muncul saat diklik)
          children: [
            const Divider(color: Color(0xFFE1F5FE), thickness: 1), // Garis pemisah tipis
            const SizedBox(height: 15),
            
            // GAMBAR BESAR
            if (imgUrl.isNotEmpty)
              Container(
                width: double.infinity,
                height: 200, 
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFE1F5FE), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: SmartImage(imgUrl, fit: BoxFit.cover),
                ),
              ),
            
            const SizedBox(height: 15),

            // PENJELASAN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), // Hijau sangat muda
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.lightbulb_outline_rounded, size: 18, color: Colors.green),
                      SizedBox(width: 5),
                      Text("Caranya:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    data['description'] ?? 'Penjelasan langkah...',
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF37474F),
                      height: 1.5,
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
}

// --- SMART IMAGE HELPER ---
class SmartImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  const SmartImage(this.imageUrl, {super.key, this.fit = BoxFit.cover});
  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return Container(color: Colors.grey[200]);
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl, fit: fit,
        loadingBuilder: (c, child, lp) => lp == null ? child : const Center(child: CircularProgressIndicator()),
        errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey),
      );
    } else {
      return Image.asset(imageUrl, fit: fit, errorBuilder: (c, e, s) => const Icon(Icons.broken_image));
    }
  }
}
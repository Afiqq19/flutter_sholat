import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GerakanSholatPage extends StatelessWidget {
  const GerakanSholatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0), // Background Oranye Sangat Muda
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Gerakan Sholat", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 22)),
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
                  color: Color(0xFFFFB74D),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                  child: Image.asset(
                    'assets/header_gerakan.png', 
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(color: const Color(0xFFFFB74D)),
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
            child: _buildContentList('gerakan'),
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

  // --- WIDGET KARTU EXPANDABLE ---
  Widget _buildExpandableCard(BuildContext context, int number, Map<String, dynamic> data) {
    String imgUrl = data['imageUrl'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(15, 0, 15, 20),

          // HEADER
          leading: SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFCA28), size: 50),
                Text(
                  "$number",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    shadows: [Shadow(color: Colors.brown, blurRadius: 2, offset: Offset(1, 1))]
                  ),
                ),
              ],
            ),
          ),
          title: Text(
            data['title'] ?? 'Judul Gerakan',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
          ),
          trailing: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.orange, size: 30),

          // ISI
          children: [
            const Divider(color: Color(0xFFFFE0B2), thickness: 1),
            const SizedBox(height: 15),

            // GAMBAR (DIPERBAIKI AGAR TIDAK TERPOTONG)
            if (imgUrl.isNotEmpty)
              Container(
                width: double.infinity,
                // Tinggi diubah jadi 220 biar gambar lebih leluasa
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFFFECB3), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  // PENTING: Menggunakan BoxFit.contain
                  child: SmartImage(imgUrl, fit: BoxFit.contain),
                ),
              ),

            const SizedBox(height: 15),

            // PENJELASAN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.lightbulb_outline_rounded, size: 18, color: Colors.orange),
                      SizedBox(width: 5),
                      Text("Caranya:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    data['description'] ?? 'Penjelasan...',
                    textAlign: TextAlign.justify,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF4E342E), height: 1.5),
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
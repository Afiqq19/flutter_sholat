import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SholatStepsPage extends StatelessWidget {
  final String categoryId; // Menerima data: 'sholat_subuh', 'sholat_dzuhur', dll
  final String title;      // Menerima judul halaman

  const SholatStepsPage({super.key, required this.categoryId, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE7F6), // Background Ungu Sangat Muda
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 22)),
        backgroundColor: const Color(0xFF673AB7), // Ungu Tua
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('contents')
            .where('category', isEqualTo: categoryId)
            // Pastikan field 'createdAt' ada di database, atau ganti dengan field 'step'
            .orderBy('createdAt') 
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)));
          }
          if (snapshot.hasError) {
             return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_rounded, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text("Data $title belum diisi admin", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              String imgUrl = data['imageUrl'] ?? '';
              String description = data['description'] ?? '';
              String itemTitle = data['title'] ?? 'Langkah';
              
              // Opsional: Jika ada field arab/latin
              String arabic = data['arabic'] ?? ''; 
              String latin = data['latin'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 20), // Jarak antar kartu lebih lebar
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25), // Sudut sangat bulat
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF673AB7).withOpacity(0.15), // Shadow Ungu Lembut
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
                    
                    // --- 1. HEADER: BINTANG UNGU ---
                    leading: SizedBox(
                      width: 55,
                      height: 55,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ikon Bintang
                          const Icon(Icons.star_rounded, color: Color(0xFF9575CD), size: 55), // Ungu Pastel
                          // Nomor
                          Text(
                            "${index + 1}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              shadows: [Shadow(color: Colors.deepPurple, blurRadius: 2, offset: Offset(1, 1))]
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // --- 2. JUDUL ---
                    title: Text(
                      itemTitle,
                      style: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFF512DA8) // Ungu Gelap
                      ),
                    ),
                    
                    // Ikon Panah
                    trailing: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF673AB7), size: 30),
                    
                    // --- 3. ISI KONTEN (EXPAND) ---
                    children: [
                      const Divider(color: Color(0xFFD1C4E9), thickness: 1), // Garis ungu tipis
                      const SizedBox(height: 15),
                      
                      // GAMBAR ILUSTRASI (Besar & Jelas)
                      if (imgUrl.isNotEmpty)
                        Container(
                          width: double.infinity,
                          height: 200, 
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E5F5), // Background ungu sangat pudar
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: const Color(0xFFD1C4E9), width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: SmartImage(imgUrl, fit: BoxFit.contain), // Gambar utuh
                          ),
                        ),
                      
                      // TEKS ARAB (Jika ada)
                      if (arabic.isNotEmpty)
                         Container(
                           width: double.infinity,
                           margin: const EdgeInsets.only(bottom: 15),
                           padding: const EdgeInsets.all(15),
                           decoration: BoxDecoration(
                             color: const Color(0xFFEDE7F6), // Ungu muda banget
                             borderRadius: BorderRadius.circular(15),
                             border: Border.all(color: const Color(0xFFD1C4E9)),
                           ),
                           child: Text(
                             arabic,
                             textAlign: TextAlign.center,
                             style: const TextStyle(
                               fontSize: 24, 
                               fontWeight: FontWeight.bold,
                               height: 1.8
                             ),
                           ),
                         ),

                       // LATIN & PENJELASAN (Dalam Kotak Putih Bersih)
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FD), // Abu sangat muda
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header "Bacaan"
                            if (latin.isNotEmpty) ...[
                               Row(
                                 children: const [
                                   Icon(Icons.record_voice_over_rounded, size: 18, color: Color(0xFF673AB7)),
                                   SizedBox(width: 5),
                                   Text("Bacaan Latin:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF673AB7))),
                                 ],
                               ),
                               const SizedBox(height: 5),
                               Text(latin, style: const TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF5E35B1), fontSize: 15)),
                               const SizedBox(height: 15),
                            ],
                            
                            // Header "Artinya/Caranya"
                            Row(
                               children: const [
                                 Icon(Icons.info_outline_rounded, size: 18, color: Colors.green),
                                 SizedBox(width: 5),
                                 Text("Penjelasan:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                               ],
                             ),
                            const SizedBox(height: 5),
                            Text(
                              description,
                              style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF455A64)),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --- CLASS SMART IMAGE ---
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
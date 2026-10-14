import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Sesuaikan import ini dengan file SmartImage kamu (biasanya di main.dart atau helper)
import '../../main.dart'; 

import 'add_wudhu_page.dart';
import 'add_gerakan_page.dart';
import 'add_sholat_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // --- PALET WARNA TEMA ANAK SHOLEH ---
  final Color mainColor = const Color(0xFF4FB3FF); // Biru Langit
  final Color accentColor = const Color(0xFFFFD54F); // Kuning Cerah
  final Color softBg = const Color(0xFFF4F8FB); // Background Putih Kebiruan
  final Color textDark = const Color(0xFF1A237E); // Biru Tua untuk Teks

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  // --- SHEET PROFIL ADMIN ---
  void _showProfileSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50, height: 5,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 25),
              // Avatar Admin
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFE3F2FD),
                child: Icon(Icons.admin_panel_settings_rounded, size: 50, color: mainColor),
              ),
              const SizedBox(height: 20),
              Text(
                currentUser?.email ?? "Admin",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: const Text("Super Admin", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _logout();
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  label: const Text("KELUAR APLIKASI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5252), // Merah Soft
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _deleteData(String documentId) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Data?"),
        content: const Text("Data yang dihapus tidak bisa dikembalikan."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance.collection('contents').doc(documentId).delete();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil dihapus')));
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- BUILDER LIST ---
  Widget _buildContentList(List<String> categories, Widget Function(DocumentSnapshot?) editPageBuilder) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('contents')
          .where('category', whereIn: categories) 
          .orderBy('createdAt', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: mainColor));
        }
        
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open_rounded, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 15),
                Text("Belum ada data", style: TextStyle(color: Colors.grey[400], fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 25, 20, 100),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5)
                  )
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: softBg,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade100)
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: SmartImage(data['imageUrl'] ?? '', fit: BoxFit.cover),
                  ),
                ),
                title: Text(
                  data['title'], 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      data['description'], 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    // Kategori Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD), // Biru sangat muda
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        data['category'].toString().toUpperCase().replaceAll('SHOLAT_', ''),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: mainColor),
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => editPageBuilder(doc)));
                    } else if (value == 'delete') {
                      _deleteData(doc.id);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(children: [Icon(Icons.edit_rounded, color: Colors.orange, size: 20), SizedBox(width: 12), Text('Edit')]),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(children: [Icon(Icons.delete_rounded, color: Colors.red, size: 20), SizedBox(width: 12), Text('Hapus')]),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: softBg, shape: BoxShape.circle),
                    child: Icon(Icons.more_vert_rounded, size: 20, color: Colors.grey[400]),
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (c, i) => const SizedBox(height: 15),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: true,
              pinned: true,
              backgroundColor: mainColor, // Warna Biru Langit
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))
              ),
              // --- JUDUL & PROFIL ---
              title: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    const Text("Panel Admin", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 22)),
                    const Spacer(),
                    GestureDetector(
                      onTap: _showProfileSheet,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: Color(0xFF4FB3FF), size: 24),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              centerTitle: false,
              
              // --- TAB BAR ---
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: accentColor, // Warna Kuning
                indicatorWeight: 4,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, fontFamily: 'Nunito'), // Font agak tebal
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                unselectedLabelColor: Colors.white.withOpacity(0.7),
                labelColor: Colors.white,
                padding: const EdgeInsets.only(bottom: 15),
                tabs: const [
                  Tab(text: "Wudhu"),
                  Tab(text: "Gerakan"),
                  Tab(text: "Sholat"),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildContentList(['wudhu'], (doc) => AddWudhuPage(document: doc)),
            _buildContentList(['gerakan'], (doc) => AddGerakanPage(document: doc)),
            _buildContentList(
              ['sholat_subuh', 'sholat_dzuhur', 'sholat_ashar', 'sholat_maghrib', 'sholat_isya'], 
              (doc) => AddSholatPage(document: doc)
            ),
          ],
        ),
      ),
      
      // --- TOMBOL TAMBAH (FAB) ---
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accentColor, // Warna Kuning Cerah
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Color(0xFF1A237E)), // Icon Biru Tua
        label: const Text(
          "TAMBAH DATA", 
          style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, letterSpacing: 0.5)
        ),
        onPressed: () {
          Widget page;
          if (_tabController.index == 0) page = const AddWudhuPage();
          else if (_tabController.index == 1) page = const AddGerakanPage();
          else page = const AddSholatPage();

          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
      ),
    );
  }
}

// --- SMART IMAGE HELPER (Agar tidak error saat copy paste) ---
class SmartImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  const SmartImage(this.imageUrl, {super.key, this.fit = BoxFit.cover});
  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return Container(color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey));
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
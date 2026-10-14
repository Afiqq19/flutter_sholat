import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_page.dart'; // Pastikan arah import ke login_page benar

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Warna Tema (Sesuai Dashboard)
  final Color mainColor = const Color(0xFF4FB3FF); 
  final Color softBg = const Color(0xFFF4F8FB);
  final Color textDark = const Color(0xFF1A237E);

  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Fungsi Ambil Data User dari Firestore
  Future<void> _getUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        
        if (doc.exists && mounted) {
          setState(() {
            userData = doc.data() as Map<String, dynamic>;
            isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  // Fungsi Logout
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      // Hapus semua history navigasi dan kembali ke Login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        title: const Text("Profil Saya", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: mainColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading 
          ? Center(child: CircularProgressIndicator(color: mainColor))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // --- HEADER PROFIL (Lingkaran Foto) ---
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Background Biru Melengkung
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                        ),
                      ),
                      // Foto Profil
                      Positioned(
                        bottom: -50,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: const Color(0xFFE3F2FD),
                            // Ganti dengan NetworkImage(userData['photoUrl']) jika ada foto di database
                            backgroundImage: const AssetImage('assets/logo.jpg'), 
                            child: const Icon(Icons.person, size: 60, color: Color(0xFF4FB3FF)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 60), // Spasi agar teks tidak tertutup foto

                  // --- NAMA & EMAIL ---
                  Text(
                    userData?['name'] ?? "User",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textDark),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userData?['email'] ?? user?.email ?? "-",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  
                  const SizedBox(height: 30),

                  // --- MENU EDIT / PENGATURAN ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildProfileItem(Icons.edit_rounded, "Edit Profil", () {}),
                        _buildProfileItem(Icons.settings_rounded, "Pengaturan", () {}),
                        _buildProfileItem(Icons.notifications_rounded, "Notifikasi", () {}),
                        _buildProfileItem(Icons.help_outline_rounded, "Bantuan", () {}),
                        
                        const SizedBox(height: 20),
                        
                        // --- TOMBOL LOGOUT ---
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _logout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFEBEE), // Merah sangat muda
                              foregroundColor: Colors.red, // Teks Merah
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              side: const BorderSide(color: Colors.redAccent, width: 1),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout_rounded),
                                SizedBox(width: 10),
                                Text("KELUAR AKUN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Widget Helper untuk Menu List
  Widget _buildProfileItem(IconData icon, String text, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: mainColor, size: 22),
        ),
        title: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
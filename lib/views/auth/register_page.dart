import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  // --- PALET WARNA ANAK-ANAK (SAMA DENGAN LOGIN) ---
  final Color mainColor = const Color(0xFF4FB3FF); // Biru Langit
  final Color secondaryColor = const Color(0xFFFFD54F); // Kuning Matahari
  final Color softBg = const Color(0xFFE3F2FD); // Background Lembut
  final Color textDark = const Color(0xFF1A237E); // Biru Tua untuk Teks

  // --- FUNGSI REGISTER ---
  Future<void> _register() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Isi semua kolom dulu ya, jangan ada yang kosong!"),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        )
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Buat Akun
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim());

      // 2. Simpan Data ke Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'user',
        'createdAt': DateTime.now(),
      });

      // 3. Sukses
      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Hore! Akun berhasil dibuat. Yuk Login!"),
              backgroundColor: Colors.green,
            ));
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Yah gagal: ${e.message}"),
            backgroundColor: Colors.redAccent,
          ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // --- DEKORASI BACKGROUND ATAS ---
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 300,
                child: Container(
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(color: mainColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo / Icon
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: secondaryColor, width: 4),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          // Gunakan gambar yang sama dengan login atau icon
                          backgroundImage: AssetImage('assets/logo.jpg'), 
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Yuk Gabung!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const Text(
                        "Biar bisa belajar solat bareng",
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),

              // --- HIASAN BUBBLE ---
              Positioned(
                top: 50,
                left: -20,
                child: CircleAvatar(radius: 40, backgroundColor: Colors.white.withOpacity(0.1)),
              ),
               Positioned(
                top: -20,
                right: -20,
                child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.1)),
              ),

              // --- FORM REGISTER (CARD) ---
              Positioned(
                top: 230,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30), // Rounded banget
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC3D8E6).withOpacity(0.8),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                       Text(
                        "Kenalan Dulu Yuk",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Input Nama
                      _buildCuteTextField(
                        controller: _nameController,
                        hint: "Nama Panggilanmu",
                        icon: Icons.face_rounded, // Icon wajah lucu
                      ),
                      const SizedBox(height: 15),

                      // Input Email
                      _buildCuteTextField(
                        controller: _emailController,
                        hint: "Email Ayah/Bunda",
                        icon: Icons.alternate_email_rounded,
                      ),
                      const SizedBox(height: 15),

                      // Input Password
                      _buildCuteTextField(
                        controller: _passwordController,
                        hint: "Buat Password Rahasia",
                        icon: Icons.lock_rounded,
                        isPassword: true,
                      ),
                      const SizedBox(height: 25),

                      // Tombol Daftar
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryColor, // Kuning
                            foregroundColor: textDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                            shadowColor: secondaryColor.withOpacity(0.5),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "MULAI BELAJAR!",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- TEXT LOGIN DI BAWAH ---
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Sudah punya akun? ", style: TextStyle(color: Colors.grey.shade600)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Masuk Disini",
                        style: TextStyle(
                          color: mainColor,
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET INPUT FIELD YANG LUCU (Copy dari Login Page) ---
  Widget _buildCuteTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8FF), // Alice Blue
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1F5FE), width: 2),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: textDark, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: mainColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}
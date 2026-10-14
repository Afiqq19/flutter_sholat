import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_page.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // --- PALET WARNA ANAK-ANAK (Cerah & Ceria) ---
  final Color mainColor = const Color(0xFF4FB3FF); // Biru Langit Cerah
  final Color secondaryColor = const Color(0xFFFFD54F); // Kuning Matahari
  final Color softBg = const Color(0xFFE3F2FD); // Biru Pucat untuk Background
  final Color textDark = const Color(0xFF1A237E); // Biru Tua untuk Teks (Biar terbaca)

  // --- FUNGSI LOGIN (TETAP SAMA, HANYA LOGIC) ---
  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ups! ${e.message}"),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- FUNGSI LUPA PASSWORD ---
  void _showForgotPasswordDialog() {
    final _resetEmailController = TextEditingController();
    if (_emailController.text.isNotEmpty) {
      _resetEmailController.text = _emailController.text;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          backgroundColor: Colors.white,
          title: Text("Lupa Password?", style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Jangan sedih ya, masukkan emailmu di sini:"),
              const SizedBox(height: 15),
              TextField(
                controller: _resetEmailController,
                decoration: InputDecoration(
                  hintText: "Email Ayah/Bunda",
                  filled: true,
                  fillColor: softBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  prefixIcon: Icon(Icons.email_rounded, color: mainColor),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                // ... (Logic Reset Password sama seperti sebelumnya)
                final email = _resetEmailController.text.trim();
                if (email.isEmpty) return;
                try {
                  Navigator.pop(context);
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Cek email ya! Link reset sudah dikirim."), backgroundColor: Colors.green),
                    );
                  }
                } on FirebaseAuthException catch (e) {
                   // Handle error
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Kirim", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg, // Background keseluruhan lembut
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // --- DEKORASI AWAN (Background Atas) ---
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 320,
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
                      // Ganti Asset logo ini dengan Gambar Kartun Muslim/Muslimah Lucu
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: secondaryColor, width: 4), // Border Kuning
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          // GANTI dengan gambar kartun anak
                          backgroundImage: AssetImage('assets/logo.jpg'), 
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Assalamualaikum!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900, // Lebih tebal (Chunky)
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Yuk Belajar Solat Bersama",
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 50), // Ruang untuk Card
                    ],
                  ),
                ),
              ),

              // --- HIASAN BULAT-BULAT (Bubble) ---
              Positioned(
                top: -30,
                right: -30,
                child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.1)),
              ),
              Positioned(
                top: 80,
                left: -20,
                child: CircleAvatar(radius: 30, backgroundColor: Colors.white.withOpacity(0.1)),
              ),

              // --- FORM LOGIN (Floating Card) ---
              Positioned(
                top: 260,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30), // Lebih bulat
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC3D8E6).withOpacity(0.8), // Shadow biru lembut
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Masuk Dulu Yuk",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 25),
                      
                      _buildCuteTextField(
                        controller: _emailController,
                        hint: "Email",
                        icon: Icons.alternate_email_rounded,
                      ),
                      const SizedBox(height: 15),
                      
                      _buildCuteTextField(
                        controller: _passwordController,
                        hint: "Password",
                        icon: Icons.lock_rounded,
                        isPassword: true,
                      ),
                      
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: Text("Lupa Password?", style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      
                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryColor, // Tombol Kuning Cerah
                            foregroundColor: textDark, // Text Biru Tua
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30), // Full Rounded (Capsule)
                            ),
                            elevation: 5,
                            shadowColor: secondaryColor.withOpacity(0.5),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "MASUK SEKARANG",
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

              // --- TEXT DAFTAR DI BAWAH ---
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Belum punya akun? ", style: TextStyle(color: Colors.grey.shade600)),
                    GestureDetector(
                      onTap: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterPage()),
                        );
                      },
                      child: Text(
                        "Daftar Disini",
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

  // --- WIDGET INPUT FIELD YANG LUCU ---
  Widget _buildCuteTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8FF), // Biru sangat muda (Alice Blue)
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1F5FE), width: 2), // Border tipis
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
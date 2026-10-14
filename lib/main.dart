import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart'; // WAJIB ADA!

import 'views/auth/login_page.dart';
import 'views/user/user_dashboard.dart';
import 'views/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FIX PENTING AGAR FIREBASE WEB TIDAK BLANK
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Belajar Sholat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const LoginPage(); // Belum login
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(snapshot.data!.uid)
              .get(),
          builder: (context, snapshotRole) {
            if (snapshotRole.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshotRole.hasData || !snapshotRole.data!.exists) {
              return const Scaffold(
                body: Center(child: Text("Role tidak ditemukan")),
              );
            }

            final role = snapshotRole.data!.get('role');

            if (role == 'admin') {
              return const AdminDashboard();
            } else {
              return const UserDashboard();
            }
          },
        );
      },
    );
  }
}

// --- WIDGET PINTAR UNTUK MENAMPILKAN GAMBAR (Bisa URL / Asset) ---
// Widget ini ditaruh di sini agar bisa diakses oleh file lain (Public Class)
class SmartImage extends StatelessWidget {
  final String path;
  final BoxFit fit;

  const SmartImage(this.path, {Key? key, this.fit = BoxFit.cover}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return const Icon(Icons.image_not_supported, color: Colors.grey);
    }
    
    // Cek apakah ini Link Internet?
    if (path.startsWith('http')) {
      return Image.network(
        path, 
        fit: fit,
        errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image),
      );
    } 
    
    // Jika bukan link, berarti Asset Lokal
    return Image.asset(
      path, 
      fit: fit,
      errorBuilder: (ctx, err, stack) => const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red),
          Text("File tdk ada", style: TextStyle(fontSize: 10))
        ],
      ),
    );
  }
}
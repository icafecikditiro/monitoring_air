import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_wrapper.dart';
import 'firebase_options.dart'; // Impor file yang digenerate oleh FlutterFire

// Ubah fungsi main menjadi async
void main() async {
  // Pastikan semua widget sudah siap sebelum menjalankan Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Login',
      // ...
      home: AuthWrapper(), // Ganti LoginPage() dengan AuthWrapper()
    );
  }
}
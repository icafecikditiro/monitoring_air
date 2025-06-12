import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Impor file yang digenerate oleh FlutterFire
import 'splash_screen.dart';

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
      home: SplashScreen(), // Ganti LoginPage() dengan AuthWrapper()
    );
  }
}
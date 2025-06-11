import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Fungsi untuk handle logic login
  Future<void> signInWithGoogle() async {
    // Buat instance dari Firebase & Google Auth
    FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      // Mulai alur login Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        // Dapatkan detail otentikasi dari request
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Buat kredensial baru untuk Firebase
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Setelah berhasil, login ke Firebase
        final UserCredential userCredential = await auth.signInWithCredential(credential);

        // Print nama user untuk verifikasi
        print("Login Berhasil: ${userCredential.user?.displayName}");

        // TODO: Navigasi ke halaman home setelah login berhasil

      }
    } catch (e) {
      print("Error saat login dengan Google: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login dengan Google'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            // Panggil fungsi login saat tombol ditekan
            signInWithGoogle();
          },
          icon: Image.asset('assets/google_logo.png', height: 24.0), // Pastikan Anda punya logo ini di folder assets
          label: const Text('Sign in with Google'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black, backgroundColor: Colors.white,
            minimumSize: const Size(250, 50),
          ),
        ),
      ),
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Jika user sudah login, tampilkan HomePage
        if (snapshot.hasData) {
          return const HomePage();
        }
        // Jika tidak, tampilkan LoginPage
        else {
          return const LoginPage();
        }
      },
    );
  }
}
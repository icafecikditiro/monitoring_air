import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beranda NilaFlow'),
        backgroundColor: Color(0xFF003D7C), // Sesuaikan dengan warna tema Anda
      ),
      body: Center(
        child: Text(
          'Selamat Datang di Aplikasi NilaFlow!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }
}
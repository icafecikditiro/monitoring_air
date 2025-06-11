import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Import splash screen Anda

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NilaFlow App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white, // Latar belakang default untuk layar lain
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(secondary: Color(0xFF00C2D1)), // Aksen warna
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(), // Mulai dengan SplashScreen
      debugShowCheckedModeBanner: false,
    );
  }
}
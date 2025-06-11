import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'home_screen.dart'; // Pastikan path ini benar

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  AnimationController? _fadeController;
  Animation<double>? _fadeAnimation;
  bool _showLogoAndText = false;

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(vsync: this);

    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800), // Durasi fade in logo dan teks
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController!, curve: Curves.easeIn),
    );

    // Menambahkan listener ke lottie controller. Lebih baik diinisialisasi di sini
    // dan hanya dijalankan sekali.
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _showLogoAndText = true;
          });
          _fadeController?.forward();
          Timer(Duration(seconds: 2), () { // Tunggu setelah fade in
            if (mounted) navigateToHome();
          });
        }
      }
    });
  }

  void navigateToHome() {
    // Pastikan navigasi hanya terjadi sekali dan widget masih mounted
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _fadeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih atau sesuaikan
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Lottie Animation
          Lottie.asset(
            'assets/lottie/water_splash_animation.json', // GANTI DENGAN NAMA FILE LOTTIE ANDA
            controller: _lottieController,
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width * 0.7,
            fit: BoxFit.contain,
            onLoaded: (composition) {
              if (mounted) {
                _lottieController
                  ..duration = composition.duration
                  ..forward(); // Mulai animasi setelah Lottie dimuat
              }
            },
            errorBuilder: (context, error, stackTrace) {
              // Fallback jika Lottie gagal dimuat
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_showLogoAndText) {
                  setState(() {
                    _showLogoAndText = true;
                  });
                  _fadeController?.forward();
                  Timer(Duration(seconds: 2), () {
                    if (mounted) navigateToHome();
                  });
                }
              });
              return Center(child: Text("Gagal memuat animasi...", style: TextStyle(color: Colors.grey)));
            },
          ),

          // Logo dan Nama Aplikasi
          Center(
            child: _showLogoAndText
                ? FadeTransition(
              opacity: _fadeAnimation!,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    'assets/images/logo.png', // GANTI DENGAN NAMA FILE LOGO ANDA
                    width: 180.0,
                    height: 180.0,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.broken_image, size: 120.0, color: Colors.grey);
                    },
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'NilaFlow',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003D7C), // Sesuaikan dengan warna brand Anda
                    ),
                  ),
                ],
              ),
            )
                : SizedBox.shrink(), // Widget kosong jika _showLogoAndText false
          ),
        ],
      ),
    );
  }
}
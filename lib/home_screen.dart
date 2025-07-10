// File: lib/main_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_page.dart'; // Pastikan path ini benar
import 'package:firebase_messaging/firebase_messaging.dart'; // BARU: Import FCM
import 'package:cloud_firestore/cloud_firestore.dart';
// Impor halaman-halaman yang akan ditampilkan
import 'dashboard_page.dart';
import 'history_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _setupNotifications();
    // Ambil UID pengguna. Jika tidak ada, gunakan string error (sebagai fallback).
    final String userId = _currentUser?.uid ?? 'error_no_user_id';

    // Inisialisasi daftar halaman dan teruskan userId ke halaman yang memerlukan.
    _pages = <Widget>[
      DashboardPage(userId: userId),
      HistoryPage(userId: userId),
      ProfilePage(user: _currentUser), // Jika diperlukan, Anda bisa tambahkan ProfilePage di sini
    ];
  }

  // BARU: Fungsi untuk meminta izin dan menyimpan token FCM
  Future<void> _setupNotifications() async {
    final messaging = FirebaseMessaging.instance;

    // 1. Minta Izin dari Pengguna
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      // 2. Dapatkan Token FCM
      final fcmToken = await messaging.getToken();
      print('FCM Token: $fcmToken');

      // 3. Simpan Token ke Firestore
      if (fcmToken != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final tokenRef = FirebaseFirestore.instance
              .collection('user_settings')
              .doc(user.uid);

          await tokenRef.set({
            'fcmToken': fcmToken,
          }, SetOptions(merge: true));
        }
      }
    } else {
      print('User declined or has not accepted permission');
    }

    // BARU: Dengarkan notifikasi saat aplikasi berjalan (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Di sini Anda bisa menampilkan dialog atau SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.notification?.title ?? "Notifikasi Baru"),
            action: SnackBarAction(
              label: "OK",
              onPressed: () {},
            ),
          ),
        );
      }
    });
  }
  // Mengubah judul agar lebih informatif dan modern
  static const List<String> _pageTitles = <String>[
    'NilaFlow Dashboard', // Judul Dashboard yang lebih ringkas
    'Analisis Riwayat',
    'Profil',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    try {
      final bool? confirmLogout = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Konfirmasi Logout'),
            content: Text('Apakah Anda yakin ingin keluar?'),
            actions: <Widget>[
              TextButton(child: Text('Batal'), onPressed: () => Navigator.of(context).pop(false)),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Logout'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (confirmLogout == true) {
        await GoogleSignIn().signOut();
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // Handle error
      print("Error during logout: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Desain AppBar yang diperbarui
        backgroundColor: Colors.transparent, // Membuat latar belakang AppBar transparan
        elevation: 0, // Menghilangkan bayangan default
        titleSpacing: 0, // Mengatur titleSpacing agar judul lebih dekat ke tepi
        toolbarHeight: kToolbarHeight + 10, // Menambah sedikit tinggi AppBar

        // Menggunakan FlexibleSpace dengan gradien untuk tampilan modern
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)], // Gradien biru
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            // Opsional: Jika ingin AppBar melengkung di bagian bawah
            // borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
        ),

        // Mengatur tema ikon dan teks agar terlihat elegan di atas gradien
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),

        // Judul halaman
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
              _pageTitles[_selectedIndex],
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
          ),
        ),

        // Aksi (Profil Pengguna dan Logout)
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') _logout();
              },
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      const Text('Logout'),
                    ],
                  ),
                ),
              ],
              // Mengubah CircleAvatar menjadi lebih menonjol
              child: Container(
                padding: const EdgeInsets.all(2), // Padding untuk border efek
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // Warna border putih
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF0D47A1), // Latar belakang avatar jika tidak ada foto
                  backgroundImage: _currentUser?.photoURL != null ? NetworkImage(_currentUser!.photoURL!) : null,
                  child: _currentUser?.photoURL == null
                      ? Text(_currentUser?.displayName?.substring(0, 1).toUpperCase() ?? 'U', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'Analisis'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF0D47A1),
        onTap: _onItemTapped,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed, // Memastikan item tidak bergeser saat dipilih
      ),
    );
  }
}
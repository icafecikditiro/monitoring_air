import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
// Import package Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_page.dart'; // Pastikan path ini benar

//==================================================================
// Halaman Utama yang Mengelola Navigasi
//==================================================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  final List<Widget> _pages = <Widget>[
    DashboardPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  static const List<String> _pageTitles = <String>[
    'Dashboard NilaFlow',
    'Riwayat Data',
    'Profil Pengguna',
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
              TextButton(child: Text('Logout'), onPressed: () => Navigator.of(context).pop(true)),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex], style: TextStyle(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
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
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                backgroundImage: _currentUser?.photoURL != null ? NetworkImage(_currentUser!.photoURL!) : null,
                child: _currentUser?.photoURL == null
                    ? Text(_currentUser?.displayName?.substring(0, 1).toUpperCase() ?? 'U', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                    : null,
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
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF0D47A1),
        onTap: _onItemTapped,
      ),
    );
  }
}

//==================================================================
// Halaman Dashboard (Menggunakan Firebase)
//==================================================================
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Alamat data real-time di Firestore
    final DocumentReference statusRef = FirebaseFirestore.instance.collection('realtime_status').doc('kolam_utama');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
        ),
      ),
      child: Center(
        child: StreamBuilder<DocumentSnapshot>(
          stream: statusRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildStatusIndicator("Menghubungkan...", Icons.wifi_tethering);
            }
            if (snapshot.hasError) {
              return _buildStatusIndicator("Koneksi Gagal", Icons.error_outline, isError: true);
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return _buildStatusIndicator("Menunggu data sensor...", Icons.hourglass_empty);
            }

            try {
              final SensorData data = SensorData.fromFirestore(snapshot.data!);
              return _buildDataDisplay(data);
            } catch (e) {
              return _buildStatusIndicator("Data tidak valid", Icons.error_outline, isError: true);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDataDisplay(SensorData data) {
    // ... (UI untuk menampilkan data, tidak ada perubahan di sini)
    return SingleChildScrollView(/* ... */);
  }

  Widget _buildStatusIndicator(String text, IconData icon, {bool isError = false}) {
    // ... (UI untuk status, tidak ada perubahan di sini)
    return Center(/* ... */);
  }
}

//==================================================================
// Halaman Riwayat (Menggunakan Firebase)
//==================================================================
class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Query untuk mengambil 50 data riwayat terakhir
  final Query historyQuery = FirebaseFirestore.instance
      .collection('history_data')
      .orderBy('timestamp', descending: true)
      .limit(50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: historyQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Tidak ada data riwayat."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              SensorData item = SensorData.fromFirestore(doc);
              return _buildHistoryTile(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryTile(SensorData data) {
    // ... (UI untuk tile riwayat, tidak ada perubahan di sini)
    return Card(/* ... */);
  }
}

//==================================================================
// Halaman Profil (Placeholder)
//==================================================================
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Halaman Profil Pengguna')),
    );
  }
}

//==================================================================
// Model Data & Enum
//==================================================================
enum WaterStatus { jernih, sedang, keruh }
class SensorData {
  final double turbidity;
  final DateTime timestamp;

  SensorData({required this.turbidity, required this.timestamp});

  // Factory constructor baru untuk membaca dari Firestore
  factory SensorData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SensorData(
      turbidity: (data['turbidity'] as num?)?.toDouble() ?? 0.0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  WaterStatus get status {
    if (turbidity < 150) return WaterStatus.jernih;
    if (turbidity <= 250) return WaterStatus.sedang;
    return WaterStatus.keruh;
  }
}

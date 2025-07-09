// File: lib/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/sensor_data_model.dart'; // Pastikan path ini benar

class DashboardPage extends StatelessWidget {
  final String userId;
  const DashboardPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // --- PERUBAHAN UTAMA: Membuat Query ke koleksi history_data ---
    // 1. Arahkan ke koleksi 'history_data'.
    // 2. Urutkan berdasarkan 'timestamp' dari yang terbaru (descending).
    // 3. Batasi hasilnya hanya 1 dokumen teratas.
    final Query historyQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('history_data') // <--- NAMA KOLEKSI BARU
        .orderBy('timestamp', descending: true) // <--- PENTING: Mengambil yang terbaru
        .limit(1); // <--- PENTING: Hanya satu data

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
        ),
      ),
      child: Center(
        // --- PERUBAHAN: StreamBuilder sekarang menggunakan QuerySnapshot ---
        child: StreamBuilder<QuerySnapshot>(
          stream: historyQuery.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildStatusIndicator("Menghubungkan...", Icons.wifi_tethering);
            }
            if (snapshot.hasError) {
              // Menambahkan log error untuk debugging yang lebih mudah
              print("Firestore Error: ${snapshot.error}");
              return _buildStatusIndicator("Koneksi Gagal", Icons.error_outline, isError: true);
            }
            // --- PERUBAHAN: Cek apakah query mengembalikan dokumen ---
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildStatusIndicator("Menunggu data sensor...", Icons.hourglass_empty);
            }

            try {
              // Ambil dokumen pertama dari daftar hasil query
              final DocumentSnapshot latestDataDoc = snapshot.data!.docs.first;
              final SensorData data = SensorData.fromFirestore(latestDataDoc);
              return _buildDataDisplay(data);
            } catch (e) {
              // Menambahkan log error untuk debugging
              print("Data Parsing Error: $e");
              return _buildStatusIndicator("Data tidak valid", Icons.error_outline, isError: true);
            }
          },
        ),
      ),
    );
  }

  // Widget untuk menampilkan data utama (TIDAK ADA PERUBAHAN DI SINI)
  Widget _buildDataDisplay(SensorData data) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (data.status) {
      case WaterStatus.jernih:
        statusColor = Colors.lightBlue.shade300;
        statusIcon = Icons.check_circle_outline;
        statusText = "Air Jernih";
        break;
      case WaterStatus.sedang:
        statusColor = Colors.teal.shade300;
        statusIcon = Icons.warning_amber_rounded;
        statusText = "Kondisi Sedang";
        break;
      case WaterStatus.keruh:
        statusColor = Colors.brown.shade400;
        statusIcon = Icons.dangerous_outlined;
        statusText = "Air Keruh";
        break;
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [statusColor.withOpacity(0.7), statusColor],
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(statusIcon, size: 80, color: Colors.white.withOpacity(0.9)),
                  SizedBox(height: 16),
                  Text(statusText, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
                ],
              ),
            ),
            SizedBox(height: 40),
            Text('${data.turbidity.toStringAsFixed(2)} NTU', style: TextStyle(fontSize: 52, fontWeight: FontWeight.w700, color: Colors.white, shadows: [Shadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: Offset(0, 2))])),
            Text('Tingkat Kekeruhan', style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.8))),
            SizedBox(height: 40),
            Text('Terakhir diperbarui:', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
            SizedBox(height: 4),
            Text('${data.timestamp.toLocal().day}/${data.timestamp.toLocal().month}/${data.timestamp.toLocal().year} - ${data.timestamp.toLocal().hour}:${data.timestamp.toLocal().minute.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk status (TIDAK ADA PERUBAHAN DI SINI)
  Widget _buildStatusIndicator(String text, IconData icon, {bool isError = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 60, color: isError ? Colors.red.shade300 : Colors.white70),
        SizedBox(height: 16),
        Text(text, style: TextStyle(fontSize: 18, color: Colors.white70)),
      ],
    );
  }
}

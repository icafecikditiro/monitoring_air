// File: lib/dashboard_page.dart
// Halaman ini menampilkan status kekeruhan air secara real-time.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Impor model data Anda agar bisa digunakan di sini
import 'models/sensor_data_model.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Alamat dokumen di Firestore yang berisi data real-time
    final DocumentReference statusRef =
    FirebaseFirestore.instance.collection('realtime_status').doc('kolam_utama');

    return Container(
      // Latar belakang gradasi yang konsisten dengan tema
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
        ),
      ),
      child: Center(
        child: StreamBuilder<DocumentSnapshot>(
          stream: statusRef.snapshots(), // Mendengarkan perubahan pada dokumen
          builder: (context, snapshot) {
            // Tampilkan loading indicator saat menghubungkan
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildStatusIndicator("Menghubungkan...", Icons.wifi_tethering);
            }
            // Tampilkan pesan error jika koneksi gagal
            if (snapshot.hasError) {
              return _buildStatusIndicator("Koneksi Gagal", Icons.error_outline, isError: true);
            }
            // Tampilkan pesan jika dokumen tidak ada atau belum ada data
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return _buildStatusIndicator("Menunggu data sensor...", Icons.hourglass_empty);
            }

            // Jika semua berhasil, parse data dan tampilkan UI utama
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

  // Widget untuk menampilkan data utama saat berhasil diterima
  Widget _buildDataDisplay(SensorData data) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    // Tentukan warna, ikon, dan teks berdasarkan status kekeruhan
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
            // Kontainer visualisasi status yang bisa beranimasi
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(statusIcon, size: 80, color: Colors.white.withOpacity(0.9)),
                  SizedBox(height: 16),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            // Tampilan nilai NTU
            Text(
              '${data.turbidity.toStringAsFixed(2)} NTU',
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: Offset(0, 2))],
              ),
            ),
            Text(
              'Tingkat Kekeruhan',
              style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.8)),
            ),

            SizedBox(height: 40),

            // Tampilan waktu pembaruan
            Text(
              'Terakhir diperbarui:',
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
            ),
            SizedBox(height: 4),
            Text(
              '${data.timestamp.toLocal().day}/${data.timestamp.toLocal().month}/${data.timestamp.toLocal().year} - ${data.timestamp.toLocal().hour}:${data.timestamp.toLocal().minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk menampilkan status koneksi atau error
  Widget _buildStatusIndicator(String text, IconData icon, {bool isError = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 60, color: isError ? Colors.red.shade300 : Colors.white70),
        SizedBox(height: 16),
        Text(
          text,
          style: TextStyle(fontSize: 18, color: isError ? Colors.red.shade300 : Colors.white70),
        ),
      ],
    );
  }
}

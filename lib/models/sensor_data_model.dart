// File: lib/models/sensor_data_model.dart
// Simpan model data di file terpisah agar bisa digunakan oleh banyak halaman.

import 'package:cloud_firestore/cloud_firestore.dart';

// Enum untuk merepresentasikan status air dengan lebih jelas
enum WaterStatus {
  jernih,
  sedang,
  keruh,
}

// Model data
class SensorData {
  final double turbidity;
  final DateTime timestamp;

  SensorData({required this.turbidity, required this.timestamp});

  // Factory constructor untuk membaca dari Firestore
  factory SensorData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SensorData(
      turbidity: (data['turbidity'] as num?)?.toDouble() ?? 0.0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Fungsi helper untuk mendapatkan status berdasarkan nilai turbidity
  WaterStatus get status {
    if (turbidity < 150) return WaterStatus.jernih;
    if (turbidity <= 250) return WaterStatus.sedang;
    return WaterStatus.keruh;
  }
}

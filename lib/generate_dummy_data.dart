// Abaikan error di editor untuk file ini, karena ini adalah skrip standalone, bukan bagian dari UI Flutter.
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

// Impor konfigurasi Firebase Anda. Pastikan Anda sudah menjalankan 'flutterfire configure'.
import 'firebase_options.dart';

// [PERUBAHAN PENTING] Impor ini diperlukan untuk ensureInitialized().
import 'package:flutter/widgets.dart';

// ===================================================================
// PANDUAN CARA MENJALANKAN SCRIPT INI:
// ===================================================================
// 1. Buat file baru di dalam folder `lib/` proyek Anda. Beri nama, misalnya, `generate_dummy_data.dart`.
// 2. Salin (copy) seluruh kode ini dan tempel (paste) ke dalam file tersebut.
// 3. Buka terminal atau Command Prompt di direktori root proyek Flutter Anda.
// 4. Jalankan skrip dengan perintah berikut:
//
//    flutter run lib/generate_dummy_data.dart
//
// 5. Tunggu beberapa saat. Skrip akan mencetak pesan "Uploading dummy data..." dan "Dummy data uploaded successfully!".
// 6. Cek Firestore console Anda. Anda akan melihat 100 dokumen baru di collection `history_data`.
// ===================================================================

void main() async {
  // [PERBAIKAN] Inisialisasi "jembatan" Flutter ke native sebelum melakukan apa pun.
  WidgetsFlutterBinding.ensureInitialized();

  // Langkah 1: Inisialisasi Firebase
  // Diperlukan agar skrip bisa terhubung ke proyek Firebase Anda.
  print("Initializing Firebase...");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Firebase initialized.");

  // Langkah 2: Buat 100 Data Dummy
  print("Generating 100 dummy data points...");
  List<Map<String, dynamic>> dummyDataList = [];
  final random = Random();
  final now = DateTime.now();

  for (int i = 0; i < 100; i++) {
    double turbidity;

    // Bagi data menjadi 3 kategori
    if (i < 40) { // 40 data Jernih
      // Nilai antara 50.0 dan 149.9
      turbidity = 50 + random.nextDouble() * 100;
    } else if (i < 70) { // 30 data Sedang
      // Nilai antara 150.0 dan 250.0
      turbidity = 150 + random.nextDouble() * 100;
    } else { // 30 data Keruh
      // Nilai antara 250.1 dan 350.0
      turbidity = 250.1 + random.nextDouble() * 100;
    }

    // Buat timestamp yang mundur agar terlihat seperti riwayat
    final timestamp = now.subtract(Duration(hours: i));

    dummyDataList.add({
      'turbidity': double.parse(turbidity.toStringAsFixed(2)),
      'timestamp': Timestamp.fromDate(timestamp),
    });
  }
  print("Dummy data generated.");

  // Langkah 3: Unggah Data ke Firestore menggunakan Batch Write
  print("Uploading dummy data to Firestore...");
  final firestore = FirebaseFirestore.instance;
  final collectionRef = firestore.collection('history_data');

  // Batch write jauh lebih efisien daripada mengunggah satu per satu.
  final batch = firestore.batch();

  for (var data in dummyDataList) {
    // Buat dokumen baru dengan ID acak di dalam collection 'history_data'
    final docRef = collectionRef.doc();
    batch.set(docRef, data);
  }

  // Lakukan semua operasi tulis dalam satu kali panggilan ke server
  await batch.commit();

  print("==========================================================");
  print("SUCCESS: 100 dummy data points have been uploaded to the 'history_data' collection.");
  print("==========================================================");
}

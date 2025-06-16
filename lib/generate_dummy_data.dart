// Abaikan error di editor untuk file ini, karena ini adalah skrip standalone, bukan bagian dari UI Flutter.
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:flutter/widgets.dart';

// Impor konfigurasi Firebase Anda. Pastikan Anda sudah menjalankan 'flutterfire configure'.
import 'firebase_options.dart';

// ===================================================================
// PANDUAN CARA MENJALANKAN SCRIPT INI:
// ===================================================================
// 1. Buat file baru di dalam folder `lib/` proyek Anda. Beri nama, misalnya, `generate_dummy_data.dart`.
// 2. Salin (copy) seluruh kode ini dan tempel (paste) ke dalam file tersebut.
// 3. [PENTING] Ganti nilai variabel `TEST_USER_ID` dengan UID Anda sendiri.
//    (Anda bisa mendapatkan UID Anda dari Firebase Console > Authentication).
// 4. Buka terminal atau Command Prompt di direktori root proyek Flutter Anda.
// 5. Jalankan skrip dengan perintah berikut:
//
//    flutter run lib/generate_dummy_data.dart
//
// 6. Cek Firestore console. Anda akan melihat sub-collection 'history_data'
//    berisi 100 dokumen baru di bawah dokumen pengguna Anda.
// ===================================================================

void main() async {
  // Inisialisasi "jembatan" Flutter ke native.
  WidgetsFlutterBinding.ensureInitialized();

  // Langkah 1: Inisialisasi Firebase
  print("Initializing Firebase...");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Firebase initialized.");

  // [PERUBAHAN] Tentukan untuk pengguna mana data ini akan dibuat.
  // GANTI NILAI INI DENGAN UID ANDA DARI FIREBASE AUTHENTICATION!
  const String TEST_USER_ID = "zuUlaz4zBZOJN85ThBRdgPtTJ7U2";

  if (TEST_USER_ID == "ganti_dengan_uid_anda_sendiri") {
    print("======================================================");
    print("ERROR: Harap ganti nilai TEST_USER_ID di dalam skrip.");
    print("======================================================");
    return;
  }

  // Langkah 2: Buat 100 Data Dummy
  print("Generating 100 dummy data points for user: $TEST_USER_ID");
  List<Map<String, dynamic>> dummyDataList = [];
  final random = Random();
  final now = DateTime.now();

  for (int i = 0; i < 100; i++) {
    double turbidity;
    if (i < 40) { // 40 data Jernih
      turbidity = 50 + random.nextDouble() * 100;
    } else if (i < 70) { // 30 data Sedang
      turbidity = 150 + random.nextDouble() * 100;
    } else { // 30 data Keruh
      turbidity = 250.1 + random.nextDouble() * 100;
    }

    final timestamp = now.subtract(Duration(hours: i));
    dummyDataList.add({
      'turbidity': double.parse(turbidity.toStringAsFixed(2)),
      'timestamp': Timestamp.fromDate(timestamp),
    });
  }
  print("Dummy data generated.");

  // Langkah 3: Unggah Data ke Firestore
  print("Uploading dummy data to Firestore...");
  final firestore = FirebaseFirestore.instance;

  // [PERUBAHAN] Path sekarang menunjuk ke sub-collection di bawah dokumen pengguna
  final collectionRef = firestore
      .collection('users')
      .doc(TEST_USER_ID)
      .collection('history_data');

  final batch = firestore.batch();
  for (var data in dummyDataList) {
    final docRef = collectionRef.doc();
    batch.set(docRef, data);
  }

  await batch.commit();

  print("==========================================================");
  print("SUCCESS: 100 dummy data points have been uploaded for user $TEST_USER_ID.");
  print("==========================================================");
}

// File: lib/notification_settings_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // BARU: Import package
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationSettingsPage extends StatefulWidget {
  final User? user;

  const NotificationSettingsPage({super.key, this.user});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _isLoading = true;
  // Variabel state tetap sama
  bool _masterNotificationsEnabled = true;
  bool _turbidityAlertsEnabled = true;
  double _turbidityThreshold = 80.0;
  bool _deviceOfflineAlertsEnabled = true;
  bool _promoInfoEnabled = false;

  // BARU: Panggil fungsi untuk memuat pengaturan saat halaman pertama kali dibuka
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _masterNotificationsEnabled = prefs.getBool('masterNotifications') ?? true;
      _turbidityAlertsEnabled = prefs.getBool('turbidityAlerts') ?? true;
      _turbidityThreshold = prefs.getDouble('turbidityThreshold') ?? 80.0;
      _deviceOfflineAlertsEnabled = prefs.getBool('deviceOfflineAlerts') ?? true;
      _promoInfoEnabled = prefs.getBool('promoInfo') ?? false;
      _isLoading = false; // BARU: Loading selesai
    });
  }

  // BARU: Fungsi untuk menyimpan pengaturan ke memori perangkat
  // BARU: Fungsi _saveSettings yang sudah dimodifikasi
  Future<void> _saveSettings() async {
    // 1. Simpan ke SharedPreferences (Lokal)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('masterNotifications', _masterNotificationsEnabled);
    await prefs.setBool('turbidityAlerts', _turbidityAlertsEnabled);
    await prefs.setDouble('turbidityThreshold', _turbidityThreshold);
    await prefs.setBool('deviceOfflineAlerts', _deviceOfflineAlertsEnabled);
    await prefs.setBool('promoInfo', _promoInfoEnabled);

    // 2. Simpan ke Firestore (Online)
    final user = widget.user;
    if (user == null) return; // Jangan lakukan apa-apa jika user tidak login

    // Tentukan lokasi dokumen di firestore
    final docRef = FirebaseFirestore.instance.collection('user_settings').doc(user.uid);

    // Siapkan data yang akan disimpan
    final settingsData = {
      'masterNotificationsEnabled': _masterNotificationsEnabled,
      'turbidityAlertsEnabled': _turbidityAlertsEnabled,
      'turbidityThreshold': _turbidityThreshold,
      'deviceOfflineAlertsEnabled': _deviceOfflineAlertsEnabled,
      'lastUpdated': FieldValue.serverTimestamp(), // Tandai kapan terakhir diupdate
    };

    // Gunakan .set dengan merge:true agar tidak menghapus data lain di dokumen
    await docRef.set(settingsData, SetOptions(merge: true));
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen Notifikasi"),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Terima Notifikasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: const Text("Aktifkan atau nonaktifkan semua notifikasi"),
            value: _masterNotificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _masterNotificationsEnabled = value;
              });
              _saveSettings(); // BARU: Simpan perubahan
            },
          ),
          const Divider(),

          _buildSectionHeader("Notifikasi Kritis"),

          SwitchListTile(
            title: const Text("Peringatan Kekeruhan Tinggi"),
            subtitle: const Text("Dapat notifikasi jika air terlalu keruh"),
            value: _turbidityAlertsEnabled,
            onChanged: _masterNotificationsEnabled ? (bool value) {
              setState(() {
                _turbidityAlertsEnabled = value;
              });
              _saveSettings(); // BARU: Simpan perubahan
            } : null,
          ),

          if (_turbidityAlertsEnabled && _masterNotificationsEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Batas Kekeruhan: ${_turbidityThreshold.round()} NTU"),
                  Slider(
                    value: _turbidityThreshold,
                    min: 0,
                    max: 200,
                    divisions: 20,
                    label: _turbidityThreshold.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _turbidityThreshold = value;
                      });
                    },
                    // BARU: Simpan perubahan setelah selesai menggeser slider
                    onChangeEnd: (double value) {
                      _saveSettings();
                    },
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          SwitchListTile(
            title: const Text("Peringatan Status Perangkat"),
            subtitle: const Text("Dapat notifikasi jika perangkat offline"),
            value: _deviceOfflineAlertsEnabled,
            onChanged: _masterNotificationsEnabled ? (bool value) {
              setState(() {
                _deviceOfflineAlertsEnabled = value;
              });
              _saveSettings(); // BARU: Simpan perubahan
            } : null,
          ),
          const Divider(),
        ],
      ),
    );
  }
}
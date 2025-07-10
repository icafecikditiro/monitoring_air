import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_settings_page.dart';
import 'device_management.dart';
import 'help_center_page.dart';

class ProfilePage extends StatefulWidget {
  final User? user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Variabel state untuk mengontrol toggle dark mode
  bool _isDarkMode = false;

  // Placeholder untuk data pengguna. Nantinya, data ini akan diambil
  // dari service otentikasi Google Anda (misalnya Firebase Auth).
  final String _userName = "Budi Santoso";
  final String _userEmail = "budi.santoso@gmail.com";
  final String? _userPhotoUrl = null; // Ganti dengan URL foto jika ada

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          // --- BAGIAN HEADER PROFIL ---
          _buildProfileHeader(),
          const SizedBox(height: 24),

          // --- BAGIAN PENGATURAN APLIKASI ---
          _buildSectionHeader("Pengaturan Aplikasi"),
          _buildProfileOption(
            icon: Icons.notifications_outlined,
            title: "Manajemen Notifikasi",
            onTap: () {
              // BARU: Kirim data pengguna saat navigasi
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationSettingsPage(user: widget.user)),
              );
            },
          ),
          _buildProfileOption(
            icon: Icons.sensors_outlined,
            title: "Manajemen Perangkat",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DeviceManagementPage()), // <-- PERBAIKI INI
              );
            },
          ),

          // Opsi dengan Toggle Switch
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: Icon(Icons.dark_mode_outlined, color: Theme.of(context).colorScheme.primary),
              title: const Text("Mode Gelap"),
              trailing: Switch(
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                  // TODO: Tambahkan logika untuk mengubah tema aplikasi
                  // (misalnya menggunakan Provider, GetX, atau Bloc)
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- BAGIAN BANTUAN & INFORMASI ---
          _buildSectionHeader("Bantuan & Informasi"),
          _buildProfileOption(
            icon: Icons.help_outline,
            title: "Pusat Bantuan",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpCenterPage()), // <-- PERBAIKI INI
              );
            },
          ),
          _buildProfileOption(
            icon: Icons.info_outline,
            title: "Tentang Aplikasi",
            onTap: () {
              showAboutDialog( // <-- PERBAIKI INI
                context: context,
                applicationName: "NilaFlow",
                applicationVersion: "1.0.0",
                applicationIcon: const Icon(Icons.waves),
                applicationLegalese: "© 2025 NilaFlow Inc.",
              );
            },
          ),
          const SizedBox(height: 24),


          // --- BAGIAN AKUN ---
          _buildLogoutButton(),
          const SizedBox(height: 16),
          _buildDeleteAccountButton(),
          const SizedBox(height: 40),

          // --- Versi Aplikasi ---
          const Center(
            child: Text(
              "NilaFlow v1.0.0",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),

        ],
      ),
    );
  }

  // Widget untuk header profil (foto, nama, email)
  Widget _buildProfileHeader() {
    // Gunakan 'widget.user' untuk mengakses data pengguna
    final user = widget.user;

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
          child: user?.photoURL == null
              ? Text(
            // Ambil huruf pertama dari nama, atau 'U' jika nama null
            user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
            style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
          )
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          // Tampilkan nama pengguna, atau 'Nama Pengguna' jika null
          user?.displayName ?? 'Nama Pengguna',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          // Tampilkan email pengguna, atau 'Email tidak tersedia' jika null
          user?.email ?? 'Email tidak tersedia',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }
  // Widget helper untuk membuat judul setiap seksi
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2
        ),
      ),
    );
  }

  // Widget helper untuk membuat baris opsi profil
  Widget _buildProfileOption({required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  // Widget untuk tombol Keluar
  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.logout),
      label: const Text("Keluar"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        // TODO: Tambahkan logika untuk logout (clear session, hapus token, navigasi ke halaman login)
        // Contoh:
        // await FirebaseAuth.instance.signOut();
        // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
      },
    );
  }

  // Widget untuk tombol Hapus Akun
  Widget _buildDeleteAccountButton() {
    return Center(
      child: TextButton(
        child: Text("Hapus Akun", style: TextStyle(color: Colors.red.shade700)),
        onPressed: () {
          // TODO: Tampilkan dialog konfirmasi sebelum menghapus akun.
          // Jika dikonfirmasi, panggil fungsi untuk menghapus data pengguna dari server Anda.
        },
      ),
    );
  }
}
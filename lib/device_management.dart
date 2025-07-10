import 'package:flutter/material.dart';

class DeviceManagementPage extends StatelessWidget {
  const DeviceManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen Perangkat"),
      ),
      body: const Center(
        child: Text("Halaman untuk mengelola perangkat NilaFlow."),
      ),
    );
  }
}
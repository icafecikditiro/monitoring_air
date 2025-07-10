import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pusat Bantuan"),
      ),
      body: const Center(
        child: Text("Halaman FAQ dan bantuan akan ada di sini."),
      ),
    );
  }
}
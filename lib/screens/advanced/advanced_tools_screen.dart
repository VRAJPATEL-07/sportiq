import 'package:flutter/material.dart';
import '../../widgets/speed_dial_fab.dart';

class AdvancedToolsScreen extends StatelessWidget {
  const AdvancedToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Admin contact used for demo — replace with app config or env
    const adminPhone = '+1234567890';
    const adminEmail = 'admin@sportiq.example';

    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Tools')),
      floatingActionButton: const SpeedDialFAB(adminPhone: adminPhone, adminEmail: adminEmail),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ElevatedButton.icon(onPressed: () => Navigator.pushNamed(context, '/api_posts'), icon: const Icon(Icons.cloud_download), label: const Text('API Posts')),
          const SizedBox(height: 8),
          ElevatedButton.icon(onPressed: () => Navigator.pushNamed(context, '/gallery'), icon: const Icon(Icons.photo), label: const Text('Gallery')),
          const SizedBox(height: 8),
          ElevatedButton.icon(onPressed: () => Navigator.pushNamed(context, '/camera'), icon: const Icon(Icons.camera), label: const Text('Camera')),
          const SizedBox(height: 8),
          ElevatedButton.icon(onPressed: () => Navigator.pushNamed(context, '/qr_scan'), icon: const Icon(Icons.qr_code_scanner), label: const Text('QR Scan (wakelock)')),
        ]),
      ),
    );
  }
}

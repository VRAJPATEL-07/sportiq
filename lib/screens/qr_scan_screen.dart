import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  @override
  void initState() {
    super.initState();
    // Keep screen awake during scanning
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    // Disable wakelock when leaving
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scan (Wakelock enabled)')),
      body: const Center(child: Text('Scanner placeholder - wakelock is enabled while this screen is active.')),
    );
  }
}

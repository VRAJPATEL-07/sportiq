import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'qr_scanner_screen.dart';
import 'scan_history_screen.dart';

class ScanEquipmentScreen extends StatelessWidget {
  const ScanEquipmentScreen({super.key});

  bool get _supportsLiveCamera {
    if (kIsWeb) return true;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Equipment"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_scanner,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              "Scan Equipment QR Code",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _supportsLiveCamera
                  ? "Point your camera at the equipment's QR code to borrow it."
                  : "Open the scanner to import a QR image or enter the code manually on this platform.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScannerScreen()));
                },
                icon: Icon(_supportsLiveCamera ? Icons.camera_alt : Icons.qr_code_scanner),
                label: Text(_supportsLiveCamera ? "Open Camera" : "Open Scanner"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScannerScreen()));
                    },
                    child: const Text("Manual / Image Scan"),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanHistoryScreen()));
                    },
                    child: const Text('History'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
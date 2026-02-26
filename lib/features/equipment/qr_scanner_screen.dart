import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../providers/equipment_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'qr_payload.dart';
import 'dev_seed.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _isScanning = true;
  String? _lastScan;
  bool _flashOn = false;
  bool _processing = false;

  final MobileScannerController _controller = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (status != PermissionStatus.granted) {
      showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Camera permission required'),
          content: const Text('Camera permission is needed to scan equipment QR codes.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close')),
          ],
        ),
      );
    }
  }

  void _handleBarcode(BarcodeCapture capture) async {
    if (!_isScanning || _processing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue;
    if (code == null) return;

    setState(() {
      _isScanning = false;
      _processing = true;
      _lastScan = code;
    });

    try {
      final provider = Provider.of<EquipmentProvider>(context, listen: false);
      final found = await provider.findByQrValue(code);
      if (found == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No equipment found for this QR code')));
      } else {
        // navigate to equipment detail page instead of staying on scanner
        if (mounted) {
          // pause scanning before navigation
          setState(() {
            _isScanning = false;
          });
          Navigator.pushNamed(context, '/equipment_detail', arguments: {'equipment': found})
              .then((_) {
            // resume scanning when user returns
            if (mounted) setState(() => _isScanning = true);
          });
        }

        // Log scan event (non-blocking)
        try {
          await provider.logScan(equipmentId: found['id']?.toString() ?? '', scannedBy: 'system', rawValue: code, action: 'scan');
        } catch (_) {}
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Scan error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    setState(() => _processing = true);
    try {
      final provider = Provider.of<EquipmentProvider>(context, listen: false);
      await provider.updateStatus(id, newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Equipment updated: $newStatus')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _showManualEntryDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Enter QR code or equipment id'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Paste QR payload or equipment id'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final code = controller.text.trim();
              if (code.isEmpty) return;
              Navigator.pop(c);
              if (!mounted) return;
              setState(() => _processing = true);
              try {
                final provider = Provider.of<EquipmentProvider>(context, listen: false);
                final found = await provider.findByQrValue(code);
                // Log manual lookup
                try {
                  await provider.logScan(equipmentId: found?['id']?.toString() ?? '', scannedBy: 'manual', rawValue: code, action: 'manual_lookup');
                } catch (_) {}
                if (found == null) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No equipment found for that code')));
                  if (mounted) setState(() => _isScanning = true);
                } else {
                  // Navigate to equipment detail page for consistency with scanner
                  if (mounted) {
                    setState(() => _isScanning = false);
                    Navigator.pushNamed(context, '/equipment_detail', arguments: {'equipment': found})
                        .then((_) {
                      if (mounted) setState(() => _isScanning = true);
                    });
                  }
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lookup failed: $e')));
              } finally {
                if (mounted) setState(() => _processing = false);
              }
            },
            child: const Text('Lookup'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Equipment QR'),
        actions: [
          IconButton(
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              _controller.toggleTorch();
              setState(() => _flashOn = !_flashOn);
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),
          if (_processing)
            const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                          Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_lastScan == null ? 'Point camera at QR code' : 'Last: $_lastScan'),
                          const SizedBox(height: 8),
                          Text('Scanning: ${_isScanning ? 'ON' : 'OFF'}'),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Enter Code Manually'),
                        onPressed: () => _showManualEntryDialog(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.qr_code),
                      label: const Text('Copy Sample QR'),
                      onPressed: () {
                        final sample = samplePayload();
                        Clipboard.setData(ClipboardData(text: sample));
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sample QR payload copied')));
                      },
                    ),
                    if (kDebugMode) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Seed sample equipment (debug)',
                        icon: const Icon(Icons.cloud_upload),
                        onPressed: () async {
                          try {
                            await seedSampleEquipment();
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeded sample equipment')));
                          } catch (e) {
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Seeding failed: $e')));
                          }
                        },
                      )
                    ]
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

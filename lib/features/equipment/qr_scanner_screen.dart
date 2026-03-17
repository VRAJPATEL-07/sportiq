import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../providers/equipment_provider.dart';
import 'dev_seed.dart';
import 'qr_payload.dart';

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
  final ImagePicker _imagePicker = ImagePicker();

  MobileScannerController? _controller;
  bool get _supportsLiveCamera {
    if (kIsWeb) return true;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
  }

  @override
  void initState() {
    super.initState();
    if (_supportsLiveCamera) {
      _controller = MobileScannerController();
      _requestCameraPermission();
    }
  }

  Future<void> _requestCameraPermission() async {
    if (kIsWeb) return;
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

    await _processCode(code, scannedBy: 'system', action: 'scan');
  }

  Future<void> _processCode(
    String code, {
    required String scannedBy,
    required String action,
  }) async {
    if (_processing) return;

    setState(() {
      _isScanning = false;
      _processing = true;
      _lastScan = code;
    });

    try {
      final provider = Provider.of<EquipmentProvider>(context, listen: false);
      final found = await provider.findByQrValue(code);
      if (found == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No equipment found for this QR code')),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
          Navigator.pushNamed(
            context,
            '/equipment_detail',
            arguments: {'equipment': found},
          ).then((_) {
            if (mounted) setState(() => _isScanning = true);
          });
        }

        try {
          await provider.logScan(
            equipmentId: found['id']?.toString() ?? '',
            scannedBy: scannedBy,
            rawValue: code,
            action: action,
          );
        } catch (_) {}
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
          if (_lastScan == code) {
            _isScanning = true;
          }
        });
      }
    }
  }

  Future<void> _scanFromImage() async {
    if (_processing) return;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (!mounted || image == null) return;

      final MobileScannerController controller =
          _controller ?? MobileScannerController(autoStart: false);
      final BarcodeCapture? capture = await controller.analyzeImage(image.path);
      final String? code = capture?.barcodes.isNotEmpty == true
          ? capture!.barcodes.first.rawValue
          : null;

      if (code == null || code.isEmpty) {
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('No QR code found in the selected image')),
          );
        }
        return;
      }

      await _processCode(code, scannedBy: 'image', action: 'image_scan');
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Image scan failed: $e')),
        );
      }
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
              await _processCode(code, scannedBy: 'manual', action: 'manual_lookup');
            },
            child: const Text('Lookup'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
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
            onPressed: _supportsLiveCamera
                ? () {
                    _controller?.toggleTorch();
                    setState(() => _flashOn = !_flashOn);
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_supportsLiveCamera)
            MobileScanner(
              controller: _controller!,
              onDetect: _handleBarcode,
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_2,
                      size: 96,
                      color: Colors.blue.shade300,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Live camera scanning is not available on this platform.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You can still scan a QR code by selecting an image or entering the code manually.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
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
                          Text(
                            _lastScan == null
                                ? (_supportsLiveCamera
                                    ? 'Point camera at QR code'
                                    : 'Choose a QR image or enter a code manually')
                                : 'Last: $_lastScan',
                          ),
                          const SizedBox(height: 8),
                          Text('Scanning: ${_isScanning && _supportsLiveCamera ? 'ON' : 'OFF'}'),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Enter Code Manually'),
                      onPressed: _showManualEntryDialog,
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.image_search),
                      label: const Text('Scan From Image'),
                      onPressed: _scanFromImage,
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.qr_code),
                      label: const Text('Copy Sample QR'),
                      onPressed: () {
                        final sample = samplePayload();
                        Clipboard.setData(ClipboardData(text: sample));
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sample QR payload copied')),
                          );
                        }
                      },
                    ),
                    if (kDebugMode)
                      IconButton(
                        tooltip: 'Seed sample equipment (debug)',
                        icon: const Icon(Icons.cloud_upload),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await seedSampleEquipment();
                            if (mounted) {
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Seeded sample equipment')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(content: Text('Seeding failed: $e')),
                              );
                            }
                          }
                        },
                      ),
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

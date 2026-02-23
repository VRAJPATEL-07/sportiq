import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../providers/equipment_provider.dart';

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
        final id = found['id']?.toString() ?? '';
        final name = found['name']?.toString() ?? 'Unknown';
        final status = found['status']?.toString() ?? 'Unknown';
        if (mounted) _showEquipmentDialog(id, name, status);
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

  void _showEquipmentDialog(String id, String name, String status) {
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(name),
        content: Text('Status: $status'),
        actions: [
          if (status == 'Available')
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(c);
                await _updateStatus(id, 'Borrowed');
              },
              child: const Text('Issue Equipment'),
            ),
          if (status == 'Borrowed')
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(c);
                await _updateStatus(id, 'Available');
              },
              child: const Text('Return Equipment'),
            ),
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close')),
        ],
      ),
    ).then((_) {
      // re-enable scanning
      if (mounted) setState(() => _isScanning = true);
    });
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
            child: Card(
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
          ),
        ],
      ),
    );
  }
}

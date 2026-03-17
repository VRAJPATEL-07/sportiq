import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _last;
  bool _saving = false;

  // Desktop platforms don't support ImageSource.camera via image_picker
  bool get _isDesktop => !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  Future<void> _capture() async {
    final messenger = ScaffoldMessenger.of(context);

    if (_isDesktop) {
      // On desktop, use file picker dialog instead of camera
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (!mounted) return;
      if (picked != null) setState(() => _last = picked);
      return;
    }

    final status = await Permission.camera.request();
    if (!mounted) return;
    if (!status.isGranted) {
      messenger.showSnackBar(const SnackBar(content: Text('Camera permission denied')));
      return;
    }

    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (!mounted) return;
    if (picked != null) setState(() => _last = picked);
  }

  Future<void> _save() async {
    if (_last == null) return;
    setState(() => _saving = true);
    // Capture messenger before async gap
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await _last!.readAsBytes();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/sportiq_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Saved to app documents')));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isDesktop ? 'Pick Image' : 'Camera')),
      body: Column(children: [
        Expanded(
          child: Center(
            child: _last == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isDesktop ? Icons.folder_open : Icons.camera_alt,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isDesktop ? 'Click "Pick Image" to select a file' : 'No photo yet',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  )
                : kIsWeb
                    ? Image.network(_last!.path)
                    : Image.file(File(_last!.path)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            ElevatedButton.icon(
              onPressed: _capture,
              icon: Icon(_isDesktop ? Icons.folder_open : Icons.camera),
              label: Text(_isDesktop ? 'Pick Image' : 'Capture'),
            ),
            ElevatedButton.icon(onPressed: () => setState(() => _last = null), icon: const Icon(Icons.refresh), label: const Text('Retake')),
            ElevatedButton.icon(onPressed: _saving ? null : _save, icon: const Icon(Icons.save), label: const Text('Save')),
          ]),
        )
      ]),
    );
  }
}

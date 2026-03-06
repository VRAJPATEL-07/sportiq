import 'dart:io';
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

  Future<void> _capture() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera permission denied')));
      return;
    }

    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked != null) setState(() => _last = picked);
  }

  Future<void> _save() async {
    if (_last == null) return;
    setState(() => _saving = true);
    try {
      final bytes = await _last!.readAsBytes();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/sportiq_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(bytes);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to app documents')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: Column(children: [
        Expanded(child: Center(child: _last == null ? const Text('No photo yet') : Image.file(File(_last!.path)))),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            ElevatedButton.icon(onPressed: _capture, icon: const Icon(Icons.camera), label: const Text('Capture')),
            ElevatedButton.icon(onPressed: () => setState(() => _last = null), icon: const Icon(Icons.refresh), label: const Text('Retake')),
            ElevatedButton.icon(onPressed: _saving ? null : _save, icon: const Icon(Icons.save), label: const Text('Save')),
          ]),
        )
      ]),
    );
  }
}

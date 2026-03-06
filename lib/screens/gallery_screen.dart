import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/image_files_provider.dart';
import '../widgets/image_grid.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> pickMultiple() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gallery permission denied')));
      return;
    }

    try {
      final List<XFile>? picked = await _picker.pickMultiImage(imageQuality: 85);
      if (picked != null && picked.isNotEmpty) {
        final files = picked.map((x) => File(x.path)).toList();
        Provider.of<ImageFilesProvider>(context, listen: false).addAll(files);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking images: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ImageFilesProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: [
            ElevatedButton.icon(onPressed: pickMultiple, icon: const Icon(Icons.photo_library), label: const Text('Pick images')),
            const SizedBox(width: 8),
            ElevatedButton.icon(onPressed: provider.clear, icon: const Icon(Icons.clear), label: const Text('Clear')),
          ]),
        ),
        Expanded(child: ImageGrid(files: provider.files)),
      ]),
    );
  }
}

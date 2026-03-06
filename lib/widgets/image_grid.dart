import 'dart:io';
import 'package:flutter/material.dart';

class ImageGrid extends StatelessWidget {
  final List<File> files;

  const ImageGrid({super.key, required this.files});

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return const Center(child: Text('No images selected'));
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 6, mainAxisSpacing: 6),
      itemCount: files.length,
      itemBuilder: (context, i) => GestureDetector(
        onTap: () => showDialog(context: context, builder: (_) => Dialog(child: Image.file(files[i]))),
        child: Image.file(files[i], fit: BoxFit.cover),
      ),
    );
  }
}

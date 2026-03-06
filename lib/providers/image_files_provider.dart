import 'dart:io';
import 'package:flutter/material.dart';

class ImageFilesProvider extends ChangeNotifier {
  final List<File> files = [];

  void add(File f) {
    files.add(f);
    notifyListeners();
  }

  void addAll(List<File> list) {
    files.addAll(list);
    notifyListeners();
  }

  void clear() {
    files.clear();
    notifyListeners();
  }
}

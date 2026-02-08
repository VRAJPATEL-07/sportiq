import 'dart:async';

import 'package:flutter/material.dart';

/// Simple in-memory mock EquipmentProvider used when Firestore is unavailable.
class MockEquipmentProvider extends ChangeNotifier {
  MockEquipmentProvider._private() {
    _initializeDefaultData();
  }

  static final MockEquipmentProvider instance = MockEquipmentProvider._private();

  final List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  void _initializeDefaultData() {
    _items.addAll([
      {
        'id': '1',
        'name': 'Football',
        'category': 'Ball Sports',
        'quantity': 10,
        'available': 7,
        'status': 'available',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '2',
        'name': 'Basketball',
        'category': 'Ball Sports',
        'quantity': 8,
        'available': 5,
        'status': 'available',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '3',
        'name': 'Tennis Racket',
        'category': 'Racket Sports',
        'quantity': 6,
        'available': 4,
        'status': 'available',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '4',
        'name': 'Badminton Set',
        'category': 'Racket Sports',
        'quantity': 5,
        'available': 3,
        'status': 'available',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '5',
        'name': 'Volleyball',
        'category': 'Ball Sports',
        'quantity': 7,
        'available': 6,
        'status': 'available',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '6',
        'name': 'Cricket Bat',
        'category': 'Bat Sports',
        'quantity': 4,
        'available': 2,
        'status': 'available',
        'createdAt': DateTime.now().toIso8601String(),
      },
    ]);
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> addEquipment({required String name, required String category, required int quantity, String status = 'available'}) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 200));
    _items.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'category': category,
      'quantity': quantity,
      'status': status,
      'createdAt': DateTime.now().toIso8601String(),
    });
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateEquipment({required String id, String? name, String? category, int? quantity, String? status}) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = _items.indexWhere((e) => e['id'] == id);
    if (idx >= 0) {
      final item = Map<String, dynamic>.from(_items[idx]);
      if (name != null) item['name'] = name;
      if (category != null) item['category'] = category;
      if (quantity != null) item['quantity'] = quantity;
      if (status != null) item['status'] = status;
      item['updatedAt'] = DateTime.now().toIso8601String();
      _items[idx] = item;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteEquipment({required String id}) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 100));
    _items.removeWhere((e) => e['id'] == id);
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

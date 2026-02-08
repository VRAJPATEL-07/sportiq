import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// EquipmentProvider: listens to `equipment` collection and exposes CRUD methods.
/// Keep reads/writes minimal to remain within Firebase Spark free tier.
class EquipmentProvider extends ChangeNotifier {
  EquipmentProvider._private() {
    try {
      _listen();
    } catch (e) {
      // Firebase not initialized; skip listen. Mock will be used instead.
    }
  }

  static final EquipmentProvider instance = EquipmentProvider._private();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  final List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _listen() {
    _sub = _firestore.collection('equipment').orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      _items.clear();
      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        _items.add(data);
      }
      notifyListeners();
    }, onError: (err) {
      // Log or handle errors appropriately by consumers
    });
  }

  Future<void> addEquipment({required String name, required String category, required int quantity, String status = 'available'}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore.collection('equipment').add({
        'name': name,
        'category': category,
        'quantity': quantity,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateEquipment({required String id, String? name, String? category, int? quantity, String? status}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (category != null) data['category'] = category;
      if (quantity != null) data['quantity'] = quantity;
      if (status != null) data['status'] = status;
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('equipment').doc(id).update(data);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEquipment({required String id}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore.collection('equipment').doc(id).delete();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

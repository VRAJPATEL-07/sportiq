import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import '../features/equipment/dev_seed.dart';

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
      
      // Auto-seed if collection is empty
      if (_items.isEmpty) {
        print('📦 Equipment collection empty. Auto-seeding demo data...');
        seedSampleEquipment().then((_) {
          print('✅ Demo equipment seeded successfully');
        }).catchError((e) {
          print('❌ Auto-seed failed: $e');
        });
      }
      
      notifyListeners();
    }, onError: (err) {
      // Log or handle errors appropriately by consumers
      print('❌ Equipment collection error: $err');
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

  /// Find equipment by a scanned QR value. The QR value is expected to match
  /// either the document id, an `equipmentId` field, or `qrCodeValue` field.
  /// Also parses JSON QR payloads to extract equipmentId.
  Future<Map<String, dynamic>?> findByQrValue(String qrValue) async {
    // Try to parse QR value as JSON and extract equipmentId
    String? extractedEquipmentId;
    try {
      final decoded = jsonDecode(qrValue) as Map;
      extractedEquipmentId = decoded['equipmentId']?.toString();
      print('DEBUG: Parsed QR JSON, extracted equipmentId: $extractedEquipmentId');
    } catch (e) {
      print('DEBUG: QR value is not JSON, will use raw value: $qrValue');
    }

    // Build list of search values
    final searchValues = <String>{qrValue};
    if (extractedEquipmentId != null) {
      searchValues.add(extractedEquipmentId);
    }

    // First try local cache with all search values
    try {
      for (final searchValue in searchValues) {
        final cached = _items.firstWhere((m) {
          final eqId = m['equipmentId']?.toString();
          final qr = m['qrCodeValue']?.toString();
          final docId = m['id']?.toString();
          return searchValue == eqId || searchValue == qr || searchValue == docId;
        }, orElse: () => {});
        if (cached.isNotEmpty) {
          print('DEBUG: Found equipment in cache: ${cached['equipmentId']}');
          return Map<String, dynamic>.from(cached);
        }
      }
    } catch (_) {}

    // Fallback to Firestore query with all search values
    try {
      for (final searchValue in searchValues) {
        // Try by equipmentId
        final byEquip = await _firestore.collection('equipment').where('equipmentId', isEqualTo: searchValue).limit(1).get();
        if (byEquip.docs.isNotEmpty) {
          final d = byEquip.docs.first;
          final data = Map<String, dynamic>.from(d.data());
          data['id'] = d.id;
          print('DEBUG: Found equipment by equipmentId in Firestore: $searchValue');
          return data;
        }

        // Try by qrCodeValue (exact match)
        final byQr = await _firestore.collection('equipment').where('qrCodeValue', isEqualTo: searchValue).limit(1).get();
        if (byQr.docs.isNotEmpty) {
          final d = byQr.docs.first;
          final data = Map<String, dynamic>.from(d.data());
          data['id'] = d.id;
          print('DEBUG: Found equipment by qrCodeValue in Firestore: $searchValue');
          return data;
        }

        // Try matching document id
        final doc = await _firestore.collection('equipment').doc(searchValue).get();
        if (doc.exists) {
          final data = Map<String, dynamic>.from(doc.data()!);
          data['id'] = doc.id;
          print('DEBUG: Found equipment by document ID in Firestore: $searchValue');
          return data;
        }
      }
    } catch (e) {
      print('DEBUG: Firestore query error: $e');
      rethrow;
    }
    
    print('DEBUG: No equipment found for any search values: $searchValues');
    return null;
  }

  /// Convenience wrapper to update only status field.
  Future<void> updateStatus(String id, String status) async {
    await updateEquipment(id: id, status: status);
  }

  /// Log a scan event to Firestore for audit/history.
  Future<void> logScan({required String equipmentId, required String scannedBy, required String rawValue, String action = 'view'}) async {
    try {
      await _firestore.collection('scan_history').add({
        'equipmentId': equipmentId,
        'scannedBy': scannedBy,
        'rawValue': rawValue,
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Stream of recent scan history entries. Consumers can listen to this to
  /// display recent scans.
  Stream<List<Map<String, dynamic>>> scanHistoryStream({int limit = 50}) {
    return _firestore.collection('scan_history').orderBy('timestamp', descending: true).limit(limit).snapshots().map((snap) {
      return snap.docs.map((d) {
        final m = Map<String, dynamic>.from(d.data());
        m['id'] = d.id;
        return m;
      }).toList();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import '../features/equipment/dev_seed.dart';

/// EquipmentProvider: listens to `equipment` collection and exposes CRUD methods.
/// Keep reads/writes minimal to remain within Firebase Spark free tier.
class EquipmentProvider extends ChangeNotifier {
  EquipmentProvider._private() {
  }

  static final EquipmentProvider instance = EquipmentProvider._private();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  bool _started = false;

  final List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Exposed so UI can show a friendly error when Firestore rules block access
  String? _error;
  String? get error => _error;

  void ensureListening() {
    if (_started) return;
    _started = true;
    try {
      _listen();
    } catch (e) {
      _started = false;
      debugPrint('❌ EquipmentProvider listen failed: $e');
    }
  }

  void _listen() {
    _sub = _firestore.collection('equipment').orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      _error = null;
      _items.clear();
      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        _items.add(data);
      }
      
      notifyListeners();
    }, onError: (err) {
      debugPrint('❌ Equipment collection error: $err');
      final msg = err.toString();
      if (msg.contains('permission-denied')) {
        _error = 'Access denied. Please check your Firestore security rules in the Firebase console.';
      } else {
        _error = 'Failed to load equipment: $msg';
      }
      notifyListeners();
    });
  }

  Future<void> addEquipment({required String name, required String category, required int quantity, String status = 'available', String? description, double? penalty}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore.collection('equipment').add({
        'name': name,
        'category': category,
        'quantity': quantity,
        'status': status,
        if (description != null && description.isNotEmpty) 'description': description,
        if (penalty != null) 'penalty': penalty,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateEquipment({required String id, String? name, String? category, int? quantity, String? status, String? description, double? penalty}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (category != null) data['category'] = category;
      if (quantity != null) data['quantity'] = quantity;
      if (status != null) data['status'] = status;
      if (description != null) data['description'] = description;
      if (penalty != null) data['penalty'] = penalty;
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
      debugPrint('DEBUG: Parsed QR JSON, extracted equipmentId: $extractedEquipmentId');
    } catch (e) {
      debugPrint('DEBUG: QR value is not JSON, will use raw value: $qrValue');
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
          debugPrint('DEBUG: Found equipment in cache: ${cached['equipmentId']}');
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
          debugPrint('DEBUG: Found equipment by equipmentId in Firestore: $searchValue');
          return data;
        }

        // Try by qrCodeValue (exact match)
        final byQr = await _firestore.collection('equipment').where('qrCodeValue', isEqualTo: searchValue).limit(1).get();
        if (byQr.docs.isNotEmpty) {
          final d = byQr.docs.first;
          final data = Map<String, dynamic>.from(d.data());
          data['id'] = d.id;
          debugPrint('DEBUG: Found equipment by qrCodeValue in Firestore: $searchValue');
          return data;
        }

        // Try matching document id
        final doc = await _firestore.collection('equipment').doc(searchValue).get();
        if (doc.exists) {
          final data = Map<String, dynamic>.from(doc.data()!);
          data['id'] = doc.id;
          debugPrint('DEBUG: Found equipment by document ID in Firestore: $searchValue');
          return data;
        }
      }
    } catch (e) {
      debugPrint('DEBUG: Firestore query error: $e');
      rethrow;
    }
    
    debugPrint('DEBUG: No equipment found for any search values: $searchValues');
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

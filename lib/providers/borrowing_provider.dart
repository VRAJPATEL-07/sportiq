import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// BorrowingProvider: Manages borrowed items for the current user
/// Listens to Firestore `borrowings` collection in real-time
class BorrowingProvider extends ChangeNotifier {
  BorrowingProvider._private();

  static final BorrowingProvider instance = BorrowingProvider._private();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  final List<Map<String, dynamic>> _borrowedItems = [];
  List<Map<String, dynamic>> get borrowedItems => List.unmodifiable(_borrowedItems);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Initialize listener for current user's borrowed items
  void initializeForUser(String userId) {
    // Cancel previous subscription
    _sub?.cancel();

    // Prefer per-user subcollection to avoid composite index requirements.
    // Path: users/{userId}/borrowings
    try {
      _sub = _firestore
          .collection('users')
          .doc(userId)
          .collection('borrowings')
          .orderBy('borrowDate', descending: true)
          .snapshots()
          .listen((snapshot) {
        _error = null;
        _borrowedItems.clear();
        for (final doc in snapshot.docs) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          _borrowedItems.add(data);
        }
        debugPrint('📦 Loaded ${_borrowedItems.length} borrowed items for user $userId (subcollection)');
        notifyListeners();
      }, onError: (err) {
        debugPrint('❌ Borrowings subcollection error: $err');
        _error = 'Failed to load borrowed items: $err';
        notifyListeners();
      });
    } catch (e) {
      // Fallback: attempt to listen to top-level collection (may require index)
      debugPrint('⚠️ Subcollection read failed, falling back to top-level query: $e');
      _sub = _firestore
          .collection('borrowings')
          .where('userId', isEqualTo: userId)
          .orderBy('borrowDate', descending: true)
          .snapshots()
          .listen((snapshot) {
        _error = null;
        _borrowedItems.clear();
        for (final doc in snapshot.docs) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          _borrowedItems.add(data);
        }
        debugPrint('📦 Loaded ${_borrowedItems.length} borrowed items for user $userId (fallback)');
        notifyListeners();
      }, onError: (err) {
        debugPrint('❌ Borrowings collection error (fallback): $err');
        _error = 'Failed to load borrowed items: $err';
        notifyListeners();
      });
    }
  }

  /// Add a new borrowing record to Firestore
  Future<void> borrowEquipment({
    required String userId,
    required String userName,
    required String equipmentId,
    required String equipmentName,
    required int quantity,
    required DateTime borrowDate,
    required DateTime returnDate,
    required String purpose,
    required double? penalty,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final equipmentRef = _firestore.collection('equipment').doc(equipmentId);
      final borrowingRef = _firestore.collection('borrowings').doc();
      final userBorrowRef = _firestore.collection('users').doc(userId).collection('borrowings').doc(borrowingRef.id);

      await _firestore.runTransaction((transaction) async {
        final equipmentSnap = await transaction.get(equipmentRef);
        if (!equipmentSnap.exists) {
          throw StateError('Equipment not found');
        }

        final equipmentData = equipmentSnap.data() ?? <String, dynamic>{};
        final totalQuantity = (equipmentData['quantity'] as num?)?.toInt() ?? quantity;
        final currentAvailable = (equipmentData['available'] as num?)?.toInt() ?? totalQuantity;
        if (quantity <= 0) {
          throw StateError('Invalid quantity');
        }
        if (currentAvailable < quantity) {
          throw StateError('Not enough equipment available');
        }

        final remaining = currentAvailable - quantity;
        final borrowingData = {
          'userId': userId,
          'userName': userName,
          'equipmentId': equipmentId,
          'equipmentName': equipmentName,
          'quantity': quantity,
          'borrowDate': borrowDate,
          'returnDate': returnDate,
          'purpose': purpose,
          'status': 'borrowed',
          'penalty': penalty,
          'createdAt': FieldValue.serverTimestamp(),
        };

        debugPrint('📊 Borrowing Data to write: userName=$userName, equipmentName=$equipmentName, userId=$userId');
        transaction.set(borrowingRef, borrowingData);
        transaction.set(userBorrowRef, borrowingData);
        transaction.update(equipmentRef, {
          'available': remaining,
          'status': remaining > 0 ? 'available' : 'borrowed',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      debugPrint('✅ Equipment borrowed: $equipmentName by $userName');
    } catch (e) {
      debugPrint('❌ Failed to borrow equipment: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Return borrowed equipment: moves item to user's history and updates top-level doc.
  Future<void> returnEquipment({required String borrowingId, String? userId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final update = {
        'status': 'returned',
        'returnedAt': FieldValue.serverTimestamp(),
      };

      final topRef = _firestore.collection('borrowings').doc(borrowingId);
      final topSnap = await topRef.get();
      if (!topSnap.exists) {
        throw StateError('Borrowing record not found');
      }

      final topData = Map<String, dynamic>.from(topSnap.data() ?? {});

      // Determine userId: prefer provided, otherwise try top-level doc
      String? uid = userId;
      if ((uid == null || uid.isEmpty) && topData['userId'] != null) {
        uid = topData['userId'].toString();
      }

      final equipmentId = topData['equipmentId']?.toString();
      final quantity = (topData['quantity'] as num?)?.toInt() ?? 1;

      if (uid != null && uid.isNotEmpty) {
        final userBorrowRef = _firestore.collection('users').doc(uid).collection('borrowings').doc(borrowingId);
        final userSnap = await userBorrowRef.get();
        final sourceData = userSnap.exists
            ? Map<String, dynamic>.from(userSnap.data() ?? {})
            : topData;

        final historyData = {
          ...sourceData,
          ...update,
          'movedAt': FieldValue.serverTimestamp(),
        };
        final historyRef = _firestore.collection('users').doc(uid).collection('borrowings_history').doc(borrowingId);

        final batch = _firestore.batch();
        batch.set(historyRef, historyData);
        if (userSnap.exists) {
          batch.delete(userBorrowRef);
        }
        batch.update(topRef, update);

        if (equipmentId != null && equipmentId.isNotEmpty) {
          final equipmentRef = _firestore.collection('equipment').doc(equipmentId);
          final equipmentSnap = await equipmentRef.get();
          if (equipmentSnap.exists) {
            final equipmentData = equipmentSnap.data() ?? <String, dynamic>{};
            final totalQuantity = (equipmentData['quantity'] as num?)?.toInt() ?? ((equipmentData['available'] as num?)?.toInt() ?? quantity);
            final currentAvailable = (equipmentData['available'] as num?)?.toInt() ?? 0;
            final restored = (currentAvailable + quantity).clamp(0, totalQuantity).toInt();
            batch.update(equipmentRef, {
              'available': restored,
              'status': restored > 0 ? 'available' : 'borrowed',
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }

        await batch.commit();
      }

      debugPrint('✅ Equipment returned and moved to history: $borrowingId');
    } catch (e) {
      debugPrint('❌ Failed to return equipment: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if item is overdue
  bool isOverdue(DateTime returnDate) {
    return DateTime.now().isAfter(returnDate);
  }

  /// Calculate days until due
  int daysUntilDue(DateTime returnDate) {
    return returnDate.difference(DateTime.now()).inDays;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

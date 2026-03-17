import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'qr_payload.dart';

/// Seeds sample equipment documents for testing.
/// Creates a realistic demo set with various sports equipment.
Future<void> seedSampleEquipment() async {
  final firestore = FirebaseFirestore.instance;
  
  final demoEquipment = [
    {
      'equipmentId': 'EQ-0001',
      'name': 'Basketball',
      'category': 'Ball Sports',
      'quantity': 10,
      'status': 'Available',
      'description': 'Official size basketball for training and matches',
      'qrCodeValue': generateQrPayload('EQ-0001'),
    },
    {
      'equipmentId': 'EQ-0002',
      'name': 'Soccer Ball',
      'category': 'Ball Sports',
      'quantity': 15,
      'status': 'Available',
      'description': 'Professional soccer ball',
      'qrCodeValue': generateQrPayload('EQ-0002'),
    },
    {
      'equipmentId': 'EQ-0003',
      'name': 'Tennis Racket',
      'category': 'Racket Sports',
      'quantity': 8,
      'status': 'Borrowed',
      'description': 'Graphite tennis racket with grip',
      'qrCodeValue': generateQrPayload('EQ-0003'),
    },
    {
      'equipmentId': 'EQ-0004',
      'name': 'Badminton Shuttlecock (Tube)',
      'category': 'Racket Sports',
      'quantity': 50,
      'status': 'Available',
      'description': 'Pack of 12 shuttlecocks',
      'qrCodeValue': generateQrPayload('EQ-0004'),
    },
    {
      'equipmentId': 'EQ-0005',
      'name': 'Volleyball',
      'category': 'Ball Sports',
      'quantity': 6,
      'status': 'Available',
      'description': 'Official volleyball for indoor use',
      'qrCodeValue': generateQrPayload('EQ-0005'),
    },
    {
      'equipmentId': 'EQ-0006',
      'name': 'Cricket Bat',
      'category': 'Bat Sports',
      'quantity': 5,
      'status': 'Available',
      'description': 'Wooden cricket bat for practice',
      'qrCodeValue': generateQrPayload('EQ-0006'),
    },
    {
      'equipmentId': 'EQ-0007',
      'name': 'Yoga Mat',
      'category': 'Fitness',
      'quantity': 20,
      'status': 'Available',
      'description': 'Non-slip yoga mat for fitness classes',
      'qrCodeValue': generateQrPayload('EQ-0007'),
    },
    {
      'equipmentId': 'EQ-0008',
      'name': 'Dumbbells Set (5kg-25kg)',
      'category': 'Fitness',
      'quantity': 3,
      'status': 'Borrowed',
      'description': 'Set of adjustable dumbbells',
      'qrCodeValue': generateQrPayload('EQ-0008'),
    },
  ];

  for (final item in demoEquipment) {
    try {
      // Check if equipment already exists by equipmentId
      final existing = await firestore
          .collection('equipment')
          .where('equipmentId', isEqualTo: item['equipmentId'])
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        // Update existing
        await firestore
            .collection('equipment')
            .doc(existing.docs.first.id)
            .update({...item, 'updatedAt': FieldValue.serverTimestamp()});
      } else {
        // Create new
        await firestore.collection('equipment').add({
          ...item,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error seeding ${item['equipmentId']}: $e');
      rethrow;
    }
  }
}

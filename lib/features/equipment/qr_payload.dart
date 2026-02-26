import 'dart:convert';

/// Generates a compact QR payload string for equipment.
/// Current format: JSON with `equipmentId`, `v` (version), and `ts` (unix seconds).
String generateQrPayload(String equipmentId) {
  final map = {
    'equipmentId': equipmentId,
    'v': 1,
    'ts': DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
  };
  return jsonEncode(map);
}

/// Example payload for equipment `EQ-0001`.
String samplePayload() => generateQrPayload('EQ-0001');

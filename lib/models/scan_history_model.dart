import 'package:cloud_firestore/cloud_firestore.dart';

class ScanHistoryModel {
  final String id;
  final String targetName;
  final bool isSafe;
  final String scanType;
  final DateTime timestamp;
  final Map<String, dynamic>? vendorResults;
  final int maliciousCount;
  final int totalEngines;

  ScanHistoryModel({
    required this.id,
    required this.targetName,
    required this.isSafe,
    required this.scanType,
    required this.timestamp,
    this.vendorResults,
    this.maliciousCount = 0,
    this.totalEngines = 0,
  });

  // แปลงจาก Map (Firestore) เป็น Model
  factory ScanHistoryModel.fromMap(String id, Map<String, dynamic> data) {
    return ScanHistoryModel(
      id: id,
      targetName: data['targetName'] ?? 'Unknown',
      isSafe: data['isSafe'] ?? false,
      scanType: data['scanType'] ?? 'unknown',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      vendorResults: data['vendorResults'] as Map<String, dynamic>?,
      maliciousCount: data['maliciousCount'] ?? 0,
      totalEngines: data['totalEngines'] ?? 0,
    );
  }

  // แปลงจาก Model กลับเป็น Map (เพื่อเซฟลง Firestore)
  Map<String, dynamic> toMap() {
    return {
      'targetName': targetName,
      'isSafe': isSafe,
      'scanType': scanType,
      'timestamp': FieldValue.serverTimestamp(),
      'vendorResults': vendorResults,
      'maliciousCount': maliciousCount,
      'totalEngines': totalEngines,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import '../core/failure.dart';
import '../models/scan_history_model.dart';

class FirestoreService {
  // Singleton pattern
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. ฟังก์ชันบันทึกประวัติ (เรียกใช้ตอนสแกนเสร็จ)
  Future<Either<Failure, void>> saveScanResult(
    ScanHistoryModel historyItem,
  ) async {
    final user = _auth.currentUser;
    // ถ้าเป็น Guest (ไม่ได้ล็อกอิน) ก็ไม่ต้องทำอะไร ปล่อยผ่านไปเลย
    if (user == null) return const Right(null);

    try {
      // บันทึกลงใน Collection: users -> [UID] -> scan_history
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('scan_history')
          .add(historyItem.toMap());
      return const Right(null);
    } catch (e) {
      return Left(Failure("Error saving history: $e"));
    }
  }

  // 2. ฟังก์ชันดึงประวัติแบบ Real-time เป็น Model List (ใช้ในหน้า Dashboard)
  Stream<List<ScanHistoryModel>> getUserHistoryStream({
    bool descending = true,
  }) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    // ดึงข้อมูลเรียงลำดับตามตัวแปร descending แล้วแมปเป็น Model
    return _db
        .collection('users')
        .doc(user.uid)
        .collection('scan_history')
        .orderBy('timestamp', descending: descending)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ScanHistoryModel.fromMap(doc.id, doc.data());
          }).toList();
        });
  }
}

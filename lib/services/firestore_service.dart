import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. ฟังก์ชันบันทึกประวัติ (เรียกใช้ตอนสแกนเสร็จ)
  Future<void> saveScanResult({
    required String targetName,
    required bool isSafe,
    required String scanType, // ใส่ค่า 'url' หรือ 'file'
  }) async {
    final user = _auth.currentUser;
    // ถ้าเป็น Guest (ไม่ได้ล็อกอิน) ก็ไม่ต้องทำอะไร ปล่อยผ่านไปเลย
    if (user == null) return;

    try {
      // บันทึกลงใน Collection: users -> [UID] -> scan_history
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('scan_history')
          .add({
            'targetName': targetName,
            'isSafe': isSafe,
            'scanType': scanType,
            'timestamp': FieldValue.serverTimestamp(), // ประทับเวลาจาก Server
          });
      print("History saved to cloud!");
    } catch (e) {
      print("Error saving history: $e");
    }
  }

  // 2. ฟังก์ชันดึงประวัติแบบ Real-time (ใช้ในหน้า Dashboard)
  Stream<QuerySnapshot> getUserHistoryStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    // ดึงข้อมูลเรียงจากล่าสุด (descending: true) ไปหาเก่าสุด
    return _db
        .collection('users')
        .doc(user.uid)
        .collection('scan_history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}

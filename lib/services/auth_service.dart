import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. สมัครสมาชิก (Sign Up)
  Future<String?> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
      User? user = userCredential.user;
      if (user != null) {
        // ใช้ .set() แทน .add() เพราะเราอยากบังคับให้ Document ID ตรงกับ UID ของ Auth เป๊ะๆ
        await _db.collection('users').doc(user.uid).set({
          'name': name.trim(),
          'email': email.trim(),
          'createdAt': FieldValue.serverTimestamp(), // เก็บเวลาที่สมัคร
          'role': 'user', // (Optional) เผื่ออนาคตทำระบบ Admin
        });
      }
      return null; // ถ้าสำเร็จ ให้ return null (ไม่มี Error)
    } on FirebaseAuthException catch (e) {
      // ดักจับ Error แจ้งเตือนผู้ใช้
      if (e.code == 'weak-password')
        return 'The password provided is too weak.';
      if (e.code == 'email-already-in-use')
        return 'The account already exists for that email.';
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // 2. เข้าสู่ระบบ (Sign In)
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // สำเร็จ
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'No user found for that email.';
      if (e.code == 'wrong-password') return 'Wrong password provided.';
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // 3. ออกจากระบบ (Sign Out)
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 4. เช็คว่ามีใคร Login ค้างไว้ไหม (เอาไว้ทำ Auto Login)
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}

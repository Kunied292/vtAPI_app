import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. สมัครสมาชิก (Sign Up)
  Future<String?> signUpWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
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

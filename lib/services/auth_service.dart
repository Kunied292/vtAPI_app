import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dartz/dartz.dart';
import '../core/failure.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. สมัครสมาชิก (Sign Up)
  Future<Either<Failure, User>> signUpWithEmail(
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
        return Right(user);
      } else {
        return Left(Failure("Failed to create user."));
      }
    } on FirebaseAuthException catch (e) {
      // ดักจับ Error แจ้งเตือนผู้ใช้
      if (e.code == 'weak-password') {
        return Left(Failure('The password provided is too weak.'));
      }
      if (e.code == 'email-already-in-use') {
        return Left(Failure('The account already exists for that email.'));
      }
      return Left(Failure(e.message ?? "An error occurred during sign up."));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  // 2. เข้าสู่ระบบ (Sign In)
  Future<Either<Failure, User>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (userCredential.user != null) {
        return Right(userCredential.user!);
      } else {
        return Left(Failure("Login failed unexpectedly."));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return Left(Failure('No user found for that email.'));
      }
      if (e.code == 'wrong-password') {
        return Left(Failure('Wrong password provided.'));
      }
      return Left(Failure(e.message ?? "An error occurred during sign in."));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  // 3. ออกจากระบบ (Sign Out)
  Future<Either<Failure, void>> signOut() async {
    try {
      await _auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(Failure("Failed to sign out: ${e.toString()}"));
    }
  }

  bool _isGoogleSignInInitialized = false;

  Future<String?> signInWithGoogle() async {
    try {
      if (!_isGoogleSignInInitialized) {
        await GoogleSignIn.instance.initialize();
        _isGoogleSignInInitialized = true;
      }

      // 1. เรียกหน้าต่างเด้งขึ้นมาให้เลือกบัญชี Google
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await GoogleSignIn.instance.authenticate();
      } on GoogleSignInException catch (e) {
        // ถ้าผู้ใช้กดยกเลิกกลางคัน ให้จบการทำงาน
        if (e.code == GoogleSignInExceptionCode.canceled) {
          return 'cancelled';
        }
        rethrow; // โยน error อื่นๆ ต่อไป
      }

      // 2. ขอ Token ยืนยันตัวตนจาก Google
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // accessToken is no longer provided during basic authentication in google_sign_in v7+
      );

      // 3. เอา Token ไปล็อกอินเข้า Firebase
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // 4. (พิเศษ) ถ้าเพิ่งเคยล็อกอินครั้งแรก ให้สร้างประวัติลง Firestore ด้วย!
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await _db.collection('users').doc(userCredential.user!.uid).set({
          'name': userCredential.user!.displayName ?? 'GOOGLE USER',
          'email': userCredential.user!.email,
          'photoUrl':
              userCredential.user!.photoURL, // ดึงรูปโปรไฟล์กูเกิลมาให้เลย
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'user',
        });
      }

      return null; // สำเร็จ
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // 4. เช็คว่ามีใคร Login ค้างไว้ไหม (เอาไว้ทำ Auto Login)
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}

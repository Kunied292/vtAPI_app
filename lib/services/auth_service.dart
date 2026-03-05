import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      if (e.code == 'user-not-found')
        return Left(Failure('No user found for that email.'));
      if (e.code == 'wrong-password')
        return Left(Failure('Wrong password provided.'));
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

  // 4. เช็คว่ามีใคร Login ค้างไว้ไหม (เอาไว้ทำ Auto Login)
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}

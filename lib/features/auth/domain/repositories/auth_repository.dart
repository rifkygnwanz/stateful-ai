import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<User?> signInWithGoogle();
  Future<void> signOut();
  Future<User?> getCurrentUser();
}

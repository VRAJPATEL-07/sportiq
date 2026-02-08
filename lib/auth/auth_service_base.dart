import 'package:flutter/material.dart';
import 'auth_state.dart';

/// Abstract base class for auth services (real Firebase or mock).
abstract class IAuthService extends ChangeNotifier {
  Stream<AuthState> get stream;
  AuthState get current;

  Future<AuthState> login({required String email, required String password});
  Future<AuthState> loginWithGoogle();
  Future<AuthState> register({required String name, required String email, required String password, String role = 'student'});
  Future<void> guestLogin();
  Future<void> logout();
  Future<void> sendPasswordResetEmail({required String email});
}

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'auth_service_base.dart';
import 'auth_state.dart';

/// Firebase-backed AuthService.
/// IMPORTANT: This implementation is intended for Firebase Spark (free) plan only.
/// Do NOT enable billing; do not rely on paid services. Keep reads/writes minimal.
class AuthService extends IAuthService {
  AuthService._private() {
    // Avoid attaching Firebase listeners during app startup on desktop.
    // The state is refreshed explicitly on login and can be refreshed later if needed.
    final user = _auth.currentUser;
    if (user != null) {
      _state = AuthState(
        userId: user.uid,
        email: user.email,
        displayName: (user.displayName != null && user.displayName!.trim().isNotEmpty)
            ? user.displayName!.trim()
            : ((user.email?.isNotEmpty ?? false) ? user.email!.split('@').first.toUpperCase() : 'User'),
        role: 'student',
        loggedIn: true,
      );
    }
  }

  static final AuthService instance = AuthService._private();

  late final FirebaseAuth _auth = FirebaseAuth.instance;
  late final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final StreamController<AuthState> _controller = StreamController<AuthState>.broadcast();
  AuthState _state = AuthState.signedOut;

  @override
  Stream<AuthState> get stream => _controller.stream;
  @override
  AuthState get current => _state;

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _state = AuthState.signedOut;
      _controller.add(_state);
      notifyListeners();
      return;
    }

    // Fetch role from Firestore users collection
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      String role = 'student';
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['role'] != null) {
          role = data['role'] as String;
          debugPrint('DEBUG: User role fetched from Firestore: $role');
        } else {
          debugPrint('DEBUG: User document exists but has no role field. Defaulting to student.');
        }
      } else {
        debugPrint('DEBUG: User document not found for ${user.uid}. Creating default student record.');
        try {
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email ?? '',
            'name': user.displayName ?? 'User',
            'role': 'student',
            'createdAt': FieldValue.serverTimestamp(),
            'status': 'active',
          });
          role = 'student';
          // Ensure role is set in Firestore
          await _firestore.collection('users').doc(user.uid).update({'role': 'student'});
        } catch (e) {
          debugPrint('ERROR: Could not create user document: $e');
          // Still continue with student role even if document creation fails
          role = 'student';
        }
      }

      // Ensure displayName is never empty - use email prefix as fallback
      final displayName = (user.displayName != null && user.displayName!.trim().isNotEmpty)
          ? user.displayName!.trim()
          : ((user.email?.isNotEmpty ?? false) ? user.email!.split('@').first.toUpperCase() : 'User');
      
      _state = AuthState(
        userId: user.uid,
        email: user.email,
        displayName: displayName,
        role: role,
        loggedIn: true,
      );
      _controller.add(_state);
      notifyListeners();
    } catch (e) {
      debugPrint('ERROR in _onAuthStateChanged: $e');
      // If Firestore read fails, default to student but still signed in.
      // Ensure displayName is never empty - use email prefix as fallback
      final displayName = (user.displayName != null && user.displayName!.trim().isNotEmpty)
          ? user.displayName!.trim()
          : ((user.email?.isNotEmpty ?? false) ? user.email!.split('@').first.toUpperCase() : 'User');
      
      _state = AuthState(
        userId: user.uid,
        email: user.email,
        displayName: displayName,
        role: 'student',
        loggedIn: true,
      );
      _controller.add(_state);
      notifyListeners();
    }
  }

  /// Login with email & password, then fetch role from Firestore.
  @override
  Future<AuthState> login({required String email, required String password}) async {
    try {
      debugPrint('DEBUG: Attempting login for email: $email');
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = cred.user;
      if (user == null) throw FirebaseAuthException(code: 'NO_USER', message: 'No user returned');

      debugPrint('DEBUG: Firebase auth successful for user: ${user.uid}');
      
      // _onAuthStateChanged will set state, but ensure we return latest state
      await _onAuthStateChanged(user);
      
      debugPrint('DEBUG: Login complete. Returning state with role: ${_state.role}');
      
      // Ensure user has a Firestore record
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          // Create user document with default role
          await _firestore.collection('users').doc(user.uid).set({
            'email': email,
            'role': 'student',
            'createdAt': FieldValue.serverTimestamp(),
            'status': 'active',
          });
        }
      } catch (firestoreError) {
        // Log but don't fail - user can still login
        debugPrint('Warning: Could not create/verify user document: $firestoreError');
      }
      
      return _state;
    } on FirebaseAuthException catch (e) {
      debugPrint('DEBUG: FirebaseAuthException: ${e.code} - ${e.message}');
      rethrow;
    } catch (e, st) {
      debugPrint('DEBUG: General exception during login: $e');
      debugPrint(st.toString());
      throw Exception('Login failed: An internal error has occurred. (${e.runtimeType}) ${e.toString()}');
    }
  }

  /// Login with Google - automatically creates account if doesn't exist with 'student' role
  /// NOTE: Google Sign-In requires platform-specific OAuth configuration
  @override
  Future<AuthState> loginWithGoogle() async {
    try {
      debugPrint('DEBUG: Google Sign-In button clicked...');
      
      // Show user-friendly error message with setup instructions
      throw Exception(
        '⚙️ Google Sign-In Configuration Required\n\n'
        'To enable Google Sign-In:\n\n'
        '1. Create OAuth 2.0 credentials in Google Cloud Console\n'
        '2. Add Web client ID to Firebase Console\n'
        '3. Configure platform-specific files:\n'
        '   • Android: google-services.json\n'
        '   • iOS: GoogleService-Info.plist\n'
        '   • Windows: Web app credentials\n\n'
        'Contact your administrator for setup assistance.'
      );
    } catch (e) {
      debugPrint('ERROR: Google Sign-In error: $e');
      rethrow;
    }
  }

  /// Register a new user and create a Firestore user doc with a role (default student).
  @override
  Future<AuthState> register({required String name, required String email, required String password, String role = 'student'}) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = cred.user;
      if (user == null) throw FirebaseAuthException(code: 'NO_USER', message: 'No user returned');

      // Create user doc in Firestore. Role must be set here; admins should be assigned manually in Firestore.
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'role': role,
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (firestoreError) {
        debugPrint('Error creating Firestore user document: $firestoreError');
        // Delete the auth user if we can't create the Firestore record
        try {
          await user.delete();
        } catch (_) {}
        throw Exception('Failed to create user profile: ${firestoreError.toString()}');
      }

      await _onAuthStateChanged(user);
      return _state;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> guestLogin() async {
    try {
      final cred = await _auth.signInAnonymously();
      final user = cred.user;
      if (user == null) throw FirebaseAuthException(code: 'NO_USER', message: 'No user returned');

      // For anonymous users, we don't create a Firestore doc. Treat as student for UI only.
      _state = AuthState(
        userId: user.uid,
        email: user.email,
        displayName: 'Anonymous User',
        role: 'student',
        loggedIn: true,
      );
      _controller.add(_state);
      notifyListeners();
    } catch (e) {
      throw Exception('Guest login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    _state = AuthState.signedOut;
    _controller.add(_state);
    notifyListeners();
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

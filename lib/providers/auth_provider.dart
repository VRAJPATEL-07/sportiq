/// LAB 6: Authentication Provider
/// State Management for User Authentication
///
/// This provider manages:
///   - User login/logout state
///   - User session persistence
///   - Authentication status
///   - Guarded routes based on authentication
library;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// AuthProvider: Manages authentication state and operations
/// 
/// LAB 6 Requirements:
///   - Manages bool isLoggedIn
///   - Provides login() method
///   - Provides logout() method
///   - Calls notifyListeners() for reactive updates
///   - Session persists during app runtime
///   - Enables guarded routes
///
/// Usage in main.dart:
///   ```dart
///   ChangeNotifierProvider(
///     create: (context) => AuthProvider(),
///     child: MaterialApp(...),
///   )
///   ```
/// 
/// Usage in widgets:
///   ```dart
///   final authProvider = Provider.of<AuthProvider>(context);
///   if (authProvider.isLoggedIn) {
///     // Show authenticated UI
///   } else {
///     // Show login screen
///   }
///   ```
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Current authenticated user
  UserModel? _user;
  
  /// Whether user is currently logged in
  bool _isLoggedIn = false;
  
  /// Error message from authentication operations
  String? _errorMessage;
  
  /// Whether an auth operation is in progress
  bool _isLoading = false;

  /// LAB 6: State properties
  
  /// Returns true if a user is logged in
  bool get isLoggedIn => _isLoggedIn;
  
  /// Returns the current user, null if not logged in
  UserModel? get user => _user;
  
  /// Returns the current user's email
  String? get userEmail => _user?.email;
  
  /// Returns any error message
  String? get errorMessage => _errorMessage;
  
  /// Returns true if an operation is in progress
  bool get isLoading => _isLoading;

  /// Constructor - checks if user is already logged in
  AuthProvider() {
    _checkAuthStatus();
  }
  /// Checks current authentication status on initialization
  /// This also fetches the user's role from Firestore and sets `isAdmin`.
  void _checkAuthStatus() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      bool isAdmin = false;
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null && data['role'] == 'admin') isAdmin = true;
        }
      } catch (e) {
        // Keep isAdmin=false on error; avoid blocking startup
        debugPrint('Warning: could not fetch user role: $e');
      }

      _user = UserModel(
        uid: currentUser.uid,
        email: currentUser.email ?? '',
        displayName: currentUser.displayName,
        photoUrl: currentUser.photoURL,
        isAdmin: isAdmin,
      );
      _isLoggedIn = true;
    } else {
      _user = null;
      _isLoggedIn = false;
    }
    notifyListeners();
  }

  /// LAB 6: Login method
  /// 
  /// Authenticates user with email and password
  /// 
  /// Parameters:
  ///   - email: User's email address
  ///   - password: User's password
  /// 
  /// Returns:
  ///   - true if login successful, false otherwise
  /// 
  /// Error Handling:
  ///   - user-not-found: No user with that email
  ///   - wrong-password: Incorrect password
  ///   - too-many-requests: Too many login attempts
  ///   - invalid-email: Invalid email format
  /// 
  /// Example:
  ///   ```dart
  ///   final success = await authProvider.login('user@example.com', 'password');
  ///   if (success) {
  ///     Navigator.pushNamed(context, '/home');
  ///   } else {
  ///     showSnackBar(authProvider.errorMessage);
  ///   }
  ///   ```
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Fetch role from Firestore
        bool isAdmin = false;
        try {
          final doc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
          if (doc.exists) {
            final data = doc.data();
            if (data != null && data['role'] == 'admin') isAdmin = true;
          }
        } catch (e) {
          debugPrint('Warning: could not fetch role on login: $e');
        }

        _user = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          displayName: userCredential.user!.displayName,
          photoUrl: userCredential.user!.photoURL,
          isAdmin: isAdmin,
        );
        _isLoggedIn = true;
        _errorMessage = null;
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _isLoggedIn = false;
      _user = null;
      
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          _errorMessage = 'Incorrect password';
          break;
        case 'too-many-requests':
          _errorMessage = 'Too many login attempts. Try again later.';
          break;
        case 'invalid-email':
          _errorMessage = 'Invalid email format';
          break;
        default:
          _errorMessage = 'Login failed: ${e.message}';
      }
    } catch (e) {
      _isLoggedIn = false;
      _user = null;
      _errorMessage = 'An unexpected error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  /// LAB 6: Register method
  /// 
  /// Creates a new user account
  /// 
  /// Parameters:
  ///   - email: User's email address
  ///   - password: User's password
  ///   - displayName: User's display name (optional)
  /// 
  /// Returns:
  ///   - true if registration successful, false otherwise
  Future<bool> register(String email, String password,
      {String? displayName}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        if (displayName != null) {
          await userCredential.user!.updateDisplayName(displayName);
        }

        // Create Firestore user document with default 'student' role
        try {
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
            'name': displayName ?? userCredential.user!.displayName ?? '',
            'email': userCredential.user!.email ?? '',
            'role': 'student',
            'status': 'active',
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          debugPrint('Warning: could not create user document on register: $e');
        }

        _user = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          displayName: displayName ?? userCredential.user!.displayName,
          photoUrl: userCredential.user!.photoURL,
          isAdmin: false,
        );
        _isLoggedIn = true;
        _errorMessage = null;
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _isLoggedIn = false;
      _user = null;
      
      switch (e.code) {
        case 'weak-password':
          _errorMessage = 'Password is too weak';
          break;
        case 'email-already-in-use':
          _errorMessage = 'Email is already registered';
          break;
        case 'invalid-email':
          _errorMessage = 'Invalid email format';
          break;
        default:
          _errorMessage = 'Registration failed: ${e.message}';
      }
    } catch (e) {
      _isLoggedIn = false;
      _user = null;
      _errorMessage = 'An unexpected error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  /// LAB 6: Logout method
  /// 
  /// Signs out the currently logged-in user
  /// Clears user data and updates login state
  /// 
  /// Returns:
  ///   - true if logout successful, false otherwise
  /// 
  /// Example:
  ///   ```dart
  ///   await authProvider.logout();
  ///   Navigator.pushNamed(context, '/login');
  ///   ```
  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signOut();
      _user = null;
      _isLoggedIn = false;
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Logout failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates user profile information
  /// 
  /// Parameters:
  ///   - displayName: New display name (optional)
  ///   - photoUrl: New photo URL (optional)
  /// 
  /// Returns:
  ///   - true if update successful, false otherwise
  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    if (_user == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        if (displayName != null) {
          await currentUser.updateDisplayName(displayName);
        }
        if (photoUrl != null) {
          await currentUser.updatePhotoURL(photoUrl);
        }

        // Reload to get updated data
        await currentUser.reload();
        
        _user = UserModel(
          uid: currentUser.uid,
          email: currentUser.email ?? '',
          displayName: currentUser.displayName,
          photoUrl: currentUser.photoURL,
          isAdmin: _user!.isAdmin,
        );
        return true;
      }
    } catch (e) {
      _errorMessage = 'Profile update failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  /// Changes the user's password
  /// 
  /// Parameters:
  ///   - newPassword: The new password
  /// 
  /// Returns:
  ///   - true if successful, false otherwise
  Future<bool> changePassword(String newPassword) async {
    if (_user == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await currentUser.updatePassword(newPassword);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          _errorMessage = 'New password is too weak';
          break;
        case 'requires-recent-login':
          _errorMessage = 'Please login again before changing your password';
          break;
        default:
          _errorMessage = 'Password change failed: ${e.message}';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  /// Sends a password reset email to the given address.
  Future<bool> sendPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Password reset failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears any stored error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

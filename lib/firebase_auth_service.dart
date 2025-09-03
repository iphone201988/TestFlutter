import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

/// Service class to handle all Firebase Authentication operations
/// This class follows the singleton pattern to ensure single instance
class FirebaseAuthService {
  FirebaseAuthService._privateConstructor();

  static final FirebaseAuthService _instance = FirebaseAuthService._privateConstructor();

  factory FirebaseAuthService() => _instance;

  // Firebase Auth instance
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Gets the current user if logged in
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Signs in user with email and password
  /// Returns AuthResult with success status and optional error message
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('Attempting to sign in with email: $email'); // Debug log

      // Validate inputs first
      if (email.trim().isEmpty || password.isEmpty) {
        return AuthResult(
          isSuccess: false,
          errorMessage: 'Email and password cannot be empty.',
        );
      }

      // Attempt to sign in with Firebase Auth
      final UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      debugPrint('Sign in successful for user: ${credential.user?.email}'); // Debug log

      // Check if user exists
      if (credential.user != null) {
        return AuthResult(
          isSuccess: true,
          user: credential.user,
          message: 'Login successful',
        );
      } else {
        return AuthResult(
          isSuccess: false,
          errorMessage: 'Login failed. No user data received.',
        );
      }
    } on FirebaseAuthException catch (e) {
      // Log the specific error for debugging
      debugPrint('FirebaseAuthException - Code: ${e.code}, Message: ${e.message}');

      return AuthResult(
        isSuccess: false,
        errorMessage: _getErrorMessage(e.code),
      );
    } catch (e) {
      // Log unexpected errors
      debugPrint('Unexpected error during sign in: $e');

      return AuthResult(
        isSuccess: false,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Creates a new user account with email and password
  Future<AuthResult> createUserWithEmailAndPassword({
    required String email,
    required String password,
  })
  async {
    try {
      final UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // Send email verification
        await credential.user!.sendEmailVerification();

        return AuthResult(
          isSuccess: true,
          user: credential.user,
          message: 'Account created successfully.',
        );
      } else {
        return AuthResult(
          isSuccess: false,
          errorMessage: 'Account creation failed. Please try again.',
        );
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: _getErrorMessage(e.code),
      );
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  /// Converts Firebase Auth error codes to user-friendly messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign in is not enabled.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'unknown':
        return 'An unknown error occurred. Please try again.';
      case 'multi-factor-auth-required':
        return 'Multi-factor authentication is required.';
      case 'requires-recent-login':
        return 'Please log out and log back in to continue.';
      case 'credential-already-in-use':
        return 'This credential is already associated with another account.';
      default:
        return 'Authentication failed. Error code: $errorCode';
    }
  }
}

/// Result class to wrap authentication results
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? message;
  final String? errorMessage;

  AuthResult({
    required this.isSuccess,
    this.user,
    this.message,
    this.errorMessage,
  });
}

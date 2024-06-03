import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taste_hub/components/toast.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      return credential.user;
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      handleAuthException(context, e);
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      return credential.user;
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      handleAuthException(context, e);
    }
    return null;
  }

  void handleAuthException(BuildContext context, FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'email-already-in-use':
        message = 'The email address is already in use';
        break;
      case 'invalid-email':
        message = 'The email address is badly formatted';
        break;
      case 'invalid-credential':
        message = 'Invalid email or password';
        break;
      case 'weak-password':
        message = 'Password must contain at least 6 symbols';
        break;
      case 'channel-error':
        message = 'Please fill all the fields';
        break;
      case 'user-disabled':
        message = 'The user account has been disabled';
        break;
      case 'user-not-found':
        message = 'No user found for this email';
        break;
      case 'wrong-password':
        message = 'Invalid email or password';
        break;
      default:
        message = 'An error occurred: ${e.code}';
        break;
    }
    showErrorToast(context, message: message);
  }
}

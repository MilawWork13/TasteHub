import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taste_hub/components/toast.dart';
import 'package:taste_hub/controller/services/firebase_auth_services.dart';

class SignInController {
  final FirebaseAuthService _auth = FirebaseAuthService();

  Future<void> signIn(
      BuildContext context,
      TextEditingController emailController,
      TextEditingController passwordController) async {
    try {
      String email = emailController.text;
      String password = passwordController.text;

      User? user =
          await _auth.signInWithEmailAndPassword(context, email, password);

      if (user != null) {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, "/home");
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showErrorToast(context, message: 'Failed to sign in. Please try again.');
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // ignore: use_build_context_synchronously
        showErrorToast(context, message: 'Google sign-in aborted.');
        return;
      }

      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushNamed('/home');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showErrorToast(context,
          message: 'Failed to sign in with Google. Please try again.');
    }
  }
}

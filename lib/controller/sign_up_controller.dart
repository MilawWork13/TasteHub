import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taste_hub/components/toast.dart';
import 'package:taste_hub/controller/services/firebase_auth_services.dart';

class SignUpController {
  final FirebaseAuthService _auth = FirebaseAuthService();

  Future<User?> signUp(
      BuildContext context,
      TextEditingController emailController,
      TextEditingController passwordController,
      TextEditingController usernameController) async {
    try {
      String email = emailController.text;
      String password = passwordController.text;
      String username = usernameController.text;

      User? user =
          await _auth.signUpWithEmailAndPassword(context, email, password);

      if (user != null) {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/sign_in');
        // ignore: use_build_context_synchronously
        showSuccessToast(context, message: 'Account created successfully!');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      _auth.handleAuthException(context, e);
      return null;
    }
  }
}

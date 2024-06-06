import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:taste_hub/components/toast.dart';
import 'package:taste_hub/controller/services/firebase_auth_service.dart';
import 'package:taste_hub/controller/services/mongo_db_service.dart';
import 'package:taste_hub/model/User.dart';

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
        String email = userCredential.user!.email!;
        String name = userCredential.user!.displayName!;

        // Initialize MongoDB service
        MongoDBService mongoDBService = await MongoDBService.create();

        // Check if user exists in MongoDB
        UserModel? existingUser = await mongoDBService.getUserByEmail(email);
        if (existingUser == null) {
          // Detect system language
          // ignore: use_build_context_synchronously
          String systemLanguage = Localizations.localeOf(context).toString();

          // Create user in MongoDB
          UserModel newUser = UserModel(
            id: ObjectId(),
            name: name,
            email: email,
            preferredLanguage: systemLanguage,
            role: 'user',
            favouriteReceipts: [],
          );

          await mongoDBService.createUser(newUser);
        }
        await mongoDBService.disconnect();
        // ignore: use_build_context_synchronously
      }
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushNamed('/home');
    } catch (e) {
      // ignore: use_build_context_synchronously
      showErrorToast(context,
          message: 'Failed to sign in with Google. Please try again.');
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(context, '/sign_in', (route) => false);
    } catch (e) {
      // Handle any errors that occur during sign-out
      print("Error signing out: $e");
      // Optionally, you could show a dialog or a snackbar to inform the user
    }
  }
}

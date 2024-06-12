import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:taste_hub/components/toast.dart';
import 'package:taste_hub/controller/services/firebase_auth_service.dart';
import 'package:taste_hub/controller/services/mongo_db_service.dart';
import 'package:taste_hub/model/User.dart';

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
        String systemLanguage = Localizations.localeOf(context).toString();

        // Create user in MongoDB
        UserModel newUser = UserModel(
          id: ObjectId(),
          name: username,
          email: email,
          preferredLanguage: systemLanguage,
          role: 'user',
          favouriteReceipts: [],
        );

        MongoDBService mongoDBService = await MongoDBService.create();
        await mongoDBService.createUser(newUser);
        await mongoDBService.disconnect();

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

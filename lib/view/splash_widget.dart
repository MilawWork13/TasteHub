import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taste_hub/controller/services/mongo_db_service.dart';
import 'package:taste_hub/model/User.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0; // Initial opacity for the logo

  @override
  void initState() {
    super.initState();

    // Timer to wait for 2 seconds before checking authentication status
    Timer(const Duration(seconds: 2), () {
      checkAuthStatus();
    });

    // Delayed execution to animate the logo opacity after 100 milliseconds
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0; // Update opacity to 1 for logo animation
      });
    });
  }

  // Method to check the authentication status and navigate accordingly
  void checkAuthStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is authenticated, fetch user details from MongoDB
      MongoDBService mongoService = await MongoDBService.create();
      UserModel? userModel = await mongoService.getUserByEmail(user.email!);
      await mongoService.disconnect();

      // Navigate based on user role retrieved from MongoDB
      if (userModel != null && userModel.role == 'admin') {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacementNamed('/admin_page');
      } else {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      // No user signed in, navigate to the get_started page
      Navigator.of(context).pushReplacementNamed('/get_started');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity, // Animated opacity controlled by _opacity variable
          duration: const Duration(milliseconds: 500),
          child: Image.asset(
            'assets/logo.png', // Logo image asset
            width: 400,
            height: 400,
          ),
        ),
      ),
    );
  }
}

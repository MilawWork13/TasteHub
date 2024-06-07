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
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      checkAuthStatus();
    });
    // Start the fade animation after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  void checkAuthStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get user role from the database
      MongoDBService mongoService = await MongoDBService.create();
      UserModel? userModel = await mongoService.getUserByEmail(user.email!);
      await mongoService.disconnect();

      // Navigate based on user role
      if (userModel != null && userModel.role == 'admin') {
        // User is an admin. Navigate to admin page.
        Navigator.of(context).pushReplacementNamed('/admin_page');
      } else {
        // User is not an admin. Navigate to home.
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      // No user signed in. Navigate to get_started.
      Navigator.of(context).pushReplacementNamed('/get_started');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // Use AnimatedOpacity for fade animation
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 500),
          child: Image.asset(
            'assets/logo.png',
            width: 400,
            height: 400,
          ),
        ),
      ),
    );
  }
}

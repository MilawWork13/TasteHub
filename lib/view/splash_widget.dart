import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
      // User is signed in. Navigate to home.
      Navigator.of(context).pushReplacementNamed('/home');
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

import 'package:flutter/material.dart';
import 'package:taste_hub/view/register.dart';
import 'package:taste_hub/view/signin.dart';
import 'package:taste_hub/view/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TasteHUB',
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashWidget(),
        '/sign_in': (context) => const SignInWidget(),
        '/register': (context) => const OnboardingCreateAccountWidget(),
      },
    );
  }
}

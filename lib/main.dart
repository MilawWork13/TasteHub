import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taste_hub/view/home_page_widget.dart';
import 'package:taste_hub/view/sign_up_widget.dart';
import 'package:taste_hub/view/sign_in_widget.dart';
import 'package:taste_hub/view/get_started_widget.dart';
import 'package:taste_hub/view/onboarding_slideshow_widget.dart';
import 'package:taste_hub/view/splash_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_API_KEY']!,
    appId: dotenv.env['FIREBASE_APP_ID']!,
    messagingSenderId: dotenv.env['FIREBASE_MESSAGING_CENTER_ID']!,
    projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
    storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
  ));

  // Activate Firebase App Check
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );

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
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/get_started': (context) => const GetStartedWidget(),
        '/sign_in': (context) => const SignInWidget(),
        '/register': (context) => const RegisterWidget(),
        '/onboarding': (context) => const OnboardingSlideshowWidget(),
      },
    );
  }
}

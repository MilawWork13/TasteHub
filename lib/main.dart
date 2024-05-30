import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:taste_hub/view/homePageWidget.dart';
import 'package:taste_hub/view/registerWidget.dart';
import 'package:taste_hub/view/signInWidget.dart';
import 'package:taste_hub/view/splashWidget.dart';
import 'package:taste_hub/view/onBoardingSlideShowWidget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: 'AIzaSyC5Xoks7maFE5V1jn0t_Mv4_5aBOk8Z1m4',
    appId: '1:588995605879:android:1af0b6563eb1850ce01d72',
    messagingSenderId: '588995605879',
    projectId: 'tastehub-5a84b',
    storageBucket: 'tastehub-5a84b.appspot.com',
  ));

  // Activate Firebase App Check
  await FirebaseAppCheck.instance.activate(
    // You can specify your preferred providers here
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
        '/home': (context) => const HomePage(),
        '/splash': (context) => const SplashWidget(),
        '/sign_in': (context) => const SignInWidget(),
        '/register': (context) => const RegisterWidget(),
        '/onboarding': (context) => const OnboardingSlideshowWidget(),
      },
    );
  }
}

import 'package:flutter/material.dart';

class SplashWidget extends StatefulWidget {
  const SplashWidget({Key? key}) : super(key: key);

  @override
  State<SplashWidget> createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Replace with your background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your image here
            Image.asset(
              'lib/resources/img/logo.png',
              width: 700, // Adjust the width as needed
              height: 650, // Adjust the height as needed
              fit: BoxFit.contain, // Adjust the fit as needed
            ),
            const SizedBox(height: 26), // Adjust the spacing as needed
            SizedBox(
              width: 350, // Adjust the width as needed
              height: 60, // Adjust the height as needed
              child: ElevatedButton(
                onPressed: () {
                  // Get Started button pressed
                  Navigator.of(context).pushNamed('/onboarding');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 228, 15, 0), // Change the color to red
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(32), // Adjust the radius
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 20, // Adjust the font size
                    color: Colors.white, // Set text color to white
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12), // Adjust the spacing as needed
            GestureDetector(
              onTap: () {
                // Sign In text pressed
                Navigator.of(context).pushNamed('/sign_in');
              },
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Already a member? ',
                      style: TextStyle(
                        color: Colors.black, // Make the text thicker
                      ),
                    ),
                    TextSpan(
                      text: 'Sign In',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

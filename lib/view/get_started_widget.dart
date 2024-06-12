import 'package:flutter/material.dart';

class GetStartedWidget extends StatefulWidget {
  const GetStartedWidget({super.key}); // Constructor for GetStartedWidget

  @override
  State<GetStartedWidget> createState() => _GetStartedWidgetState();
}

class _GetStartedWidgetState extends State<GetStartedWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents the widget from resizing when the keyboard is shown
      backgroundColor: Colors.white, // Background color of the scaffold

      // Builds the widget's body based on the available layout constraints
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate dimensions based on parent constraints
          double imageWidth =
              constraints.maxWidth * 0.8; // Adjusted image width
          double imageHeight =
              constraints.maxHeight * 0.5; // Adjusted image height
          double buttonWidth =
              constraints.maxWidth * 0.7; // Adjusted button width
          double buttonHeight = 60; // Fixed button height

          // Limit maximum dimensions for better UI scaling
          if (imageWidth > 700) imageWidth = 700;
          if (imageHeight > 650) imageHeight = 650;
          if (buttonWidth > 350) buttonWidth = 350;

          // Widget tree starting with a column layout
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/logo.png', // Image asset path
                    width: imageWidth,
                    height: imageHeight,
                    fit: BoxFit
                        .contain, // Maintain aspect ratio and fit container
                  ),
                ),
              ),
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                        '/onboarding'); // Navigate to '/onboarding' route
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 228, 15, 0), // Button background color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(32), // Button border radius
                    ),
                  ),
                  child: const Text(
                    'Get Started', // Button text
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12), // Spacer with fixed height
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                      '/sign_in'); // Navigate to '/sign_in' route on tap
                },
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Already a member? ', // First part of the text
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text:
                            'Sign In', // Second part of the text with underline and bold
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
              const SizedBox(height: 26), // Additional spacer for layout
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SuggestedPage extends StatefulWidget {
  const SuggestedPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SuggestedPageState createState() => _SuggestedPageState();
}

class _SuggestedPageState extends State<SuggestedPage> {
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greetingText;
    String greetingImage;

    if (hour < 12) {
      greetingText = 'Good Morning!';
      greetingImage = 'assets/breakfast.jpeg';
    } else if (hour < 17) {
      greetingText = 'Good Afternoon!';
      greetingImage = 'assets/lunch.jpg';
    } else {
      greetingText = 'Good Evening!';
      greetingImage = 'assets/dinner.jpg';
    }

    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                greetingImage,
                width: double.infinity,
                height: 200, // Adjust height as needed
                fit: BoxFit.cover,
              ),
              Container(
                width: double.infinity,
                height: 200, // Match height to the image
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(0, 255, 255, 255),
                      backgroundColor.withOpacity(1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 15,
                left: 25,
                child: Text(
                  greetingText,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ],
          ),
          // Add the rest of your page content below the image
          const Expanded(
            child: Center(
              child: Text(
                'Main content here',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

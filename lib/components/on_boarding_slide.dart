import 'package:flutter/material.dart';

class OnboardingSlide extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String description;

  const OnboardingSlide({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 4, // Adjust the flex value as needed
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 56,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding:
                    const EdgeInsets.all(16.0), // Adjust the padding as needed
                child: Image.asset(
                  imageUrl,
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2, // Adjust the flex value as needed
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

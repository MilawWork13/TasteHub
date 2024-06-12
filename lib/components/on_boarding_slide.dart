import 'package:flutter/material.dart';

class OnboardingSlide extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String description;
  final double paddingHorizontal;
  final double paddingVertical;

  const OnboardingSlide({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.paddingHorizontal,
    required this.paddingVertical,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: paddingHorizontal,
        right: paddingHorizontal,
        top: paddingVertical,
        bottom: paddingVertical + 100,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 40),
            textAlign: TextAlign.center,
          ),
          Expanded(
            child: Image.asset(imageUrl),
          ),
          Text(
            description,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

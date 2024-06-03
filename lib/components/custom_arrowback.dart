import 'package:flutter/material.dart';

class CustomBackArrowButton extends StatelessWidget {
  final VoidCallback? onBackButtonPressed;

  const CustomBackArrowButton({
    super.key,
    this.onBackButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(left: 18, top: 40), // Adjust margin as needed
      child: ClipOval(
        child: Container(
          color: Colors.white, // Set the background color to white
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(4, 0, 0, 0), // Adjust icon position
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black, // Set the color of the icon to black
                size: 18,
              ),
              onPressed:
                  onBackButtonPressed ?? () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
    );
  }
}

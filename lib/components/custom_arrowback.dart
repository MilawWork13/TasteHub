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
      margin: const EdgeInsets.only(left: 18, top: 40),
      child: ClipOval(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
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

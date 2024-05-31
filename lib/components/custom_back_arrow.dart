import 'package:flutter/material.dart';

class CustomBackArrow extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool backButton;
  final VoidCallback? onBackButtonPressed;

  const CustomBackArrow({
    super.key,
    required this.title,
    this.backButton = false,
    this.onBackButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: backButton,
      leading: backButton
          ? Container(
              margin: const EdgeInsets.only(
                  left: 16, top: 8, bottom: 8), // Adjust margins as needed
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, // Set the background color to white
              ),
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 6.0), // Adjust icon position
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: 14,
                  ),
                  onPressed:
                      onBackButtonPressed ?? () => Navigator.of(context).pop(),
                ),
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

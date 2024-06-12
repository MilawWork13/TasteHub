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
              margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: ClipOval(
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 5, 8, 8),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                        size: 14,
                      ),
                      onPressed: onBackButtonPressed ??
                          () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            )
          : null,
      backgroundColor: const Color.fromARGB(0, 255, 255, 255),
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

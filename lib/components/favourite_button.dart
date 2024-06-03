import 'package:flutter/material.dart';
import 'package:taste_hub/components/toast.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({super.key});

  @override
  FavoriteButtonState createState() => FavoriteButtonState();
}

class FavoriteButtonState extends State<FavoriteButton> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isFavorite = !isFavorite;
        });
        showSuccessToast(
          context,
          message: isFavorite
              ? 'Recipe added to favorites!'
              : 'Recipe removed from favorites!',
        );
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : Colors.red,
          size: 24,
        ),
      ),
    );
  }
}

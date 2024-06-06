import 'package:flutter/material.dart';
import 'package:taste_hub/components/toast.dart';

class FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final Function(bool) onFavoriteChanged;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  @override
  FavoriteButtonState createState() => FavoriteButtonState();
}

class FavoriteButtonState extends State<FavoriteButton> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isFavorite = !isFavorite;
        });
        widget.onFavoriteChanged(isFavorite);
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

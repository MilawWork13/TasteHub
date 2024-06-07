import 'package:flutter/material.dart';

class ModifyRecipeButton extends StatefulWidget {
  final Function() onModify;

  const ModifyRecipeButton({
    Key? key,
    required this.onModify,
  }) : super(key: key);

  @override
  _ModifyRecipeButtonState createState() => _ModifyRecipeButtonState();
}

class _ModifyRecipeButtonState extends State<ModifyRecipeButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Show a dialog or navigate to the modify recipe screen
        widget.onModify();
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: Colors.white,
      ),
      child: const Padding(
        padding: EdgeInsets.all(0),
        child: Icon(
          Icons.edit,
          color: Colors.red,
          size: 24,
        ),
      ),
    );
  }
}

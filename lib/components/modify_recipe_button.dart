import 'package:flutter/material.dart';

class ModifyRecipeButton extends StatefulWidget {
  final Function() onModify;

  const ModifyRecipeButton({
    super.key,
    required this.onModify,
  });

  @override
  ModifyRecipeButtonState createState() => ModifyRecipeButtonState();
}

class ModifyRecipeButtonState extends State<ModifyRecipeButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
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

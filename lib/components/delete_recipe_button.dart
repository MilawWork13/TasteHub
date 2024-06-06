import 'package:flutter/material.dart';

class DeleteRecipeButton extends StatefulWidget {
  final Function() onDelete;

  const DeleteRecipeButton({
    super.key,
    required this.onDelete,
  });

  @override
  DeleteRecipeButtonState createState() => DeleteRecipeButtonState();
}

class DeleteRecipeButtonState extends State<DeleteRecipeButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content:
                  const Text('Are you sure you want to delete this recipe?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    widget.onDelete();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: Colors.white,
      ),
      child: const Padding(
        padding: EdgeInsets.all(10.0),
        child: Icon(
          Icons.delete,
          color: Colors.red,
          size: 24,
        ),
      ),
    );
  }
}

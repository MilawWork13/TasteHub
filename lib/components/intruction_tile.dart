import 'package:flutter/material.dart';

class InstructionTile extends StatefulWidget {
  final String instruction;
  final Function(bool) onChanged;

  const InstructionTile({
    super.key,
    required this.instruction,
    required this.onChanged,
  });

  @override
  InstructionTileState createState() => InstructionTileState();
}

class InstructionTileState extends State<InstructionTile> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: isChecked,
        onChanged: (value) {
          setState(() {
            isChecked = value!;
          });
          widget.onChanged(value!);
        },
      ),
      title: Text(
        widget.instruction,
        style: TextStyle(
          fontSize: 16,
          decoration: isChecked ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }
}

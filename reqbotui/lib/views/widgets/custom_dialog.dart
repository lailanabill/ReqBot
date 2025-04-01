// lib/widgets/custom_dialog.dart
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onAction;
  final TextEditingController controller;
  final Color primaryColor;

  const CustomDialog({
    Key? key,
    required this.title,
    required this.actionText,
    required this.onAction,
    required this.controller,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(title, style: TextStyle(color: primaryColor)),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: "Enter requirement",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel", style: TextStyle(color: primaryColor)),
        ),
        ElevatedButton(
          onPressed: onAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(actionText),
        ),
      ],
    );
  }
}

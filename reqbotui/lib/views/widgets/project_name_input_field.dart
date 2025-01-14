import 'package:flutter/material.dart';

class ProjectNameInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? errorText;

  const ProjectNameInputField({
    super.key,
    required this.controller,
    this.label = 'Project Name',
    this.hint = 'Enter project name',
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}

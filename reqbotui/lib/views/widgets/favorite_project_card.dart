import 'package:flutter/material.dart';

class FavoriteProjectCard extends StatelessWidget {
  final String projectName;
  final VoidCallback onDelete;

  const FavoriteProjectCard({
    super.key,
    required this.projectName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(
          projectName,
          style: const TextStyle(fontSize: 18),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

// widgets/favorite_project_card.dart
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(projectName),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

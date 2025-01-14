import 'package:flutter/material.dart';

class HomeActionButtons extends StatelessWidget {
  final VoidCallback onNewProject;
  final VoidCallback onViewFavorites;
  final VoidCallback onGoToMailPage;

  const HomeActionButtons({
    super.key,
    required this.onNewProject,
    required this.onViewFavorites,
    required this.onGoToMailPage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: onNewProject,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              textStyle: const TextStyle(
                fontSize: 20,
                color: Color(0xFF3F51B5),
              ),
            ),
            child: const Text(
              'New Project',
              style: TextStyle(color: Color(0xFF3F51B5)),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onViewFavorites,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            child: const Text(
              'View Favorites',
              style: TextStyle(color: Color(0xFF3F51B5)),
            ),
          ),
          ElevatedButton(
            onPressed: onGoToMailPage,
            child: const Text('Go to Mail Page'),
          ),
        ],
      ),
    );
  }
}

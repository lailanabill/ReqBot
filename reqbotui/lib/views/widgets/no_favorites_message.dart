import 'package:flutter/material.dart';

class NoFavoritesMessage extends StatelessWidget {
  const NoFavoritesMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No favorite projects yet!',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}

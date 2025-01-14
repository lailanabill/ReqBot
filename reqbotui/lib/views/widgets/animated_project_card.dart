import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reqbot/services/providers/favorites_provider.dart';

class AnimatedProjectCard extends StatelessWidget {
  final String projectName;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const AnimatedProjectCard({
    super.key,
    required this.projectName,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(projectName);

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0.8, end: 1),
      curve: Curves.easeOut,
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: Dismissible(
            key: ValueKey(projectName),
            background: Container(color: Colors.red),
            onDismissed: (direction) {
              onRemove();
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: Text(projectName),
                onTap: onTap,
                trailing: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    favoritesProvider.toggleFavorite(projectName);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFavorite
                              ? '$projectName removed from favorites'
                              : '$projectName added to favorites',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

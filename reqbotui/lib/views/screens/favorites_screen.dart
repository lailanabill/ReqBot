import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reqbot/services/providers/favorites_provider.dart';
import '../widgets/favorite_project_card.dart';
import '../widgets/no_favorites_message.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final favoriteProjects = favoritesProvider.favoriteProjects.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Projects'),
        backgroundColor: const Color(0xFF3F51B5),
      ),
      body: favoriteProjects.isEmpty
          ? const NoFavoritesMessage()
          : ListView.builder(
              itemCount: favoriteProjects.length,
              itemBuilder: (context, index) {
                final projectName = favoriteProjects[index];

                return FavoriteProjectCard(
                  projectName: projectName,
                  onDelete: () => favoritesProvider.toggleFavorite(projectName),
                );
              },
            ),
    );
  }
}

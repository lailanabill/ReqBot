import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/favorites_controller.dart';
import '../../services/providers/favorites_provider.dart';
import '../widgets/favorite_project_card.dart';
import '../widgets/no_favorites_message.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final controller = FavoritesController(favoritesProvider);
    final favoriteProjects = controller.getFavoriteProjects();

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
                  onDelete: () {
                    controller.toggleFavorite(projectName);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '$projectName removed from favorites'),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

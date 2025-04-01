import 'package:reqbot/services/providers/favorites_provider.dart';

class FavoritesController {
  final FavoritesProvider _favoritesProvider;

  FavoritesController(this._favoritesProvider);

  /// Returns a copy of favorite projects to prevent external modifications.
  List<String> getFavoriteProjects() =>
      List.unmodifiable(_favoritesProvider.favoriteProjects);

  /// Toggles the favorite status of a project.
  void toggleFavorite(String projectName) {
    if (projectName.isNotEmpty) {
      _favoritesProvider.toggleFavorite(projectName);
    }
  }
}

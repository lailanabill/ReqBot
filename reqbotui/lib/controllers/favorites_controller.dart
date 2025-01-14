import 'package:reqbot/services/providers/favorites_provider.dart';

class FavoritesController {
  final FavoritesProvider _favoritesProvider;

  FavoritesController(this._favoritesProvider);

  List<String> getFavoriteProjects() {
    return _favoritesProvider.favoriteProjects.toList();
  }

  void toggleFavorite(String projectName) {
    _favoritesProvider.toggleFavorite(projectName);
  }
}

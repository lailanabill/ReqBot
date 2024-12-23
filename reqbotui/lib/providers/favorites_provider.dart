import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favoriteProjects = {};

  Set<String> get favoriteProjects => _favoriteProjects;

  void toggleFavorite(String projectName) {
    if (_favoriteProjects.contains(projectName)) {
      _favoriteProjects.remove(projectName);
    } else {
      _favoriteProjects.add(projectName);
    }
    notifyListeners();
  }

  bool isFavorite(String projectName) {
    return _favoriteProjects.contains(projectName);
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Set<String> _favoriteProjects = {};

  Set<String> get favoriteProjects => _favoriteProjects;

  FavoritesProvider() {
    _loadFavoritesFromSupabase(); // Load favorites on startup
  }

  Future<void> _loadFavoritesFromSupabase() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return; // No user logged in

    final response = await _supabase
        .from('favorites')
        .select('project_name')
        .eq('user_id', user.id);

    if (response.isNotEmpty) {
      _favoriteProjects.addAll(response.map((e) => e['project_name'] as String));
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String projectName) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    if (_favoriteProjects.contains(projectName)) {
      _favoriteProjects.remove(projectName);
      await _supabase.from('favorites').delete().match({
        'user_id': user.id,
        'project_name': projectName,
      });
    } else {
      _favoriteProjects.add(projectName);
      await _supabase.from('favorites').insert({
        'user_id': user.id,
        'project_name': projectName,
      });
    }

    notifyListeners();
  }

  bool isFavorite(String projectName) {
    return _favoriteProjects.contains(projectName);
  }
}

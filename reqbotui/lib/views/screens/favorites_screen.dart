import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/favorite_project_card.dart';
import '../widgets/no_favorites_message.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<String> _favoriteProjects = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('favorites')
          .select('project_name')
          .eq('user_id', user.id);

      setState(() {
        _favoriteProjects =
            response.map((f) => f['project_name'] as String).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading favorites: $e")),
      );
    }
  }

  Future<void> _removeFavorite(String projectName) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase
          .from('favorites')
          .delete()
          .eq('user_id', user.id)
          .eq('project_name', projectName);

      setState(() {
        _favoriteProjects.remove(projectName);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$projectName removed from favorites')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error removing favorite: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Projects'),
        backgroundColor: const Color(0xFF3F51B5),
      ),
      body: _favoriteProjects.isEmpty
          ? const NoFavoritesMessage()
          : ListView.builder(
              itemCount: _favoriteProjects.length,
              itemBuilder: (context, index) {
                final projectName = _favoriteProjects[index];

                return FavoriteProjectCard(
                  projectName: projectName,
                  onDelete: () => _removeFavorite(projectName),
                );
              },
            ),
    );
  }
}

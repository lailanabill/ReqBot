import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectNameController {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> saveProject(String name) async {
    if (name.isEmpty) {
      throw Exception('Project name cannot be empty.');
    }

    try {
      await _supabase.from('projects').insert({
        'name': name,
        'status': 'in_progress', // Default status
      });
    } catch (e) {
      throw Exception('Error saving project: $e');
    }
  }
}

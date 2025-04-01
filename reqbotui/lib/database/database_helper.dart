import 'package:supabase_flutter/supabase_flutter.dart';

class DBHelper {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Insert a project into Supabase
  Future<void> insertProject(String name, String transcription) async {
    try {
      await _supabase.from('projects').insert({
        'name': name,
        'transcription': transcription,
      });
    } catch (e) {
      throw Exception('Error inserting project: $e');
    }
  }

  /// Delete a project from Supabase by ID
  Future<void> deleteProject(int id) async {
    try {
      await _supabase.from('projects').delete().match({'id': id});
    } catch (e) {
      throw Exception('Error deleting project: $e');
    }
  }

  /// Get all projects from Supabase
  Future<List<Map<String, dynamic>>> getProjects() async {
    try {
      final response = await _supabase.from('projects').select();
      return response;
    } catch (e) {
      throw Exception('Error fetching projects: $e');
    }
  }

  /// Get a single project by ID from Supabase
  Future<Map<String, dynamic>> getProjectById(int id) async {
    try {
      final response =
          await _supabase.from('projects').select().eq('id', id).single();
      return response;
    } catch (e) {
      throw Exception('Error fetching project by ID: $e');
    }
  }
}

import 'package:reqbot/models/project_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ProjectModel>> loadProjects() async {
    final response = await _supabase.from('projects').select();
    
    if (response.isEmpty) {
      return [];
    }

    return response.map((e) => ProjectModel.fromMap(e)).toList();
  }

  Future<void> addProject(String name, String transcription) async {
    await _supabase.from('projects').insert({
      'name': name,
      'transcription': transcription,
    });
  }

  Future<void> removeProject(int id) async {
    await _supabase.from('projects').delete().eq('id', id);
  }
}

import 'package:reqbot/models/project_model.dart';
import 'package:reqbot/database/database_helper.dart';

class HomeController {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<List<ProjectModel>> loadProjects() async {
    final data = await _dbHelper.getProjects();
    return data.map((e) => ProjectModel.fromMap(e)).toList();
  }

  Future<void> addProject(String name, String transcription) async {
    await _dbHelper.insertProject(name, transcription);
  }

  Future<void> removeProject(int id) async {
    await _dbHelper.deleteProject(id);
  }
}
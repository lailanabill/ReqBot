import 'package:reqbot/database/database_helper.dart';

class ProjectNameController {
  Future<void> saveProject(String name) async {
    if (name.isEmpty) {
      throw Exception('Project name cannot be empty.');
    }

    try {
      await DBHelper.instance.insertProject(
        name,
        'in_progress', // Default status
      );
    } catch (e) {
      throw Exception('Error saving project: $e');
    }
  }
}

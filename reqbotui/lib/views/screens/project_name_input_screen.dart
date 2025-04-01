import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/project_name_input_field.dart';
import '../widgets/save_button.dart';

class ProjectNameScreen extends StatefulWidget {
  const ProjectNameScreen({super.key});

  @override
  _ProjectNameScreenState createState() => _ProjectNameScreenState();
}

class _ProjectNameScreenState extends State<ProjectNameScreen> {
  final TextEditingController _projectNameController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> _handleSaveProject() async {
    final projectName = _projectNameController.text.trim();
    if (projectName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project name cannot be empty.')),
      );
      return;
    }

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to save a project.')),
        );
        return;
      }

      await _supabase.from('projects').insert({
        'user_id': user.id, // Linking project to the logged-in user
        'name': projectName,
        'transcription': '', // Empty transcription for now
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project saved successfully.')),
      );

      Navigator.pop(context); // Close the screen after saving
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving project: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Project'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProjectNameInputField(controller: _projectNameController),
            const Spacer(),
            SaveButton(onPressed: _handleSaveProject),
          ],
        ),
      ),
    );
  }
}

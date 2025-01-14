import 'package:flutter/material.dart';
import 'package:reqbot/controllers/project_name_controller.dart';
import '../widgets/project_name_input_field.dart';
import '../widgets/save_button.dart';

class ProjectNameScreen extends StatefulWidget {
  const ProjectNameScreen({super.key});

  @override
  _ProjectNameScreenState createState() => _ProjectNameScreenState();
}

class _ProjectNameScreenState extends State<ProjectNameScreen> {
  final TextEditingController _projectNameController = TextEditingController();
  final ProjectNameController _controller = ProjectNameController();

  Future<void> _handleSaveProject() async {
    try {
      await _controller.saveProject(_projectNameController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project saved successfully.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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

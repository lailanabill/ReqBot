import 'package:flutter/material.dart';
import 'upload_convert.dart';

class ProjectNameInputScreen extends StatelessWidget {
  const ProjectNameInputScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController projectNameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Project'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: projectNameController,
              decoration: InputDecoration(
                labelText: 'Project Name',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 24),
            UploadButton(
              label: 'Upload Audio',
              onPressed: () {
                if (projectNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a project name.')),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UploadConvertScreen()),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            UploadButton(
              label: 'Upload Text',
              onPressed: () {
                // Implement text upload functionality
              },
            ),
            const SizedBox(height: 16),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (projectNameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter a project name.')),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UploadConvertScreen()),
                      );
                    }
                  },
                  child: const Text('Continue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UploadButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const UploadButton({Key? key, required this.label, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
            ),
            child: Text(label),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.check_circle, color: Colors.green),
      ],
    );
  }
}

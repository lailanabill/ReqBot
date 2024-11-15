import 'package:flutter/material.dart';

class NewProjectScreen extends StatelessWidget {
  const NewProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Enter Project Name:', style: TextStyle(fontSize: 20)),
            const TextField(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to upload screen
              },
              child: const Text('Upload Initial Files'),
            ),
          ],
        ),
      ),
    );
  }
}
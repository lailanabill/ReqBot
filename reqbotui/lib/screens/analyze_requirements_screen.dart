import 'package:flutter/material.dart';

class AnalyzeRequirementsScreen extends StatelessWidget {
  const AnalyzeRequirementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyze Requirements'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Analyzing Requirements...', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to specifications screen
              },
              child: const Text('View Analyzed Requirements'),
            ),
          ],
        ),
      ),
    );
  }
}
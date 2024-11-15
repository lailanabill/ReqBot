import 'package:flutter/material.dart';

class ValidationScreen extends StatelessWidget {
  const ValidationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validate Requirements'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Validation Summary:', style: TextStyle(fontSize: 20)),
            // Placeholder for validation results
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to feedback screen
              },
              child: const Text('View Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
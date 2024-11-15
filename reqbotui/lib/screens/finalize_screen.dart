import 'package:flutter/material.dart';

class FinalizeScreen extends StatelessWidget {
  const FinalizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalize Requirements'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Final Summary:', style: TextStyle(fontSize: 20)),
            // Placeholder for final summary content
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Simulate export functionality
              },
              child: const Text('Export Requirements'),
            ),
          ],
        ),
      ),
    );
  }
}
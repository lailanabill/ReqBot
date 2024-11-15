import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Extracted Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Functional Requirements:', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('- Requirement 1\n- Requirement 2\n- Requirement 3'),
            SizedBox(height: 20),
            Text('Use Cases:', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('- Use Case 1\n- Use Case 2'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

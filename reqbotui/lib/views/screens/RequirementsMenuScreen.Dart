import 'package:flutter/material.dart';
import 'package:reqbot/views/screens/diagramsmenu.dart';
import 'package:reqbot/views/screens/functional_requirements_screen.dart';
import 'package:reqbot/views/screens/non_functional_requirements_screen.dart';
import 'package:reqbot/views/screens/summary.dart';
import 'package:reqbot/views/screens/transcript.dart';

class RequirementsMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Requirement Type'),
        backgroundColor: Color.fromARGB(255, 187, 151, 236),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Functional Requirements Button
            ListTile(
              title: const Text('Functional Requirements'),
              leading: const Icon(Icons.check_circle_outline, color: Color.fromARGB(255, 187, 151, 236)),
              onTap: () {
                // Navigate to Functional Requirements screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FunctionalRequirementsScreen()),
                );
              },
            ),
            const Divider(),

            // Non-Functional Requirements Button
            ListTile(
              title: const Text('Non-Functional Requirements'),
              leading: const Icon(Icons.accessibility_new, color: Color.fromARGB(255, 187, 151, 236)),
              onTap: () {
                // Navigate to Non-Functional Requirements screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NonFunctionalRequirementsScreen()),
                );
              },
            ),
            const Divider(),
            // Non-Functional Requirements Button
            ListTile(
              title: const Text('Summary'),
              leading: const Icon(Icons.summarize, color: Color.fromARGB(255, 187, 151, 236)),
              onTap: () {
                // Navigate to Non-Functional Requirements screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SummaryScreen()),
                );
              },
            ),
            const Divider(),
            // Non-Functional Requirements Button
            ListTile(
              title: const Text('Trasncription'),
              leading: const Icon(Icons.transcribe, color: Color.fromARGB(255, 187, 151, 236)),
              onTap: () {
                // Navigate to Non-Functional Requirements screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TranscriptScreen()),
                );
              },
            ),
            const Divider(),

            // Diagrams Button
            ListTile(
              title: const Text('Diagrams'),
              leading: const Icon(Icons.account_tree, color: Color.fromARGB(255, 187, 151, 236)),
              onTap: () {
                // Navigate to the Diagrams Menu
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DiagramsMenu()),
                );
              },
            ),
            const Divider(),

            // Draft SRS Button (Disabled for now)
            ListTile(
              title: const Text('Draft SRS'),
              leading: const Icon(Icons.article_outlined, color: Color.fromARGB(255, 187, 151, 236)),
              onTap: () {
                // Uncomment and add the correct screen when available
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => DraftSrsScreen()),
                // );
              },
            ),
          ],
        ),
      ),
    );
  }
}

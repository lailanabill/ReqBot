import 'package:flutter/material.dart';
import 'package:reqbot/views/screens/diagramsmenu.dart';
import 'package:reqbot/views/screens/functional_requirements_screen.dart';
import 'package:reqbot/views/screens/non_functional_requirements_screen.dart';

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

         
  }
}

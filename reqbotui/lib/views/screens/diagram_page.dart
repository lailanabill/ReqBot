import 'package:flutter/material.dart';
import 'package:reqbot/views/screens/database_schema';
import 'package:reqbot/views/screens/sequence_diagram_screen.dart';
import 'class_diagram_editor.dart'; // Assuming this exists
import 'UseCaseValidation.dart'; // Assuming this exists

class DiagramPage extends StatelessWidget {
  final String diagramName;

  const DiagramPage({Key? key, required this.diagramName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(diagramName)),
      body: Center(
        child:
            Text('Showing $diagramName', style: const TextStyle(fontSize: 20)),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 187, 151, 236),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              // Navigate to the appropriate editor based on diagram type
              if (diagramName == 'Class Diagram') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ClassDiagramEditor(),
                  ),
                );
              } else if (diagramName == 'Use Case Diagram') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UseCaseValidation(),
                  ),
                );
              } else if (diagramName == 'Database Schema') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DatabaseSchemaEditor(),
                  ),
                );
              } else if (diagramName == 'Sequence Diagram') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SequenceDiagramScreen(),
                  ),
                );
              } else {
                // For other diagram types, show a placeholder message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Editor for $diagramName not implemented yet')),
                );
              }
            },
            child: const Text(
              "Edit Diagram",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

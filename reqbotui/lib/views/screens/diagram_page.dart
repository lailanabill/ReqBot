import 'package:flutter/material.dart';
import 'package:reqbot/views/screens/context_diagram_editor_screen.dart';
import 'package:reqbot/views/screens/database_schema_editor.dart';
import 'package:reqbot/views/screens/sequence_diagram_screen.dart';
import 'class_diagram_editor.dart'; // Assuming this exists
import 'UseCaseValidation.dart'; // Assuming this exists

class DiagramPage extends StatelessWidget {
  final String diagramName;
  final String dgrnam;

  const DiagramPage({Key? key, required this.diagramName, required this.dgrnam})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: Text(diagramName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Showing $diagramName', style: const TextStyle(fontSize: 20)),
            SizedBox(
              height: 20,
            ),
            // Image.asset(
            //   'assets/images/${dgrnam}_diagram_4.png',
            //   width: screenWidth * 0.8,
            //   height: screenHeight * 0.6,
            //   fit: BoxFit.contain,
            // ),
            Image.network(
              "https://storage.googleapis.com/diagrams-data/images/${dgrnam}_diagram_5.png",
              width: screenWidth * 0.8,
              height: screenHeight * 0.6,
              fit: BoxFit.contain,
            )
          ],
        ),
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
              } else if (diagramName == 'Context Diagram') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContextDiagramEditorScreen(),
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

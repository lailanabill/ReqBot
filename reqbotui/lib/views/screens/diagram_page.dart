import 'package:flutter/material.dart';
import 'UseCaseValidation.dart'; // Import the new validation page

class DiagramPage extends StatelessWidget {
  final String diagramName;
  
  const DiagramPage({Key? key, required this.diagramName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(diagramName)),
      body: Center(
        child: Text('Showing $diagramName', style: TextStyle(fontSize: 20)),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 187, 151, 236),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              // Navigate to the appropriate validation page based on diagram type
              if (diagramName == 'Use Case Diagram') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UseCaseValidation(),
                  ),
                );
              } else {
                // For other diagram types, you can add more conditions later
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Validation for $diagramName not implemented yet')),
                );
              }
            },
            child: Text("Edit Diagram", style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
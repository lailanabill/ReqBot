import 'package:flutter/material.dart';

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
              backgroundColor: const Color.fromARGB(255, 187, 151, 236), // Custom button color
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              // Handle edit action
            },
            child: Text("Edit Diagram", style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SpecificationsScreen extends StatelessWidget {
  const SpecificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Specifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            Text('Specifications Organized:', style: TextStyle(fontSize: 20)),
            // Placeholder for specifications content
          ],
        ),
      ),
    );
  }
}
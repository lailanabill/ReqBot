import 'package:flutter/material.dart';
import 'diagram_page.dart';

class DiagramsMenu extends StatelessWidget {
  final List<Map<String, dynamic>> diagrams = [
    {'name': 'Use Case Diagram', 'icon': Icons.account_tree},
    {'name': 'Sequence Diagram', 'icon': Icons.timeline},
    {'name': 'Database Schema', 'icon': Icons.storage},
    {'name': 'Class Diagram', 'icon': Icons.class_},
    {'name': 'Context Diagram', 'icon': Icons.blur_circular},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select a Diagram')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return _buildWideLayout(context);
          } else {
            return _buildNarrowLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: diagrams.length,
      itemBuilder: (context, index) {
        return _buildDiagramCard(context, index);
      },
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: diagrams.length,
      itemBuilder: (context, index) {
        return _buildDiagramCard(context, index);
      },
    );
  }

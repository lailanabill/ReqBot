import 'package:flutter/material.dart';
import 'package:reqbot/views/widgets/Sequencediagram/sequence_diagram_editor.dart';

class SequenceDiagramScreen extends StatefulWidget {
  const SequenceDiagramScreen({Key? key}) : super(key: key);

  @override
  _SequenceDiagramScreenState createState() => _SequenceDiagramScreenState();
}

class _SequenceDiagramScreenState extends State<SequenceDiagramScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sequence Diagram Validation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Validate Your Sequence Diagram',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Check your diagram against standard UML rules and best practices.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SequenceDiagramEditor(), // Delegate to the editor widget
              ),
            ),
          ],
        ),
      ),
    );
  }
}

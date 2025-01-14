import 'package:flutter/material.dart';
import '../widgets/transcription_display.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final String projectName;
  final String transcription;

  const ProjectDetailsScreen({
    super.key,
    required this.projectName,
    required this.transcription,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(projectName),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TranscriptionDisplay(transcription: transcription),
      ),
    );
  }
}

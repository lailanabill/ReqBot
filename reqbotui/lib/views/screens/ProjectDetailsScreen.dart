import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/transcription_display.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final int projectId;
  final String projectName;
  final String transcription;
  const ProjectDetailsScreen(
      {super.key,
      required this.transcription ,
      required this.projectName,
      required this.projectId});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> _fetchProjectDetails() async {
    final response = await _supabase
        .from('projects')
        .select()
        .eq('id', widget.projectId)
        .single();

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Project Details"),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder(
        future: _fetchProjectDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Error loading project details."));
          }

          final project = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                TranscriptionDisplay(transcription: project['transcription']),
          );
        },
      ),
    );
  }
}

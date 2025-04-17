import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reqbot/controllers/record_controller.dart';
import 'package:reqbot/views/screens/RequirementsMenuScreen.Dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

class Record extends StatefulWidget {
  const Record({super.key});

  @override
  _RecordState createState() => _RecordState();
}

class _RecordState extends State<Record> {
  String xxx = '';
  final RecordController _controller = RecordController();
  String _transcription = '';
  bool _isListening = false;

  void _updateTranscription(String transcription) {
    setState(() {
      _transcription = transcription;
    });
  }

  Future<void> _handleUploadAudio() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result != null) {
        File file = File(result.files.single.path!);
        var request = http.MultipartRequest(
            'POST',
            Uri.parse(
                'https://lastisa-1016128810332.us-central1.run.app/whisper/'));
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
        var response = await request.send();
        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          var transcription = jsonDecode(responseData)['transcription'];
          _updateTranscription(transcription);
        } else {
          throw Exception(
              "Failed to upload audio. Status code: ${response.statusCode}");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // Future<void> scam() async {
  //   final user = Supabase.instance.client.auth.currentUser;
  //   final userId = user!.id;
  //   final analyid = await Supabase.instance.client
  //       .from('users')
  //       .select("analyzer_id")
  //       .eq('id', userId)
  //       .single();

  //   final classdia = File(
  //       'reqbotui/assets/umls/class_diagram.puml'); // path to your UML file
  //   final contdia = File(
  //       'reqbotui/assets/umls/context_diagram.puml'); // path to your UML file
  //   final seqdia = File(
  //       'reqbotui/assets/umls/sequence_diagram.puml'); // path to your UML file
  //   final ucdia = File(
  //       'reqbotui/assets/umls/use_case_diagram.puml'); // path to your UML file
  //   final dbdia = File(
  //       'reqbotui/assets/umls/database_diagram.puml'); // path to your UML file
  //   final analyzerId = analyid['analyzer_id'];
  //   final String umlclass = await classdia.readAsString();
  //   final String umlcontext = await contdia.readAsString();
  //   final String umlseq = await seqdia.readAsString();
  //   final String umlusecase = await ucdia.readAsString();
  //   final String umldatabase = await dbdia.readAsString();

  //   final response = await Supabase.instance.client.from('diagrams').insert({
  //     "class_uml": umlclass,
  //     "context_uml": umlcontext,
  //     "seq_uml": umlseq,
  //     "usecase": umlusecase,
  //     "database_uml": umldatabase,
  //     "analyzer_id": analyzerId
  //   }).select();

  //   print('RES YA GELLO ${response}');
  // }

  Future<void> scam() async {
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user!.id;
    final analyid = await Supabase.instance.client
        .from('users')
        .select("analyzer_id")
        .eq('id', userId)
        .single();
    final analyzerId = analyid['analyzer_id'];

    // final classdia = File(
    //     'reqbotui/assets/umls/class_diagram.puml'); // path to your UML file

    // final String umlclass = await classdia.readAsString();
    final classdia = await rootBundle.loadString('umls/class_diagram.puml');
    print('Analyzer ID: $analyzerId ');
    print('Class UML: $classdia');
    xxx = classdia;
    final response = await Supabase.instance.client
        .from('diagrams')
        .insert({"class_uml": classdia, "project_id": analyzerId}).select();
  }

  void _showTranscriptionDialog(String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$title Transcription'),
          content: Text(_transcription.isEmpty
              ? 'No transcription available'
              : _transcription),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetings & Audio Records'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.4,
                children: [
                  _buildMeetingCard(
                      'Project Kickoff', 'April 25, 2024', 'Pending'),
                  _buildMeetingCard(
                      'Design Review', 'April 20, 2024', 'Completed',
                      showAudio: true),
                  _buildMeetingCard(
                      'Sprint Planning', 'April 15, 2024', 'In Progress'),
                  _buildMeetingCard(
                      'Retrospective', 'April 10, 2024', 'Completed'),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RequirementsMenuScreen()),
                );
              },
              child: Text('Next'),
            ),
            ElevatedButton(
              onPressed: () async {
                scam();
                print('here alooo RES YA');
              },
              child: Text('nothinggggg'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingCard(String title, String date, String status,
      {bool showAudio = false}) {
    return GestureDetector(
      onTap: () => _showTranscriptionDialog(title),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text(date, style: TextStyle(color: Colors.grey, fontSize: 12)),
              SizedBox(height: 10),
              if (showAudio)
                Row(
                  children: [
                    Icon(Icons.play_arrow, color: Colors.blue, size: 20),
                    Expanded(child: LinearProgressIndicator()),
                    Icon(Icons.stop, color: Colors.red, size: 20),
                  ],
                ),
              Spacer(),
              ElevatedButton(
                onPressed: _handleUploadAudio,
                child: Text('Upload'),
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 12),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

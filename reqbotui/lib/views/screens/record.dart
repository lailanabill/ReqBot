import 'package:flutter/material.dart';
import 'package:reqbot/controllers/record_controller.dart';
import '../widgets/project_name_input_field.dart';
import '../widgets/transcription_display.dart';
import 'home_screen.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Record extends StatefulWidget {
  const Record({super.key});

  @override
  _RecordState createState() => _RecordState();
}

class _RecordState extends State<Record> {
  final RecordController _controller = RecordController();
  final TextEditingController _projectNameController = TextEditingController();
  String _transcription = '';
  bool _isListening = false;

  void _updateTranscription(String transcription) {
    setState(() {
      _transcription = transcription;
    });
  }

  Future<void> _handleStartStopRecording() async {
    try {
      if (_isListening) {
        await _controller.stopListening();
      } else {
        await _controller.startListening(_updateTranscription);
      }
      setState(() {
        _isListening = _controller.isListening;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _handleuploadausio() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.audio);

      if (result != null) {
        File file = File(result.files.single.path!);
        print('a7a+ ${file}');
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://192.168.1.3:8080/whisper/'),
        );
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
        print('a7a request+${request}');
        var response = await request.send();
        if (response.statusCode == 200) {
          print('ma ygebha ella rgalha ya gello , kaffo 3lyk + ${response}');
          var responseData = await response.stream.bytesToString();
          var transcription = jsonDecode(responseData)['transcription'];

          _updateTranscription(transcription);
        } else {
          print('shits + ${response.statusCode}');
          throw Exception(
              "Failed to upload audio. Status code: ${response.statusCode}");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _handleSaveProject() async {
    try {
      await _controller.saveProject(
          _projectNameController.text, _transcription);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project saved successfully.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        // Wrap the content in a SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProjectNameInputField(controller: _projectNameController),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleStartStopRecording,
                child:
                    Text(_isListening ? 'Stop Recording' : 'Start Recording'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleuploadausio,
                child: Text('Upload Recording'),
              ),
              const SizedBox(height: 16),
              if (_transcription.isNotEmpty)
                TranscriptionDisplay(transcription: _transcription),
              const SizedBox(height: 16), // Add extra spacing
              ElevatedButton(
                onPressed: _handleSaveProject,
                child: const Text('Save Project'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

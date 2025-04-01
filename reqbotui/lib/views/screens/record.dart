import 'package:flutter/material.dart';
import 'package:reqbot/controllers/record_controller.dart';

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:reqbot/views/screens/RequirementsMenuScreen.Dart';

class Record extends StatefulWidget {
  const Record({super.key});

  @override
  _RecordState createState() => _RecordState();
}

class _RecordState extends State<Record> {
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

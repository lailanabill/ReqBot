import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For content type
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reqbot/controllers/record_controller.dart';
import 'package:reqbot/services/providers/data_providers.dart';
import 'package:reqbot/views/screens/RequirementsMenuScreen.Dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

class Record extends StatefulWidget {
  const Record({super.key});

  @override
  _RecordState createState() => _RecordState();
}

class _RecordState extends State<Record> {
  // final RecordController _controller = RecordController();
  String _transcription = '';
  String req_sumURI = "http://192.168.1.3:8080/reqsneww/";
  String sumURI = "http://192.168.1.3:8080/summarize/";
  String diagramsURI = "http://192.168.1.3:8080/diagrams/";

  // bool _isListening = false;

  void _updateTranscription(List<dynamic> transcription) {
    setState(() {
      _transcription = transcription
          .map((item) => "${item['speaker']}: ${item['text']}")
          .join("\n");
      context.read<DataProvider>().setTranscript(_transcription);
    });
  }

  Future<void> _handleUploadAudio() async {
    // //mobile updload function
    // try {
    //   FilePickerResult? result =
    //       await FilePicker.platform.pickFiles(type: FileType.audio);
    //   if (result != null) {
    //     File file = File(result.files.single.path!);
    //     var request = http.MultipartRequest(
    //         'POST', Uri.parse('http://192.168.1.4:8080/whisper/'));
    //     request.files.add(await http.MultipartFile.fromPath('file', file.path));
    //     var response = await request.send();
    //     if (response.statusCode == 200) {
    //       var responseData = await response.stream.bytesToString();
    //       var transcription = jsonDecode(responseData)['transcription'];
    //       _updateTranscription(transcription);
    //     } else {
    //       throw Exception(
    //           "Failed to upload audio. Status code: ${response.statusCode}");
    //     }
    //   }
    // } catch (e) {
    //   ScaffoldMessenger.of(context)
    //       .showSnackBar(SnackBar(content: Text(e.toString())));
    // }
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'audio/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((e) async {
          final bytes = reader.result as List<int>;

          var uri = Uri.parse('http://192.168.1.3:8080/whisper/');
          var request = http.MultipartRequest('POST', uri);
          request.files.add(http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: file.name,
            contentType: MediaType('audio', 'wav'),
          ));

          var response = await request.send();
          var responseData = await http.Response.fromStream(response);
          if (responseData.statusCode == 200) {
            var transcription = jsonDecode(responseData.body)['transcription'];
            _updateTranscription(transcription);
            // _getTransciptSummary(context.read()<DataProvider>().transcript);
          } else {
            print("Upload failed: ${responseData.statusCode}");
          }
        });
      }
    });
  }

  Future<void> _getTransciptSummary(String WhisperTranscript) async {
    var SumURI = Uri.parse(sumURI);
    // var DiagramsURI = Uri.parse(diagramsURI);
    final body = jsonEncode({
      "text": WhisperTranscript,
    });
    try {
      var SumRequest = await http.post(SumURI, body: body);
      if (SumRequest.statusCode == 200) {
        final responseData = jsonDecode(SumRequest.body);
        print("Summary: ${responseData['summary']}");
        context.read<DataProvider>().setSummary(responseData['summary']);
        // call to reqs func
        // _getRrequirements(WhisperTranscript, responseData['summary']);
        // call to diagrams
        // final diagramsBody = {'transcription': responseData['summary']};
        // var DiagramsRequest = await http.post(DiagramsURI, body: diagramsBody);
        // if (DiagramsRequest.statusCode == 200) {
        //   print('success');
        // } else {
        //   print("Server error: ${DiagramsRequest.statusCode}");
        //   print("Error body: ${DiagramsRequest.body}");
        // }
      } else {
        print("Server error: ${SumRequest.statusCode}");
        print("Error body: ${SumRequest.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _getRrequirements(
      String WhisperTranscript, String SummaryText) async {
    var ReqSumURI = Uri.parse(req_sumURI);

    final body = jsonEncode({
      "summ": SummaryText,
      "orig": WhisperTranscript,
    });
    try {
      var ReqSumRequest = await http.post(ReqSumURI, body: body);
      if (ReqSumRequest.statusCode == 200) {
        final responseData = jsonDecode(ReqSumRequest.body);
        print("Requirements: ${responseData['reqs']}");
        context.read<DataProvider>().setRequirements(responseData['reqs']);
      } else {
        print("Server error: ${ReqSumRequest.statusCode}");
        print("Error body: ${ReqSumRequest.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
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
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => RequirementsMenuScreen()),
                // );
                _getTransciptSummary(_transcription);
              },
              child: Text('Next'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => RequirementsMenuScreen()),
                // );
                final sumprov = context.read<DataProvider>().summary;
                final transprov = context.read<DataProvider>().transcript;
                final reqprov = context.read<DataProvider>().requirements;
                // _getTransciptSummary(_transcription);
                print("provv  Summary: $sumprov");
                print("provv  Transcript: $transprov");
                print("provv  Requirements: $reqprov");
              },
              child: Text('Printer'),
            ),
            ElevatedButton(
              onPressed: () {
                // // Navigator.push(
                // //   context,
                // //   MaterialPageRoute(
                // //       builder: (context) => RequirementsMenuScreen()),
                // // );
                // final sumprov = context.read<DataProvider>().summary;
                // final transprov = context.read<DataProvider>().transcript;
                // final reqprov = context.read<DataProvider>().requirements;
                // // _getTransciptSummary(_transcription);
                // print("provv  Summary: $sumprov");
                // print("provv  Transcript: $transprov");
                // print("provv  Requirements: $reqprov");
                print('1 from tran sum');
                _getTransciptSummary(_transcription);
                print('2 from tran sum');
              },
              child: Text('tarnscropy summary'),
            ),
            ElevatedButton(
              onPressed: () {
                // // Navigator.push(
                // //   context,
                // //   MaterialPageRoute(
                // //       builder: (context) => RequirementsMenuScreen()),
                // // );
                // final sumprov = context.read<DataProvider>().summary;
                // final transprov = context.read<DataProvider>().transcript;
                // final reqprov = context.read<DataProvider>().requirements;
                // // _getTransciptSummary(_transcription);
                // print("provv  Summary: $sumprov");
                // print("provv  Transcript: $transprov");
                // print("provv  Requirements: $reqprov");
                _getRrequirements(
                    _transcription, context.read<DataProvider>().summary);
              },
              child: Text('requirements'),
            ),
            ElevatedButton(
              onPressed: () async {
                var DiagramsURI = Uri.parse(diagramsURI);

                final diagramsBody =
                    jsonEncode({'transcription': _transcription});
                var DiagramsRequest =
                    await http.post(DiagramsURI, body: diagramsBody);
                if (DiagramsRequest.statusCode == 200) {
                  print('success ya gello');
                } else {
                  print("Server error: ${DiagramsRequest.statusCode}");
                  print("Error body: ${DiagramsRequest.body}");
                }
                // // Navigator.push(
                // //   context,
                // //   MaterialPageRoute(
                // //       builder: (context) => RequirementsMenuScreen()),
                // // );
                // final sumprov = context.read<DataProvider>().summary;
                // final transprov = context.read<DataProvider>().transcript;
                // final reqprov = context.read<DataProvider>().requirements;
                // // _getTransciptSummary(_transcription);
                // print("provv  Summary: $sumprov");
                // print("provv  Transcript: $transprov");
                // print("provv  Requirements: $reqprov");
              },
              child: Text('diagrams'),
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
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 12),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
                child: Text('Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reqbot/screens/structured_requirements.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class Record extends StatefulWidget {
  const Record({Key? key}) : super(key: key);

  @override
  _RecordState createState() => _RecordState();
}

class _RecordState extends State<Record> {
  final List<String> uploadedFiles = [];
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _transcription = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _startListening() async {
    // Request microphone permission
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required.')),
      );
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );

    if (available) {
      setState(() {
        _isListening = true;
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            _transcription = result.recognizedWords;
          });
        },
      );
    } else {
      setState(() {
        _isListening = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition unavailable.')),
      );
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
      uploadedFiles.add(_transcription);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Speech-to-text completed.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload & Convert'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Options',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Live Speech-to-Text Button
            Center(
              child: ElevatedButton.icon(
                icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                label:
                    Text(_isListening ? 'Stop Listening' : 'Start Listening'),
                onPressed: _isListening ? _stopListening : _startListening,
                style: ElevatedButton.styleFrom(
                  iconColor: _isListening ? Colors.red : Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Display Live Transcription
            if (_isListening || _transcription.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _transcription.isEmpty
                      ? 'Listening... Speak now.'
                      : 'Transcription: $_transcription',
                  style: const TextStyle(fontSize: 16),
                ),
              ),

            const SizedBox(height: 24),

            // Uploaded Files Section
            const Text(
              'Uploaded Files',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Display List of Uploaded/Transcribed Files
            Expanded(
              child: ListView.builder(
                itemCount: uploadedFiles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(uploadedFiles[index]),
                    trailing:
                        const Icon(Icons.check_circle, color: Colors.green),
                  );
                },
              ),
            ),
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 800),
              tween: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: const Offset(0, 0),
              ),
              curve: Curves.easeOut,
              builder: (context, Offset offset, child) {
                return Transform.translate(offset: offset, child: child);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(color: Colors.white), // White text
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const StructuredRequirementsScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(color: Colors.white), // White text
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

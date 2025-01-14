import 'package:permission_handler/permission_handler.dart';
import 'package:reqbot/database/database_helper.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class RecordController {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool isListening = false;
  String transcription = '';

  Future<void> startListening(Function(String) onTranscriptionUpdated) async {
    try {
      var status = await Permission.microphone.request();

      if (status.isGranted) {
        bool available = await _speech.initialize(
          onStatus: (status) => print('Speech status: $status'),
          onError: (error) => print('Speech error: $error'),
        );

        if (available) {
          isListening = true;
          _speech.listen(
            onResult: (result) {
              transcription = result.recognizedWords;
              onTranscriptionUpdated(transcription);
            },
          );
        } else {
          throw Exception('Speech recognition unavailable.');
        }
      } else if (status.isDenied) {
        throw Exception('Microphone permission is required.');
      } else if (status.isPermanentlyDenied) {
        throw Exception(
            'Microphone permission is permanently denied. Please enable it in settings.');
      }
    } catch (e) {
      throw Exception('Error initializing speech-to-text: $e');
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
    isListening = false;
  }

  Future<void> saveProject(String projectName, String transcription) async {
    if (projectName.isEmpty || transcription.isEmpty) {
      throw Exception('Please enter a project name and record audio.');
    }
    try {
      await DBHelper.instance.insertProject(projectName, transcription);
    } catch (e) {
      throw Exception('Error saving project: $e');
    }
  }
}

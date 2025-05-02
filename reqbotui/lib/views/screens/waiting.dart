import 'package:flutter/material.dart';

class ProcessingScreen extends StatefulWidget {
  final String transcription;
  const ProcessingScreen({super.key, required this.transcription});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  @override
  void initState() {
    super.initState();

    // Run the background task after UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getTranscriptSummary(widget.transcription);
    });
  }

  Future<void> _getTranscriptSummary(String transcript) async {
    // Simulate network call (replace with your actual call)
    // final result = await yourApiCall(transcript);

    // Notify user (could be snackbar, local notification, etc.)
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Project processing completed!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Processing")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Your project is being processed and you will be notified when done.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/HomeScreen');
              },
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class UploadConvertScreen extends StatelessWidget {
  const UploadConvertScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload & Convert'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Upload your audio or text files.', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Simulate file upload and conversion
              },
              child: const Text('Upload Files'),
            ),
          ],
        ),
      ),
    );
  }
}
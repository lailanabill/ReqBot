import 'package:flutter/material.dart';

class UploadConvertScreen extends StatelessWidget {
  const UploadConvertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload & Convert'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Options
            const Text('Upload Options',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            UploadButton(
                label: 'Upload Audio',
                icon: Icons.mic,
                onPressed: () {
                  // Implement audio upload functionality
                }),
            const SizedBox(height: 16),
            UploadButton(
                label: 'Upload Text',
                icon: Icons.text_fields,
                onPressed: () {
                  // Implement text upload functionality
                }),
            const SizedBox(height: 16),

            const SizedBox(height: 24), // Space before file status
            // File Processing Status
            const Text('Uploaded Files',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  FileStatusItem(
                      fileName: 'Meeting Notes Audio', isConverting: true),
                  FileStatusItem(
                      fileName: 'Project Requirements Document',
                      isConverting: false,
                      isCompleted: true),
                  FileStatusItem(
                      fileName: 'Chat Log from Stakeholders',
                      isConverting: false),
                ],
              ),
            ),

            const SizedBox(height: 24), // Space before navigation buttons
            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implement back action
                  },
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implement next action
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Tip: You can upload multiple files for batch processing. All transcripts will be editable.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class UploadButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const UploadButton(
      {required this.label,
      required this.icon,
      required this.onPressed,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(label, style: const TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20), // Large button size
      ),
    );
  }
}

class FileStatusItem extends StatelessWidget {
  final String fileName;
  final bool isConverting;
  final bool isCompleted;

  const FileStatusItem({
    required this.fileName,
    this.isConverting = false,
    this.isCompleted = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(fileName),
      trailing: isConverting
          ? const CircularProgressIndicator() // Show progress indicator while converting
          : isCompleted
              ? const Icon(Icons.check_circle,
                  color: Colors.green) // Success icon
              : const Icon(Icons.error,
                  color: Colors.red), // Error icon if not completed
    );
  }
}

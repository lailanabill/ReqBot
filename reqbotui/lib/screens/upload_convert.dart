import 'package:flutter/material.dart';
import 'structured_requirements.dart';
import 'package:file_picker/file_picker.dart';

class UploadConvertScreen extends StatefulWidget {
  const UploadConvertScreen({Key? key}) : super(key: key);
  @override
  _UploadConvertScreenState createState() => _UploadConvertScreenState();
}

class _UploadConvertScreenState extends State<UploadConvertScreen> {
  List<String> uploadedFiles = [];
  String errorMessage = '';

  Future<void> pickFile(String type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: type == 'audio'
            ? FileType.audio
            : FileType.custom, // Use FileType.custom for text
        allowedExtensions: type == 'text'
            ? ['txt', 'md']
            : null, // Specify allowed text file extensions
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          uploadedFiles.add(result.files.first.name);
          errorMessage = ''; // Clear any previous error message
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.files.first.name} uploaded successfully!'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error uploading file: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload & Convert'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upload Options',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            UploadButton(
              label: 'Upload Audio',
              icon: Icons.mic,
              onPressed: () => pickFile('audio'),
            ),
            const SizedBox(height: 16),
            UploadButton(
              label: 'Upload Text',
              icon: Icons.text_fields,
              onPressed: () => pickFile('text'),
            ),
            const SizedBox(height: 24),
            const Text('Uploaded Files',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
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
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (uploadedFiles.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please upload at least one file.')),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const StructuredRequirementsScreen()),
                      );
                    }
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (errorMessage.isNotEmpty) ...[
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ],
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
        padding: const EdgeInsets.symmetric(vertical: 20),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:reqbot/controllers/upload_convert_controller.dart';
import '../widgets/upload_button.dart';
import '../widgets/uploaded_files_list.dart';
import '../widgets/error_message.dart';
import 'record.dart';
import 'structured_requirements.dart';

class UploadConvertScreen extends StatefulWidget {
  const UploadConvertScreen({super.key});

  @override
  _UploadConvertScreenState createState() => _UploadConvertScreenState();
}

class _UploadConvertScreenState extends State<UploadConvertScreen> {
  final UploadConvertController _controller = UploadConvertController();
  List<String> uploadedFiles = [];
  String errorMessage = '';

  Future<void> _handlePickFile(String type) async {
    try {
      final files = await _controller.pickFile(type);
      setState(() {
        uploadedFiles.addAll(files);
        errorMessage = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${files.first} uploaded successfully!')),
      );
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
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
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
            UploadButton(
              label: 'Upload Audio',
              icon: Icons.mic,
              onPressed: () => _handlePickFile('audio'),
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 16),
            UploadButton(
              label: 'Upload Text',
              icon: Icons.text_fields,
              onPressed: () => _handlePickFile('text'),
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 16),
            UploadButton(
              label: 'Start Recording',
              icon: Icons.mic,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Record()),
              ),
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Uploaded Files',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: uploadedFiles.isEmpty
                  ? const Center(child: Text('No files uploaded.'))
                  : UploadedFilesList(uploadedFiles: uploadedFiles),
            ),
            const SizedBox(height: 16),
            if (errorMessage.isNotEmpty) ErrorMessage(errorMessage: errorMessage),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (uploadedFiles.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please upload at least one file.')),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StructuredRequirementsScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

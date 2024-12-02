import 'package:flutter/material.dart';
import 'package:reqbotui/screens/record.dart';
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
        allowMultiple: true,
        type: type == 'audio'
            ? FileType.audio
            : FileType.custom, // Use FileType.custom for text
        allowedExtensions: type == 'text' ? ['txt', 'md'] : null,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          uploadedFiles.addAll(result.files.map((file) => file.name));
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
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3F51B5), Color(0xFFF6F7FB)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 700),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double opacity, child) {
                    return Opacity(opacity: opacity, child: child);
                  },
                  child: const Text(
                    'Upload Options',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),

                // Upload Buttons
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: UploadButton(
                    label: 'Upload Audio',
                    icon: Icons.mic,
                    onPressed: () => pickFile('audio'),
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 16),

                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: UploadButton(
                    label: 'Upload Text',
                    icon: Icons.text_fields,
                    onPressed: () => pickFile('text'),
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 24),

                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: UploadButton(
                    label: 'Start Recording',
                    icon: Icons.text_fields,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Record()),
                    ),
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 24),

                // Uploaded Files Section
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double opacity, child) {
                    return Opacity(opacity: opacity, child: child);
                  },
                  child: const Text(
                    'Uploaded Files',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),

                // File List with Animated Items
                Expanded(
                  child: ListView.builder(
                    itemCount: uploadedFiles.length,
                    itemBuilder: (context, index) {
                      return TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 500),
                        tween: Tween<double>(begin: 0, end: 1),
                        curve: Curves.easeOut,
                        builder: (context, double scale, child) {
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: ListTile(
                          title: Text(uploadedFiles[index]),
                          trailing: const Icon(Icons.check_circle,
                              color: Colors.green),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Navigation Buttons with Animation
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
                          if (uploadedFiles.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Please upload at least one file.')),
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
                const SizedBox(height: 8),

                // Error Message
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
        ],
      ),
    );
  }
}

// Upload Button Component
class UploadButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const UploadButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      splashColor: color.withOpacity(0.3),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24), // White icon
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white, // White text
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class UploadedFilesList extends StatelessWidget {
  final List<String> uploadedFiles;

  const UploadedFilesList({super.key, required this.uploadedFiles});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: uploadedFiles.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(uploadedFiles[index]),
          trailing: const Icon(Icons.check_circle, color: Colors.green),
        );
      },
    );
  }
}

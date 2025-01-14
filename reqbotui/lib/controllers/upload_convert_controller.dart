import 'package:file_picker/file_picker.dart';

class UploadConvertController {
  List<String> uploadedFiles = [];

  Future<List<String>> pickFile(String type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: type == 'audio'
            ? FileType.audio
            : FileType.custom, // Use FileType.custom for text
        allowedExtensions: type == 'text' ? ['txt', 'md'] : null,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.map((file) => file.name).toList();
      } else {
        throw Exception('No files selected');
      }
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }
}

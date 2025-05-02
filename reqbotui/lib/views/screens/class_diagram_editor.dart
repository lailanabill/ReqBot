import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:reqbot/views/widgets/Classdiagram/editor_tools.dart'; // Adjust path as needed

class ClassDiagramEditor extends StatefulWidget {
  const ClassDiagramEditor({super.key});

  @override
  State<ClassDiagramEditor> createState() => _ClassDiagramEditorState();
}

class _ClassDiagramEditorState extends State<ClassDiagramEditor> {
  Future<Map<String, dynamic>> loadPuml() async {
    final url =
        "https://storage.googleapis.com/diagrams-data/umls/class_diagram_5.puml";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return {'body': response.body, 'StatCode': response.statusCode};
    } else {
      throw Exception("Failed to load PUML file: ${response.statusCode}");
    }
  }

  String plantumlCode = """

""";

//   String plantumlCode = '''
// @startuml
// skinparam class {
//   BackgroundColor PaleGreen
//   BorderColor DarkGreen
//   ArrowColor DarkGray
// }

// class User {
//   -String userId
//   -String name
//   -Boolean isActive
//   +getName(): String
//   +setName(name: String): void
//   +isDeactivated(): Boolean
// }

// class Task {
//   -String taskId
//   -String title
//   -String description
//   -DateTime deadline
//   -Priority priority
//   -Status status
//   +assignUser(user: User): void
//   +editTask(): void
//   +deleteTask(): void
// }

// class Notification {
//   -String notificationId
//   -String content
//   -Boolean isRead
//   -DateTime timestamp
//   +markAsRead(): void
// }

// class Preferences {
//   -Boolean pushEnabled
//   -Boolean dailySummary
//   -Boolean darkMode
//   +updatePreferences(): void
// }

// class LanguageSetting {
//   -String languageCode
//   +apply(): void
// }

// User "1" --> "0..*" Task : creates
// Task "1" --> "0..*" User : assigned to
// User "1" --> "0..*" Notification : receives
// User "1" --> "1" Preferences : has
// User "1" --> "1" LanguageSetting : uses
// @enduml
// ''';

  String? _previousPlantumlCode;
  late TextEditingController _plantumlController;

  @override
  Future<void> initState() async {
    super.initState();
    final res = await loadPuml();
    if (res['StatCode'] == 200) {
      setState(() {
        plantumlCode = res['body'];
      });
    } else {
      print("Error loading PUML file: ${res['StatCode']}");
    }
    _plantumlController = TextEditingController(text: plantumlCode);
    _previousPlantumlCode = plantumlCode;
  }

  @override
  void dispose() {
    _plantumlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Diagram Editor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Edit Your Class Diagram',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Modify classes, attributes, methods, and relationships in your UML class diagram.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            // Diagram Section (Upper)
            Expanded(
              flex: 2, // Takes more space at the top
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Image.network(
                    _getDiagramUrl(),
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('Image load error: $error');
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text('Failed to load image: $error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _updateDiagram,
                            child: const Text('Retry'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Editor Tools Section (Lower)
            Expanded(
              flex: 1, // Takes less space below
              child: SingleChildScrollView(
                child: EditorTools(
                  plantumlCode: plantumlCode,
                  plantumlController: _plantumlController,
                  onUpdate: (newCode) {
                    print('Updating PlantUML code: $newCode');
                    setState(() {
                      _previousPlantumlCode = plantumlCode;
                      plantumlCode = newCode;
                      _plantumlController.text = plantumlCode;
                    });
                    _updateDiagram();
                  },
                  onCopy: _copyCode,
                  onRevert: _revertToLastVersion,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateDiagram() {
    setState(() {});
  }

  String _getDiagramUrl() {
    final List<int> bytes = utf8.encode(plantumlCode);
    final List<int> compressed = ZLibEncoder().encode(bytes);
    final String base64Str = base64Url.encode(compressed);
    final String url = 'https://kroki.io/plantuml/png/$base64Str';
    print('Diagram URL: $url');
    return url;
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: plantumlCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PlantUML code copied to clipboard!')),
    );
  }

  void _revertToLastVersion() {
    if (_previousPlantumlCode != null) {
      print('Reverting to previous code: $_previousPlantumlCode');
      setState(() {
        plantumlCode = _previousPlantumlCode!;
        _plantumlController.text = plantumlCode;
      });
      _updateDiagram();
    }
  }
}

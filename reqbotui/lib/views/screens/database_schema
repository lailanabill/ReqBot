import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:reqbot/views/widgets/Database_schema/management.dart';
import 'package:reqbot/views/widgets/Database_schema/editing.dart';

class DatabaseSchemaEditor extends StatefulWidget {
  const DatabaseSchemaEditor({super.key});

  @override
  State<DatabaseSchemaEditor> createState() => _DatabaseSchemaEditorState();
}

class _DatabaseSchemaEditorState extends State<DatabaseSchemaEditor> {
  String plantumlCode = '''
@startuml
entity "Users" {
  *id : INT <<PK>>
  --
  name : VARCHAR(100)
  email : VARCHAR(100)
  is_active : BOOLEAN
}

entity "Tasks" {
  *task_id : INT <<PK>>
  --
  title : VARCHAR(255)
  description : TEXT
  deadline : DATETIME
  priority : VARCHAR(20)
  status : VARCHAR(20)
  created_by : INT <<FK>>
}

entity "Task_Assignees" {
  *id : INT <<PK>>
  --
  task_id : INT <<FK>>
  user_id : INT <<FK>>
}

entity "Notifications" {
  *notification_id : INT <<PK>>
  --
  user_id : INT <<FK>>
  content : TEXT
  is_read : BOOLEAN
  timestamp : DATETIME
}

entity "Preferences" {
  *id : INT <<PK>>
  --
  user_id : INT <<FK>>
  push_enabled : BOOLEAN
  daily_summary : BOOLEAN
  dark_mode : BOOLEAN
}

entity "Language_Settings" {
  *id : INT <<PK>>
  --
  user_id : INT <<FK>>
  language_code : VARCHAR(10)
}

Users ||--o{ Tasks : creates
Users ||--o{ Task_Assignees : assigned
Tasks ||--o{ Task_Assignees
Users ||--o{ Notifications : receives
Users ||--|| Preferences : has
Users ||--|| Language_Settings : uses
@enduml
''';

  String? _previousPlantumlCode;
  late TextEditingController _plantumlController;

  @override
  void initState() {
    super.initState();
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
        title: const Text('Database Schema Editor'),
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
            const Text(
              'Edit Your Database Schema',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Modify tables, columns, and relationships in your database schema.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
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
                          const Icon(Icons.broken_image, size: 64, color: Colors.grey),
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
            const SizedBox(height: 16),
            Expanded(
              flex: 3,
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
    print('Updating diagram');
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
    print('Copying code');
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'dart:convert'; // For base64 encoding
import 'package:archive/archive.dart'; // For zlib compression
import 'dart:async'; // For debouncing
import 'package:reqbot/views/widgets/Contextdiagram/context_diagram_widgets.dart';

void main() {
  runApp(const ContextDiagramEditorApp());
}

class ContextDiagramEditorApp extends StatelessWidget {
  const ContextDiagramEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Context Diagram Editor',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ContextDiagramEditorScreen(),
    );
  }
}

class ContextDiagramEditorScreen extends StatefulWidget {
  const ContextDiagramEditorScreen({super.key});

  @override
  State<ContextDiagramEditorScreen> createState() => _ContextDiagramEditorScreenState();
}

class _ContextDiagramEditorScreenState extends State<ContextDiagramEditorScreen> {
  String plantumlCode = '''
@startuml
@startuml
left to right direction
skinparam monochrome true

actor "User" as user
actor "Admin" as admin
actor "QA Tester" as qa
actor "UX Designer" as ux
rectangle "Task Management System" as sys
rectangle "Notification Service" as notify
rectangle "Authentication Service" as auth
rectangle "Frontend UI" as frontend

user --> sys : "Creates/Edits Tasks"
sys --> user : "Sends Notifications"
admin --> sys : "Manages Users"
qa --> sys : "Reports Issues"
ux --> sys : "Provides UI Feedback"

sys --> notify : "Triggers Notification"
notify --> sys : "Sends Delivery Status"

sys --> auth : "Validates User"
auth --> sys : "Returns Access Info"

user --> frontend : "Uses Interface"
frontend --> sys : "Calls APIs"

@enduml
''';

  TextEditingController entityController = TextEditingController();
  TextEditingController interactionController = TextEditingController();
  late TextEditingController plantumlController;
  Timer? _debounce;
  bool _isSystemEntity = false; // Toggle for entity type (person vs external system)

  String? _imageUrl;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    plantumlController = TextEditingController(text: plantumlCode);
    plantumlController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _updateDiagram();
        _loadDiagram();
      });
    });
    _loadDiagram();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    entityController.dispose();
    interactionController.dispose();
    plantumlController.dispose();
    super.dispose();
  }

  String encodePlantUMLForKroki(String plantUmlCode) {
    final List<int> bytes = utf8.encode(plantUmlCode);
    final List<int> compressed = ZLibEncoder().encode(bytes);
    final String base64Str = base64Url.encode(compressed);
    return base64Str;
  }

  Future<void> _loadDiagram() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String encodedDiagram = encodePlantUMLForKroki(plantumlCode);
      final String url = 'https://kroki.io/plantuml/png/$encodedDiagram';
      setState(() {
        _imageUrl = url;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error encoding diagram: $e';
        _isLoading = false;
      });
    }
  }

  void _updateDiagram() {
    final newCode = plantumlController.text.trim();
    if (!newCode.startsWith('@startuml') || !newCode.endsWith('@enduml')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PlantUML code must start with @startuml and end with @enduml'),
        ),
      );
      return;
    }
    setState(() {
      plantumlCode = newCode;
    });
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: plantumlCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copied to clipboard')),
    );
  }

  void _addEntity() {
    final entityName = entityController.text.trim();
    if (entityName.isEmpty) return;

    setState(() {
      if (_isSystemEntity) {
        // Add as an external system (rectangle)
        plantumlCode = plantumlCode.replaceFirst(
          '@enduml',
          'rectangle "$entityName" as $entityName\n@enduml',
        );
      } else {
        // Add as a person/role (actor)
        plantumlCode = plantumlCode.replaceFirst(
          '@enduml',
          'actor "$entityName" as $entityName\n@enduml',
        );
      }
      plantumlController.text = plantumlCode;
    });
    entityController.clear();
  }

  void _addInteraction() {
    final interaction = interactionController.text.trim();
    if (interaction.isEmpty) return;

    setState(() {
      // Default to labeled arrow if no label is provided
      final formattedInteraction = interaction.contains(':') 
          ? interaction 
          : '$interaction : "Data"';
      plantumlCode = plantumlCode.replaceFirst(
        '@enduml',
        '$formattedInteraction\n@enduml',
      );
      plantumlController.text = plantumlCode;
    });
    interactionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Context Diagram Editor')),
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EntityEditor(
                    entityController: entityController,
                    isSystemEntity: _isSystemEntity,
                    onSystemEntityChanged: (value) {
                      setState(() {
                        _isSystemEntity = value ?? false;
                      });
                    },
                    onAddEntity: _addEntity,
                  ),
                  InteractionEditor(
                    interactionController: interactionController,
                    onAddInteraction: _addInteraction,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PlantUML Code:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: TextField(
                      controller: plantumlController,
                      maxLines: 10,
                      style: const TextStyle(fontFamily: 'monospace'),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Edit your PlantUML code here...',
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _updateDiagram();
                          _loadDiagram();
                        },
                        child: const Text('Update Diagram'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _copyCode,
                        child: const Text('Copy Code'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Diagram:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Expanded(
                    child: DiagramContent(
                      isLoading: _isLoading,
                      errorMessage: _errorMessage,
                      imageUrl: _imageUrl,
                      onRetry: _loadDiagram,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
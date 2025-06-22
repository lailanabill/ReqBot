import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'dart:convert'; // For base64 encoding
import 'package:archive/archive.dart'; // For zlib compression
import 'package:provider/provider.dart';
import 'package:reqbot/services/providers/userProvider.dart';
import 'dart:async'; // For debouncing
import 'package:reqbot/views/widgets/Contextdiagram/context_diagram_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

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
  State<ContextDiagramEditorScreen> createState() =>
      _ContextDiagramEditorScreenState();
}

class _ContextDiagramEditorScreenState
    extends State<ContextDiagramEditorScreen> {

  void downloadFile(String fileName) async {
    try {
      final contents = await rootBundle.loadString(
          'umls/context_diagram_${context.read<UserDataProvider>().SelectedProjectId}.puml');
      final cleaned = contents.trim().replaceAll('\r\n', '\n');

      setState(() {
        plantumlCode = cleaned;
        plantumlController = TextEditingController(text: plantumlCode);
      });
      _loadDiagram();
      print("PUML Loaded:\n$plantumlCode");
    } catch (e) {
      print("Download failed: $e");
    }
  }

  String plantumlCode = "";

  TextEditingController entityController = TextEditingController();
  TextEditingController interactionController = TextEditingController();
  late TextEditingController plantumlController;
  Timer? _debounce;
  bool _isSystemEntity = false;

  String? _imageUrl;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    downloadFile('context_diagram_5.puml');
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
          content: Text(
              'PlantUML code must start with @startuml and end with @enduml'),
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

  void _addEntity(String entity, bool isSystemEntity) {
    setState(() {
      String entityType = isSystemEntity ? 'rectangle' : 'rectangle';
      String entityLine = '$entityType "$entity" as ${entity.replaceAll(' ', '')}';
      
      List<String> lines = plantumlCode.split('\n');
      int insertIndex = lines.length - 1;
      
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('@enduml')) {
          insertIndex = i;
          break;
        }
      }
      
      lines.insert(insertIndex, entityLine);
      plantumlCode = lines.join('\n');
      plantumlController.text = plantumlCode;
    });
  }

  void _addInteraction(String interaction) {
    setState(() {
      List<String> lines = plantumlCode.split('\n');
      int insertIndex = lines.length - 1;
      
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('@enduml')) {
          insertIndex = i;
          break;
        }
      }
      
      lines.insert(insertIndex, interaction);
      plantumlCode = lines.join('\n');
      plantumlController.text = plantumlCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromARGB(255, 0, 54, 218);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          'Context Diagram Editor',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              border: Border(
                bottom: BorderSide(
                  color: primaryColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.blur_circular_outlined,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Context Diagram Editor',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Define system boundaries and external entity interactions',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.4,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Diagram Section (Upper)
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            // Top decoration
                            Container(
                              width: double.infinity,
                              height: 6,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor.withOpacity(0.7),
                                    primaryColor,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                            ),
                            
                            // Content
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: DiagramContent(
                                  isLoading: _isLoading,
                                  errorMessage: _errorMessage,
                                  imageUrl: _imageUrl,
                                  onRetry: _loadDiagram,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Editor Tools Section (Lower)
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            // Header
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor.withOpacity(0.1),
                                    primaryColor.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.build_outlined,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Context Diagram Tools',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Content
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
                                      onAddEntity: () {
                                        if (entityController.text.isNotEmpty) {
                                          _addEntity(entityController.text, _isSystemEntity);
                                          entityController.clear();
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    InteractionEditor(
                                      interactionController: interactionController,
                                      onAddInteraction: () {
                                        if (interactionController.text.isNotEmpty) {
                                          _addInteraction(interactionController.text);
                                          interactionController.clear();
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    
                                    // PlantUML Code Section
                                    Text(
                                      'PlantUML Code',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: primaryColor.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: TextField(
                                        controller: plantumlController,
                                        maxLines: 10,
                                        style: GoogleFonts.jetBrainsMono(
                                          color: Colors.black87,
                                          fontSize: 13,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'PlantUML Code',
                                          labelStyle: GoogleFonts.inter(
                                            color: primaryColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: primaryColor,
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: const EdgeInsets.all(16),
                                          hintText: 'Edit your PlantUML code here...',
                                          hintStyle: GoogleFonts.jetBrainsMono(
                                            color: Colors.grey[500],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Action Buttons
                                    _buildGradientButton(
                                      context: context,
                                      text: 'Update Diagram',
                                      icon: Icons.refresh_outlined,
                                      onPressed: () {
                                        _updateDiagram();
                                        _loadDiagram();
                                      },
                                      isPrimary: true,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildSecondaryButton(
                                            context: context,
                                            text: 'Copy Code',
                                            icon: Icons.content_copy_outlined,
                                            onPressed: _copyCode,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildGradientButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    const primaryColor = Color.fromARGB(255, 0, 54, 218);
    
    return SizedBox(
      width: double.infinity,
      child: Material(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withBlue((primaryColor.blue + 40).clamp(0, 255)),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    const primaryColor = Color.fromARGB(255, 0, 54, 218);
    
    return SizedBox(
      width: double.infinity,
      child: Material(
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 
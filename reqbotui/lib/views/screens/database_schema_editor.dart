import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reqbot/services/providers/userProvider.dart';
import 'package:reqbot/views/widgets/Database_schema/management.dart';
import 'package:reqbot/views/widgets/Database_schema/editing.dart';

class DatabaseSchemaEditor extends StatefulWidget {
  const DatabaseSchemaEditor({super.key});

  @override
  State<DatabaseSchemaEditor> createState() => _DatabaseSchemaEditorState();
}

class _DatabaseSchemaEditorState extends State<DatabaseSchemaEditor> {
  // Future<Map<String, dynamic>> loadPuml() async {
  //   final url =
  //       "https://storage.googleapis.com/diagrams-data/umls/database_diagram_5.puml";

  //   final response = await http.get(Uri.parse(url));

  //   if (response.statusCode == 200) {
  //     return {'body': response.body, 'StatCode': response.statusCode};
  //   } else {
  //     throw Exception("Failed to load PUML file: ${response.statusCode}");
  //   }
  // }

  void downloadFile(String fileName) async {
    // Future<void> downloadFile(String url, String fileName) async {
    try {
      // // if mobile
      // final filePath =
      //     'F:/collage/year 4/grad/github grad/ReqBot/Lama/mainOfScripts.txt';
      // Dio dio = Dio();
      // await dio.download(url, filePath);

      // final file = File(filePath);

      // if (await file.exists()) {
      // setState(() async {
      //   _plantUmlCode = await file.readAsString();
      // });

      final contents = await rootBundle.loadString(
          'assets/umls/database_diagram_${context.read<UserDataProvider>().SelectedProjectId}.puml');
      setState(() {
        plantumlCode = contents;
        _plantumlController = TextEditingController(text: plantumlCode);
        _previousPlantumlCode = plantumlCode;
      });
      print("PUML Loaded:\n$plantumlCode");
    } catch (e) {
      print("Download failed: $e");
    }
  }

  String plantumlCode = """

""";

  String? _previousPlantumlCode;
  late TextEditingController _plantumlController;

  @override
  void initState() {
    super.initState();

    downloadFile("database_diagram_5.puml");
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

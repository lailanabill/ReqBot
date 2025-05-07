import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart'; // For zlib compression

class SequenceDiagramEditor extends StatefulWidget {
  const SequenceDiagramEditor({Key? key}) : super(key: key);

  @override
  _SequenceDiagramEditorState createState() => _SequenceDiagramEditorState();
}

class _SequenceDiagramEditorState extends State<SequenceDiagramEditor> {
  // Future<Map<String, dynamic>> loadPuml() async {
  //   final url =
  //       "https://storage.googleapis.com/diagrams-data/umls/sequence_diagram_5.puml";

  //   final response = await http.get(Uri.parse(url));

  //   if (response.statusCode == 200) {
  //     return {'body': response.body, 'StatCode': response.statusCode};
  //   } else {
  //     throw Exception("Failed to load PUML file: ${response.statusCode}");
  //   }
  // }

  Future<void> downloadFile(String fileName) async {
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
      print('found it');
      // return contents;
      // } else {
      //   throw Exception("File not found at: $filePath");
      // }
      // // if web
      // final response = await http.get(Uri.parse(url));
      // if (response.statusCode == 200) {
      //   setState(() {
      //     _plantUmlCode = response.body; // This is your PUML code
      //   });
      //   print("wasal ");
      //   print(_plantUmlCode);
      // } else {
      //   throw Exception('Failed to load file: ${response.statusCode}');
      // }

      final contents =
          await rootBundle.loadString('assets/umls/use_case_diagram_5.puml');
      setState(() {
        _plantUmlCode = contents;
      });
      print("PUML Loaded:\n$_plantUmlCode");
    } catch (e) {
      print("Download failed: $e");
    }
  }

  String _plantUmlCode = """

""";

  bool _isLoading = true;
  String? _imageUrl;
  String? _errorMessage;

//   String _plantUmlCode = '''@startuml
// actor "User" as User
// participant "Task Management System" as System
// participant "Database" as Database
// participant "Notification Service" as Notify

// User -> System: Create Task
// System -> Database: Insert Task Data
// Database --> System: Task Created

// User -> System: Assign Task to User(s)
// System -> Database: Update Task Assignees
// Database --> System: Assignment Confirmed

// System -> Notify: Trigger Assignment Notification
// Notify --> System: Notification Sent

// System --> User: Task Assigned & Notified

// @enduml''';

  List<String> _lifelines = ['User', 'System', 'Database'];
  String _selectedLifeline = 'User';
  String _lifelineToRemove = 'User';
  String _sourceLifeline = '';
  String _targetLifeline = '';
  String _messageType = '->';
  final TextEditingController _newNameController = TextEditingController();
  String _lifelineToRename = '';
  List<Map<String, dynamic>> _existingMessages = [];
  int _selectedMessageIndex = -1;

  final TextEditingController _newMessageController = TextEditingController();
  final TextEditingController _newLifelineNameController =
      TextEditingController();

  @override
  void initState() async {
    super.initState();
    _loadDiagram();
    _extractExistingMessages();
    // final res = await loadPuml();
    // if (res['StatCode'] == 200) {
    //   setState(() {
    //     _plantUmlCode = res['body'];
    //     _isLoading = false;
    //   });
    // } else {
    //   setState(() {
    //     _errorMessage = 'Failed to load PUML file: ${res['StatCode']}';
    //     _isLoading = false;
    //   });
    // }
    downloadFile('sequence_diagram_5.puml');
  }

  @override
  void dispose() {
    _newNameController.dispose();
    _newLifelineNameController.dispose();
    _newMessageController.dispose();
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
      final String encodedDiagram = encodePlantUMLForKroki(_plantUmlCode);
      final String url = 'https://kroki.io/plantuml/png/$encodedDiagram';
      setState(() {
        _imageUrl = url;
        _isLoading = false;
      });
      _extractExistingMessages();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error encoding diagram: $e';
        _isLoading = false;
      });
    }
  }

  void _extractExistingMessages() {
    _existingMessages = [];
    List<String> lines = _plantUmlCode.split('\n');
    RegExp messageRegex = RegExp(r'(\w+)\s+([-+>]+)\s+(\w+):?\s*(.*)?');

    for (String line in lines) {
      Match? match = messageRegex.firstMatch(line.trim());
      if (match != null && match.groupCount >= 4) {
        String source = match.group(1)!;
        String target = match.group(3)!;
        String type = match.group(2)!;
        String message = match.group(4)?.trim() ?? '';
        _existingMessages.add({
          'source': source,
          'target': target,
          'type': type,
          'message': message,
          'line': line
        });
      }
    }

    if (_existingMessages.isNotEmpty && _selectedMessageIndex < 0) {
      _selectedMessageIndex = 0;
    } else if (_selectedMessageIndex >= _existingMessages.length) {
      _selectedMessageIndex = _existingMessages.isEmpty ? -1 : 0;
    }
  }

  void _renameLifeline() {
    if (_newNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Please enter a new name for the lifeline')),
      );
      return;
    }

    final String oldName = _selectedLifeline;
    final String newName = _newNameController.text;

    List<String> lines = _plantUmlCode.split('\n');
    String updatedCode = '';

    for (String line in lines) {
      if (line.contains('actor "$oldName" as $oldName') ||
          line.contains('participant "$oldName" as $oldName')) {
        updatedCode += line.replaceAll(oldName, newName) + '\n';
      } else if (line.contains(oldName)) {
        updatedCode += line.replaceAll(oldName, newName) + '\n';
      } else {
        updatedCode += line + '\n';
      }
    }

    setState(() {
      _plantUmlCode = updatedCode.trim();
      _lifelines = List.from(_lifelines)
        ..remove(oldName)
        ..add(newName);
      _selectedLifeline = newName;
      _lifelineToRemove = newName;
      _newNameController.clear();
    });

    _loadDiagram();
  }

  void _removeLifeline() {
    if (_lifelines.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                const Text('Cannot remove the last lifeline from the diagram')),
      );
      return;
    }

    final String lifelineToRemove = _lifelineToRemove;
    List<String> lines = _plantUmlCode.split('\n');
    List<String> updatedLines = [];

    for (String line in lines) {
      if (!line.contains(lifelineToRemove)) {
        updatedLines.add(line);
      }
    }

    setState(() {
      _plantUmlCode = updatedLines.join('\n');
      _lifelines.remove(lifelineToRemove);
      if (_selectedLifeline == lifelineToRemove)
        _selectedLifeline = _lifelines[0];
      if (_lifelineToRemove == lifelineToRemove)
        _lifelineToRemove = _lifelines[0];
    });

    _loadDiagram();
  }

  void _addNewLifeline() {
    if (_newLifelineNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Please enter a name for the new lifeline')),
      );
      return;
    }

    final String newLifelineName = _newLifelineNameController.text;
    if (_lifelines.contains(newLifelineName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('A lifeline with this name already exists')),
      );
      return;
    }

    List<String> lines = _plantUmlCode.split('\n');
    lines.insert(1, 'participant "$newLifelineName" as $newLifelineName');

    setState(() {
      _plantUmlCode = lines.join('\n');
      _lifelines.add(newLifelineName);
      _newLifelineNameController.clear();
    });

    _loadDiagram();
  }

  void _addMessage() {
    if (_sourceLifeline.isEmpty ||
        _targetLifeline.isEmpty ||
        _newMessageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text(
                'Please select source and target lifelines and enter a message')),
      );
      return;
    }

    if (_sourceLifeline == _targetLifeline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                const Text('Source and target lifelines cannot be the same')),
      );
      return;
    }

    List<String> lines = _plantUmlCode.split('\n');
    int insertIndex = lines.indexWhere((line) => line.contains('@enduml')) - 1;
    lines.insert(insertIndex,
        '  $_sourceLifeline $_messageType $_targetLifeline: ${_newMessageController.text}');

    setState(() {
      _plantUmlCode = lines.join('\n');
      _newMessageController.clear();
      _sourceLifeline = '';
      _targetLifeline = '';
    });

    _loadDiagram();
  }

  void _removeMessage() {
    if (_selectedMessageIndex < 0 ||
        _selectedMessageIndex >= _existingMessages.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please select a message to remove')),
      );
      return;
    }

    Map<String, dynamic> message = _existingMessages[_selectedMessageIndex];
    List<String> lines = _plantUmlCode.split('\n');
    List<String> updatedLines = [];

    for (String line in lines) {
      if (line.trim() != message['line'].trim()) {
        updatedLines.add(line);
      }
    }

    setState(() {
      _plantUmlCode = updatedLines.join('\n');
      _extractExistingMessages();
    });

    _loadDiagram();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 5, // Increased from 3 to 5 to give more space to the image
          child: _buildDiagramContent(),
        ),
        Expanded(
          flex: 2, // Keep the tools section as is
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
              child: _buildValidationTools(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiagramContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 36),
            const SizedBox(height: 8),
            Text(_errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _loadDiagram, child: const Text('Retry')),
          ],
        ),
      );
    } else if (_imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.network(
            _imageUrl!,
            fit: BoxFit.contain, // Keeps the aspect ratio intact
            width: double.infinity, // Ensures it takes full available width
            height: double.infinity, // Ensures it takes full available height
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.broken_image, size: 36, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text('Failed to load image',
                      style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                      onPressed: _loadDiagram, child: const Text('Retry')),
                ],
              );
            },
          ),
        ),
      );
    } else {
      return const Center(child: Text('No diagram available'));
    }
  }

  Widget _buildValidationTools() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Validation Tools',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 8),
              title: const Text('Rename Lifeline'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            labelText: 'Select Lifeline',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12)),
                        value: _lifelines.contains(_selectedLifeline)
                            ? _selectedLifeline
                            : (_lifelines.isNotEmpty ? _lifelines[0] : null),
                        items: _lifelines
                            .map((lifeline) => DropdownMenuItem(
                                value: lifeline, child: Text(lifeline)))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedLifeline = value!),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _newNameController,
                        decoration: const InputDecoration(
                            labelText: 'New Lifeline Name',
                            hintText: 'Enter new name',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12)),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8)),
                              onPressed: _renameLifeline,
                              child: const Text('Apply Rename'))),
                    ],
                  ),
                ),
              ],
            ),
            ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 8),
              title: const Text('Remove Lifeline'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            labelText: 'Select Lifeline to Remove',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12)),
                        value: _lifelines.contains(_lifelineToRemove)
                            ? _lifelineToRemove
                            : (_lifelines.isNotEmpty ? _lifelines[0] : null),
                        items: _lifelines
                            .map((lifeline) => DropdownMenuItem(
                                value: lifeline, child: Text(lifeline)))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _lifelineToRemove = value!),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                          'Warning: This will remove the lifeline and all its messages.',
                          style: TextStyle(
                              color: Colors.red,
                              fontStyle: FontStyle.italic,
                              fontSize: 12)),
                      const SizedBox(height: 8),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8)),
                              onPressed: _removeLifeline,
                              child: const Text('Remove Lifeline'))),
                    ],
                  ),
                ),
              ],
            ),
            ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 8),
              title: const Text('Add New Lifeline'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _newLifelineNameController,
                        decoration: const InputDecoration(
                            labelText: 'New Lifeline Name',
                            hintText: 'Enter name',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12)),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8)),
                              onPressed: _addNewLifeline,
                              child: const Text('Add Lifeline'))),
                    ],
                  ),
                ),
              ],
            ),
            ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 8),
              title: const Text('Add Message'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Message Type:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      Row(
                        children: [
                          Expanded(
                              child: RadioListTile<String>(
                                  title: const Text('Synchronous',
                                      style: TextStyle(fontSize: 13)),
                                  value: '->',
                                  groupValue: _messageType,
                                  dense: true,
                                  onChanged: (value) =>
                                      setState(() => _messageType = value!))),
                          Expanded(
                              child: RadioListTile<String>(
                                  title: const Text('Asynchronous',
                                      style: TextStyle(fontSize: 13)),
                                  value: '->>',
                                  groupValue: _messageType,
                                  dense: true,
                                  onChanged: (value) =>
                                      setState(() => _messageType = value!))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Source Lifeline:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            labelText: 'Select Source',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12)),
                        value: _lifelines.contains(_sourceLifeline)
                            ? _sourceLifeline
                            : (_lifelines.isNotEmpty ? _lifelines[0] : null),
                        items: _lifelines
                            .map((lifeline) => DropdownMenuItem(
                                value: lifeline,
                                child: Text(lifeline,
                                    style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _sourceLifeline = value!),
                      ),
                      const SizedBox(height: 12),
                      const Text('Target Lifeline:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            labelText: 'Select Target',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12)),
                        value: _lifelines.contains(_targetLifeline)
                            ? _targetLifeline
                            : (_lifelines.isNotEmpty ? _lifelines[0] : null),
                        items: _lifelines
                            .map((lifeline) => DropdownMenuItem(
                                value: lifeline,
                                child: Text(lifeline,
                                    style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _targetLifeline = value!),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _newMessageController,
                        decoration: const InputDecoration(
                            labelText: 'Message',
                            hintText: 'Enter message',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12)),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8)),
                              onPressed: _addMessage,
                              child: const Text('Add Message'))),
                    ],
                  ),
                ),
              ],
            ),
            ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 8),
              title: const Text('Remove Message'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Message to Remove:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      if (_existingMessages.isEmpty)
                        const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('No messages found in the diagram.',
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey)))
                      else
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4)),
                          child: ListView.builder(
                            itemCount: _existingMessages.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> message =
                                  _existingMessages[index];
                              return RadioListTile<int>(
                                title: Text(
                                    '${message['source']} ${message['type']} ${message['target']}: ${message['message']}',
                                    style: const TextStyle(fontSize: 13)),
                                value: index,
                                groupValue: _selectedMessageIndex,
                                dense: true,
                                onChanged: (value) => setState(
                                    () => _selectedMessageIndex = value!),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8)),
                              onPressed: _existingMessages.isEmpty
                                  ? null
                                  : _removeMessage,
                              child: const Text('Remove Message'))),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

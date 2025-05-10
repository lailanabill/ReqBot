import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart'; // For zlib compression
import 'dart:convert';

import 'dart:html' as html;

class UseCaseValidation extends StatefulWidget {
  const UseCaseValidation({Key? key}) : super(key: key);

  @override
  _UseCaseValidationState createState() => _UseCaseValidationState();
}

class _UseCaseValidationState extends State<UseCaseValidation> {
  // Future<Map<String, dynamic>> loadPuml() async {
  //   final url =
  //       "https://storage.googleapis.com/diagrams-data/umls/use_case_diagram_5.puml";

  //   final response = await http.get(Uri.parse(url));

  //   if (response.statusCode == 200) {
  //     return {'body': response.body, 'StatCode': response.statusCode};
  //   } else {
  //     throw Exception("Failed to load PUML file: ${response.statusCode}");
  //   }
  // }

  void _extractActorsFromPuml() {
    final RegExp actorRegex =
        RegExp(r'actor\s+"([^"]+)"\s+as\s+(\w+)', multiLine: true);

    final matches = actorRegex.allMatches(_plantUmlCode);
    final extracted = matches
        .map((m) => m.group(2)!)
        .toList(); // Extract alias like "Student", "Admin"

    setState(() {
      _actors = extracted;
      _selectedActor = _actors.isNotEmpty ? _actors[0] : '';
      _actorToRemove = _actors.isNotEmpty ? _actors[0] : '';
    });
  }

  void _extractUseCasesFromPuml() {
    final RegExp useCaseRegex =
        RegExp(r'usecase\s+"[^"]+"\s+as\s+(\w+)', multiLine: true);

    final matches = useCaseRegex.allMatches(_plantUmlCode);
    final useCases =
        matches.map((m) => m.group(1)!).toList(); // e.g. UC001, FR002

    setState(() {
      _useCases
        ..clear()
        ..addAll(useCases);
      _selectedUseCase = _useCases.isNotEmpty ? _useCases[0] : '';
      _sourceUseCase = _useCases.isNotEmpty ? _useCases[0] : '';
      _targetUseCase = _useCases.length > 1 ? _useCases[1] : '';
    });
  }

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

      final contents =
          await rootBundle.loadString('assets/umls/use_case_diagram_5.puml');
      setState(() {
        _plantUmlCode = contents;
        // _plantUmlCode = cleanedContents;
      });
      print("PUML Loaded:\n$_plantUmlCode");
      _extractActorsFromPuml();
      _extractUseCasesFromPuml();
      _loadDiagram();
    } catch (e) {
      print("Download failed: $e");
    }
  }

  String _plantUmlCode = """""";
  bool _isLoading = true;
  String? _imageUrl;
  String? _errorMessage;

  // List of actors extracted from the PlantUML code
  List<String> _actors = [];
  String _selectedActor = 'Librarian'; // Default selected actor
  String _actorToRemove = 'Librarian'; // Default actor to remove
  String _sourceUseCase = '';
  String _targetUseCase = '';
  String _relationshipType = 'include';
  final TextEditingController _newNameController = TextEditingController();
  String _useCaseToRename = '';
  List<Map<String, dynamic>> _existingRelationships = [];
  int _selectedRelationshipIndex = -1;

  final TextEditingController _newUseCaseNameController2 =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDiagram();
    _extractExistingRelationships();
    downloadFile('use_case_diagram_5.puml');
    if (_useCases.isNotEmpty) {
      _selectedUseCase = _useCases[0];
    }
    if (_actors.isNotEmpty) {
      _selectedActorForUseCaseRemoval = _actors[0];
    }
  }

  void _addRelationship() {
    if (_sourceUseCase == _targetUseCase) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Source and target use cases cannot be the same')),
      );
      return;
    }

    // Get descriptions for display in confirmation
    Map<String, String> descriptions = _extractUseCaseDescriptions();
    String sourceDescription = descriptions[_sourceUseCase] ?? _sourceUseCase;
    String targetDescription = descriptions[_targetUseCase] ?? _targetUseCase;

    // Split the PlantUML code into lines for easier processing
    List<String> lines = _plantUmlCode.split('\n');

    // Check if the relationship already exists
    bool relationshipExists = false;
    for (String line in lines) {
      if (line.contains('$_sourceUseCase ..> $_targetUseCase') &&
          line.contains('<<$_relationshipType>>')) {
        relationshipExists = true;
        break;
      }
    }

    if (relationshipExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This relationship already exists')),
      );
      return;
    }

    // Find where to add the relationship (before the closing brace of the rectangle)
    int closingBraceIndex = -1;
    for (int i = lines.length - 1; i >= 0; i--) {
      if (lines[i].trim() == '}') {
        closingBraceIndex = i;
        break;
      }
    }

    // Add the relationship
    if (closingBraceIndex > 0) {
      lines.insert(closingBraceIndex,
          '    $_sourceUseCase ..> $_targetUseCase : <<$_relationshipType>>');
    }

    // Update the state
    setState(() {
      _plantUmlCode = lines.join('\n');
    });

    // Reload the diagram
    _loadDiagram();

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Added $_relationshipType relationship from "$sourceDescription" to "$targetDescription"')),
    );
  }

  List<String> _findActorsConnectedToUseCase(String useCase) {
    List<String> connectedActors = [];

    // Split the PlantUML code into lines
    List<String> lines = _plantUmlCode.split('\n');

    // Look for relationships between actors and this use case
    for (String line in lines) {
      // Check for pattern: Actor --> UseCase
      for (String actor in _actors) {
        if (line.contains('$actor --> $useCase')) {
          connectedActors.add(actor);
          break;
        }
      }
    }

    return connectedActors;
  }

  void _extractExistingRelationships() {
    _existingRelationships = [];

    // Split the PlantUML code into lines
    List<String> lines = _plantUmlCode.split('\n');

    // Regular expressions to match include and extend relationships
    RegExp includeRegex = RegExp(r'(\w+)\s+\.\.>\s+(\w+)\s*:\s*<<include>>');
    RegExp extendRegex = RegExp(r'(\w+)\s+\.\.>\s+(\w+)\s*:\s*<<extend>>');

    // Extract relationships
    for (String line in lines) {
      // Check for include relationships
      Match? includeMatch = includeRegex.firstMatch(line);
      if (includeMatch != null && includeMatch.groupCount >= 2) {
        String source = includeMatch.group(1)!;
        String target = includeMatch.group(2)!;
        _existingRelationships.add({
          'source': source,
          'target': target,
          'type': 'include',
          'line': line
        });
        continue;
      }

      // Check for extend relationships
      Match? extendMatch = extendRegex.firstMatch(line);
      if (extendMatch != null && extendMatch.groupCount >= 2) {
        String source = extendMatch.group(1)!;
        String target = extendMatch.group(2)!;
        _existingRelationships.add({
          'source': source,
          'target': target,
          'type': 'extend',
          'line': line
        });
      }
    }

    // Update selected index if needed
    if (_existingRelationships.isNotEmpty && _selectedRelationshipIndex < 0) {
      _selectedRelationshipIndex = 0;
    } else if (_selectedRelationshipIndex >= _existingRelationships.length) {
      _selectedRelationshipIndex = _existingRelationships.isEmpty ? -1 : 0;
    }
  }

  void _removeUseCase() {
    List<String> lines = _plantUmlCode.split('\n');
    List<String> updatedLines = [];
    if (_selectedUseCase.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a use case to remove')),
      );
      return;
    }

    // Get the description for the selected use case
    Map<String, String> descriptions = _extractUseCaseDescriptions();
    String useCaseDescription =
        descriptions[_selectedUseCase] ?? _selectedUseCase;

    if (_removeEntireUseCase) {
      // Remove the use case entirely

      // Split the PlantUML code into lines for easier processing

      // 1. Remove the use case declaration
      for (String line in lines) {
        if (!line.contains('usecase') ||
            !line.contains('as $_selectedUseCase')) {
          updatedLines.add(line);
        }
      }

      // 2. Remove all relationships involving this use case
      List<String> finalLines = [];
      for (String line in updatedLines) {
        // Skip lines containing relationships with this use case
        if (!line.contains('$_selectedUseCase -->') &&
            !line.contains('--> $_selectedUseCase') &&
            !line.contains('$_selectedUseCase ..>') &&
            !line.contains('..> $_selectedUseCase')) {
          finalLines.add(line);
        }
      }

      // 3. Remove any notes related to this use case
      List<String> withoutNotes = [];
      for (String line in finalLines) {
        if (!line.contains('note right of $_selectedUseCase') &&
            !line.contains('note left of $_selectedUseCase') &&
            !line.contains('note top of $_selectedUseCase') &&
            !line.contains('note bottom of $_selectedUseCase')) {
          withoutNotes.add(line);
        }
      }

      // Update the state
      setState(() {
        _plantUmlCode = withoutNotes.join('\n');

        // Update the use cases list
        _useCases.remove(_selectedUseCase);

        // Reset selection
        if (_useCases.isNotEmpty) {
          _selectedUseCase = _useCases[0];
        } else {
          _selectedUseCase = '';
        }
      });

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Use case "$useCaseDescription" has been removed entirely')),
      );
    } else {
      // Remove the use case only from the specified actor
      if (_selectedActorForUseCaseRemoval.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an actor')),
        );
        return;
      }

      // Keep all lines but remove the specific relationship
      for (String line in lines) {
        // Skip the line that contains the relationship between the actor and the use case
        if (!line.contains(
            '$_selectedActorForUseCaseRemoval --> $_selectedUseCase')) {
          updatedLines.add(line);
        }
      }

      // Update the state
      setState(() {
        _plantUmlCode = updatedLines.join('\n');
      });

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Use case "$useCaseDescription" has been removed from actor "$_selectedActorForUseCaseRemoval"')),
      );
    }

    // Reload the diagram with the updated code
    _loadDiagram();
  }

  @override
  void dispose() {
    _newNameController.dispose();
    _newActorNameController.dispose();
    _newUseCaseNameController.dispose();
    _newUseCaseNameController2.dispose();

    _newUseCaseNameController.dispose();
    super.dispose();
  }

  // Function to encode PlantUML for Kroki API
  String encodePlantUMLForKroki(String plantUmlCode) {
    // 1. Convert string to UTF-8 bytes
    final List<int> bytes = utf8.encode(plantUmlCode);

    // 2. Compress with zlib
    final List<int> compressed = ZLibEncoder().encode(bytes);

    // 3. Convert to base64url
    final String base64Str = base64Url.encode(compressed);

    // 4. Return the encoded string (already URL-safe with base64Url)
    return base64Str;
  }

  Future<void> _loadDiagram() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Encode the PlantUML code for Kroki
      final String encodedDiagram = encodePlantUMLForKroki(_plantUmlCode);

      // Create the Kroki API URL with the encoded diagram
      final String url = 'https://kroki.io/plantuml/png/$encodedDiagram';

      // Set the image URL
      setState(() {
        _imageUrl = url;
        _isLoading = false;
      });

      // Extract relationships after loading
      _extractExistingRelationships();

      // Clear the actors cache since we've updated the diagram
    } catch (e) {
      print('Exception: $e');
      setState(() {
        _errorMessage = 'Error encoding diagram: $e';
        _isLoading = false;
      });
    }
  }

  void _removeRelationship() {
    if (_selectedRelationshipIndex < 0 ||
        _selectedRelationshipIndex >= _existingRelationships.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a relationship to remove')),
      );
      return;
    }

    Map<String, dynamic> relationship =
        _existingRelationships[_selectedRelationshipIndex];
    String source = relationship['source'];
    String target = relationship['target'];
    String type = relationship['type'];
    String line = relationship['line'];

    // Get descriptions for display in confirmation
    Map<String, String> descriptions = _extractUseCaseDescriptions();
    String sourceDescription = descriptions[source] ?? source;
    String targetDescription = descriptions[target] ?? target;

    // Split the PlantUML code into lines
    List<String> lines = _plantUmlCode.split('\n');
    List<String> updatedLines = [];

    // Remove the relationship line
    for (String currentLine in lines) {
      if (currentLine.trim() != line.trim()) {
        updatedLines.add(currentLine);
      }
    }

    // Update the state
    setState(() {
      _plantUmlCode = updatedLines.join('\n');

      // Re-extract relationships
      _extractExistingRelationships();
    });

    // Reload the diagram
    _loadDiagram();

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Removed $type relationship from "$sourceDescription" to "$targetDescription"')),
    );
  }

  Map<String, String> _extractUseCaseDescriptions() {
    Map<String, String> descriptions = {};

    // Regular expression to match use case definitions
    // This pattern looks for: usecase "Description" as ID
    RegExp useCaseRegex = RegExp(r'usecase\s+"([^"]+)"\s+as\s+(\w+)');

    // Find all matches in the PlantUML code
    Iterable<RegExpMatch> matches = useCaseRegex.allMatches(_plantUmlCode);

    // Extract descriptions and IDs
    for (var match in matches) {
      if (match.groupCount >= 2) {
        String description = match.group(1)!;
        String id = match.group(2)!;
        descriptions[id] = description;
      }
    }

    return descriptions;
  }

  void _renameUseCase() {
    if (_newUseCaseNameController2.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a new name for the use case')),
      );
      return;
    }

    final String oldId = _useCaseToRename;
    final String newName = _newUseCaseNameController2.text;

    // Get the current description for display in confirmation
    Map<String, String> descriptions = _extractUseCaseDescriptions();
    String oldDescription = descriptions[oldId] ?? oldId;

    // Update the PlantUML code
    // We need to update the use case declaration but keep the ID the same

    // Find and replace the use case declaration
    final RegExp useCaseDeclarationRegex = RegExp(
      'usecase\\s+"[^"]+"\\s+as\\s+$oldId',
      caseSensitive: true,
    );

    String updatedCode = _plantUmlCode.replaceAll(
        useCaseDeclarationRegex, 'usecase "$newName" as $oldId');

    // Update the state
    setState(() {
      _plantUmlCode = updatedCode;
      _newUseCaseNameController2.clear();
    });

    // Reload the diagram
    _loadDiagram();

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Use case "$oldDescription" has been renamed to "$newName"')),
    );
  }

  // Function to rename an actor in the PlantUML code
  void _renameActor() {
    if (_newNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a new name for the actor')),
      );
      return;
    }

    final String oldName = _selectedActor;
    final String newName = _newNameController.text;

    // Update the PlantUML code
    // We need to update both the actor declaration and any references to it

    // 1. Update the actor declaration
    final RegExp actorDeclarationRegex = RegExp(
      'actor\\s+"$oldName"\\s+as\\s+$oldName',
      caseSensitive: true,
    );

    String updatedCode = _plantUmlCode.replaceAll(
        actorDeclarationRegex, 'actor "$newName" as $newName');

    // 2. Update references to the actor in relationships
    final RegExp actorReferenceRegex = RegExp(
      '$oldName\\s+-->',
      caseSensitive: true,
    );

    updatedCode = updatedCode.replaceAll(actorReferenceRegex, '$newName -->');

    // Update the state
    setState(() {
      _plantUmlCode = updatedCode;

      // Update the actors list
      _actors = List.from(_actors);
      int index = _actors.indexOf(oldName);
      if (index != -1) {
        _actors[index] = newName;
      }

      _selectedActor = newName;
      _actorToRemove = _actors.isNotEmpty ? _actors[0] : '';
      _newNameController.clear();
    });

    // Reload the diagram with the updated code
    _loadDiagram();
    // Navigator.pop(context); // Close the dialog
  }

  // For Add New Actor functionality
  final TextEditingController _newActorNameController = TextEditingController();
  final List<String> _useCases = [
    'UC001',
    'UC002',
    'UC003',
    'UC004',
    'UC005',
    'UC006'
  ];
  final Set<String> _selectedExistingUseCases = <String>{};
  final TextEditingController _newUseCaseNameController =
      TextEditingController();
  final Set<String> _actorsForNewUseCase = <String>{};

  final List<String> _newUseCases = [];
// Function to add a new actor to the PlantUML code
  void _addNewActor() {
    if (_newActorNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a name for the new actor')),
      );
      return;
    }

    final String newActorName = _newActorNameController.text;

    // Check if actor already exists
    if (_actors.contains(newActorName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An actor with this name already exists')),
      );
      return;
    }

    // Split the PlantUML code into lines for easier processing
    List<String> lines = _plantUmlCode.split('\n');

    // Find the index of the last actor declaration
    int lastActorIndex = -1;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim().startsWith('actor ')) {
        lastActorIndex = i;
      }
    }

    // Add the new actor declaration after the last actor
    if (lastActorIndex >= 0) {
      lines.insert(
          lastActorIndex + 1, 'actor "$newActorName" as $newActorName');
    }

    // Find the index where relationships are defined (after the rectangle opening)
    int relationshipsIndex = -1;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('rectangle "Library Management System" {')) {
        relationshipsIndex = i;
        break;
      }
    }

    // Add new use cases if any
    if (_newUseCases.isNotEmpty) {
      // Find where use cases are defined
      int useCaseIndex = -1;
      for (int i = relationshipsIndex + 1; i < lines.length; i++) {
        if (lines[i].trim().startsWith('usecase ')) {
          useCaseIndex = i;
        }
      }

      // Add new use cases after the last use case
      if (useCaseIndex >= 0) {
        for (String newUseCase in _newUseCases) {
          lines.insert(
              useCaseIndex + 1, '    usecase "$newUseCase" as $newUseCase');
          useCaseIndex++; // Increment to insert after the newly added use case
        }
      }
    }

    // Find where to add relationships (before the closing brace of the rectangle)
    int closingBraceIndex = -1;
    for (int i = lines.length - 1; i >= 0; i--) {
      if (lines[i].trim() == '}') {
        closingBraceIndex = i;
        break;
      }
    }

    // Add relationships for selected existing use cases
    if (_selectedExistingUseCases.isNotEmpty) {
      for (String useCase in _selectedExistingUseCases) {
        lines.insert(closingBraceIndex, '    $newActorName --> $useCase');
      }
    }

    // Add relationships for new use cases
    if (_newUseCases.isNotEmpty) {
      for (String newUseCase in _newUseCases) {
        lines.insert(closingBraceIndex, '    $newActorName --> $newUseCase');
      }
    }

    // Join the lines back into a single string
    String updatedCode = lines.join('\n');

    // Update the state
    setState(() {
      _plantUmlCode = updatedCode;
      _actors.add(newActorName);

      // If new use cases were added, update the use cases list
      if (_newUseCases.isNotEmpty) {
        _useCases.addAll(_newUseCases);
      }

      // Clear the input fields and selections
      _newActorNameController.clear();
      _selectedExistingUseCases.clear();
      _newUseCases.clear();
      _newUseCaseNameController.clear();
    });

    // Reload the diagram with the updated code
    _loadDiagram();

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Actor "$newActorName" has been added')),
    );
  }

  String _selectedUseCase = ''; // For storing the selected use case to remove
  bool _removeEntireUseCase =
      true; // Whether to remove the use case entirely or just from an actor
  String _selectedActorForUseCaseRemoval =
      ''; // Actor to remove the use case from

// Function to add a new use case to the temporary list
  void _addNewUseCaseToTheActor() {
    if (_newUseCaseNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a name for the new use case')),
      );
      return;
    }

    final String newUseCaseName = _newUseCaseNameController.text;

    // Check if use case already exists
    if (_useCases.contains(newUseCaseName) ||
        _newUseCases.contains(newUseCaseName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('A use case with this name already exists')),
      );
      return;
    }

    setState(() {
      _newUseCases.add(newUseCaseName);
      _newUseCaseNameController.clear();
    });
  }

  void _addNewUseCase() {
    if (_newUseCaseNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a name for the new use case')),
      );
      return;
    }

    final String newUseCaseName = _newUseCaseNameController.text;

    // Generate a new ID for the use case (e.g., UC007, UC008, etc.)
    String newUseCaseId = 'UC';
    int maxId = 0;

    // Find the highest existing use case ID number
    for (String useCase in _useCases) {
      if (useCase.startsWith('UC')) {
        try {
          int idNumber = int.parse(useCase.substring(2));
          if (idNumber > maxId) {
            maxId = idNumber;
          }
        } catch (e) {
          // Skip if not a number
        }
      }
    }

    // Create new ID with the next number, padded to 3 digits
    newUseCaseId += (maxId + 1).toString().padLeft(3, '0');

    // Split the PlantUML code into lines for easier processing
    List<String> lines = _plantUmlCode.split('\n');

    // Find where use cases are defined
    int useCaseIndex = -1;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim().startsWith('usecase ')) {
        useCaseIndex = i;
      }
    }

    // Add the new use case after the last use case
    if (useCaseIndex >= 0) {
      lines.insert(
          useCaseIndex + 1, '    usecase "$newUseCaseName" as $newUseCaseId');
    } else {
      // If no use cases found, add it after the rectangle opening
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('rectangle "Library Management System" {')) {
          lines.insert(i + 1, '    usecase "$newUseCaseName" as $newUseCaseId');
          break;
        }
      }
    }

    // Find where to add relationships (before the closing brace of the rectangle)
    int closingBraceIndex = -1;
    for (int i = lines.length - 1; i >= 0; i--) {
      if (lines[i].trim() == '}') {
        closingBraceIndex = i;
        break;
      }
    }

    // Add relationships for selected actors
    if (_actorsForNewUseCase.isNotEmpty && closingBraceIndex > 0) {
      for (String actor in _actorsForNewUseCase) {
        lines.insert(closingBraceIndex, '    $actor --> $newUseCaseId');
      }
    }

    // Update the state
    setState(() {
      _plantUmlCode = lines.join('\n');
      _useCases.add(newUseCaseId);
      _newUseCaseNameController.clear();
      _actorsForNewUseCase.clear();
    });

    // Reload the diagram
    _loadDiagram();

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Use case "$newUseCaseName" has been added')),
    );
  }

  // Function to remove an actor from the PlantUML code
  void _removeActor() {
    if (_actors.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Cannot remove the last actor from the diagram')),
      );
      return;
    }

    final String actorToRemove = _actorToRemove;

    // Split the PlantUML code into lines for easier processing
    List<String> lines = _plantUmlCode.split('\n');
    List<String> updatedLines = [];

    // 1. Remove the actor declaration line
    for (String line in lines) {
      if (!line.contains('actor "$actorToRemove" as $actorToRemove')) {
        updatedLines.add(line);
      }
    }

    // 2. Remove any relationships involving this actor
    String updatedCode = updatedLines.join('\n');

    // Remove relationships where the actor is the source
    final RegExp actorSourceRegex = RegExp(
      '$actorToRemove\\s+-->\\s+\\w+',
      caseSensitive: true,
    );
    updatedCode = updatedCode.replaceAll(actorSourceRegex, '');

    // Clean up any empty lines created by the removal
    updatedCode = updatedCode.replaceAll(RegExp(r'\n\s*\n'), '\n\n');

    // Update the state
    setState(() {
      _plantUmlCode = updatedCode;

      // Update the actors list
      _actors.remove(actorToRemove);

      // Update selected actors if needed
      if (_selectedActor == actorToRemove && _actors.isNotEmpty) {
        _selectedActor = _actors[0];
      }
      if (_actorToRemove == actorToRemove && _actors.isNotEmpty) {
        _actorToRemove = _actors[0];
      }
    });

    // Reload the diagram with the updated code
    _loadDiagram();

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Actor "$actorToRemove" has been removed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Use Case Diagram Validation'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Validate Your Use Case Diagram',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Check your diagram against standard UML rules and best practices.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            // Diagram section - make it flexible
            Expanded(
              flex: 3, // Give more space to the diagram
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildDiagramContent(),
              ),
            ),

            // Validation tools section - make it smaller
            Expanded(
              flex: 2, // Give less space to the tools
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                  child: _buildValidationTools(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagramContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 36),
            SizedBox(height: 8),
            Text(_errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 14)),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadDiagram,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    } else if (_imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: InteractiveViewer(
          boundaryMargin: EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.network(
            _imageUrl!,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print('Image error: $error');
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 36, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Failed to load image', style: TextStyle(fontSize: 14)),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadDiagram,
                    child: Text('Retry'),
                  ),
                ],
              );
            },
          ),
        ),
      );
    } else {
      return Center(
        child: Text('No diagram available'),
      );
    }
  }

  Widget _buildValidationTools() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ElevatedButton(onPressed: loadPuml, child: Text("uml")),
            Text(
              'Validation Tools',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            // Rename Actor Tool - more compact
            ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 8),
              title: Text('Rename Actor'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Actor selection dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select Actor',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        value: _actors.contains(_selectedActor)
                            ? _selectedActor
                            : (_actors.isNotEmpty ? _actors[0] : null),
                        items: _actors.map((actor) {
                          return DropdownMenuItem<String>(
                            value: actor,
                            child: Text(actor),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedActor = value;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 8),

                      // New name text field
                      TextField(
                        controller: _newNameController,
                        decoration: InputDecoration(
                          labelText: 'New Actor Name',
                          hintText: 'Enter new name for the actor',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                      ),
                      SizedBox(height: 8),

                      // Apply button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: _renameActor,
                          child: Text('Apply Rename'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Remove Actor Tool - more compact
            ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 8),
              title: Text('Remove Actor'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Actor selection dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select Actor to Remove',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        value: _actors.contains(_actorToRemove)
                            ? _actorToRemove
                            : (_actors.isNotEmpty ? _actors[0] : null),
                        items: _actors.map((actor) {
                          return DropdownMenuItem<String>(
                            value: actor,
                            child: Text(actor),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _actorToRemove = value;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 8),

                      // Warning text
                      Text(
                        'Warning: This will remove the actor and all its connections.',
                        style: TextStyle(
                            color: Colors.red,
                            fontStyle: FontStyle.italic,
                            fontSize: 12),
                      ),
                      SizedBox(height: 8),

                      // Remove button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: _removeActor,
                          child: Text('Remove Actor'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Add New Actor Tool - more compact
            ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 8),
              title: Text('Add New Actor'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // New actor name field
                      TextField(
                        controller: _newActorNameController,
                        decoration: InputDecoration(
                          labelText: 'New Actor Name',
                          hintText: 'Enter name for the new actor',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                      ),
                      SizedBox(height: 12),

                      // Existing use cases section
                      Text(
                        'Connect to existing use cases:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      SizedBox(height: 4),

                      // Wrap the checkboxes in a container with fixed height and scrolling
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ListView(
                          children: _useCases.map((useCase) {
                            // Get descriptions dynamically from the PlantUML code
                            Map<String, String> descriptions =
                                _extractUseCaseDescriptions();
                            return CheckboxListTile(
                              dense: true,
                              title: Text(descriptions[useCase] ?? useCase,
                                  style: TextStyle(fontSize: 13)),
                              value:
                                  _selectedExistingUseCases.contains(useCase),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedExistingUseCases.add(useCase);
                                  } else {
                                    _selectedExistingUseCases.remove(useCase);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 12),

                      // New use cases section
                      Text(
                        'Connect to new use cases:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      SizedBox(height: 4),

                      // New use case input with add button
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _newUseCaseNameController,
                              decoration: InputDecoration(
                                labelText: 'New Use Case Name',
                                hintText: 'Enter name',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addNewUseCaseToTheActor,
                            child: Text('Add'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),

                      // Display list of new use cases to be added
                      if (_newUseCases.isNotEmpty) ...[
                        Text(
                          'New use cases to be added:',
                          style: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 12),
                        ),
                        Container(
                          height: 80, // Reduced height
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ListView.builder(
                            itemCount: _newUseCases.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                dense: true,
                                title: Text(_newUseCases[index],
                                    style: TextStyle(fontSize: 13)),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, size: 18),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  onPressed: () {
                                    setState(() {
                                      _newUseCases.removeAt(index);
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 8),
                      ],

                      // Apply button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: _addNewActor,
                          child: Text('Add Actor with Connections'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 8),
              title: Text('Remove Use Case'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Use case selection dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select Use Case to Remove',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        value: _useCases.contains(_selectedUseCase)
                            ? _selectedUseCase
                            : (_useCases.isNotEmpty ? _useCases[0] : null),
                        items: _useCases.map((useCase) {
                          // Get descriptions using your existing method
                          Map<String, String> descriptions =
                              _extractUseCaseDescriptions();
                          return DropdownMenuItem<String>(
                            value: useCase,
                            child: Text('${descriptions[useCase] ?? useCase}',
                                style: TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedUseCase = value;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 12),

                      // Radio buttons for removal type
                      Text(
                        'Removal Type:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      RadioListTile<bool>(
                        title: Text('Remove entirely',
                            style: TextStyle(fontSize: 13)),
                        value: true,
                        groupValue: _removeEntireUseCase,
                        dense: true,
                        onChanged: (value) {
                          setState(() {
                            _removeEntireUseCase = value!;
                          });
                        },
                      ),
                      RadioListTile<bool>(
                        title: Text('Remove from specific actor',
                            style: TextStyle(fontSize: 13)),
                        value: false,
                        groupValue: _removeEntireUseCase,
                        dense: true,
                        onChanged: (value) {
                          setState(() {
                            _removeEntireUseCase = value!;
                          });
                        },
                      ),

                      // Actor selection (only visible when removing from specific actor)
                      if (!_removeEntireUseCase) ...[
                        SizedBox(height: 8),
                        Builder(
                          builder: (context) {
                            // Get actors connected to this use case
                            List<String> connectedActors =
                                _findActorsConnectedToUseCase(_selectedUseCase);

                            // If no actors are connected, show a message
                            if (connectedActors.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'No actors are connected to this use case.',
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey),
                                ),
                              );
                            }

                            // Initialize the selected actor if needed
                            if (!connectedActors
                                .contains(_selectedActorForUseCaseRemoval)) {
                              _selectedActorForUseCaseRemoval =
                                  connectedActors[0];
                            }

                            return DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Select Actor',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                              ),
                              value: connectedActors
                                      .contains(_selectedActorForUseCaseRemoval)
                                  ? _selectedActorForUseCaseRemoval
                                  : connectedActors[0],
                              items: connectedActors.map((actor) {
                                return DropdownMenuItem<String>(
                                  value: actor,
                                  child: Text(actor,
                                      style: TextStyle(fontSize: 13)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedActorForUseCaseRemoval = value;
                                  });
                                }
                              },
                            );
                          },
                        ),
                      ],

                      SizedBox(height: 12),

                      // Warning text
                      Text(
                        _removeEntireUseCase
                            ? 'Warning: This will remove the use case and all its connections from the diagram.'
                            : 'Warning: This will remove the connection between the selected actor and use case.',
                        style: TextStyle(
                            color: Colors.red,
                            fontStyle: FontStyle.italic,
                            fontSize: 12),
                      ),
                      SizedBox(height: 8),

                      // Remove button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: _removeUseCase,
                          child: Text('Remove Use Case'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 8),
              title: Text('Add New Use Case'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // New use case name field
                      TextField(
                        controller: _newUseCaseNameController,
                        decoration: InputDecoration(
                          labelText: 'New Use Case Name',
                          hintText: 'Enter name for the new use case',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Actor selection section
                      Text(
                        'Connect to actors:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      SizedBox(height: 8),

                      // Wrap the checkboxes in a container with fixed height and scrolling
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ListView(
                          children: _actors.map((actor) {
                            return CheckboxListTile(
                              dense: true,
                              title:
                                  Text(actor, style: TextStyle(fontSize: 13)),
                              value: _actorsForNewUseCase.contains(actor),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _actorsForNewUseCase.add(actor);
                                  } else {
                                    _actorsForNewUseCase.remove(actor);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Add button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: _addNewUseCase,
                          child: Text('Add Use Case'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 8),
              title: Text('Rename Use Case'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Use case selection dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select Use Case',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        value: _useCases.contains(_useCaseToRename)
                            ? _useCaseToRename
                            : (_useCases.isNotEmpty ? _useCases[0] : null),
                        items: _useCases.map((useCase) {
                          // Get descriptions using your existing method
                          Map<String, String> descriptions =
                              _extractUseCaseDescriptions();
                          return DropdownMenuItem<String>(
                            value: useCase,
                            child: Text('${descriptions[useCase] ?? useCase}',
                                style: TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _useCaseToRename = value;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 16),

                      // New name text field
                      TextField(
                        controller: _newUseCaseNameController2,
                        decoration: InputDecoration(
                          labelText: 'New Use Case Name',
                          hintText: 'Enter new name for the use case',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Apply button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: _renameUseCase,
                          child: Text('Apply Rename'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 8),
              title: Text('Add Relationship'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Relationship type selection
                      Text(
                        'Relationship Type:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('Include',
                                  style: TextStyle(fontSize: 13)),
                              value: 'include',
                              groupValue: _relationshipType,
                              dense: true,
                              onChanged: (value) {
                                setState(() {
                                  _relationshipType = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('Extend',
                                  style: TextStyle(fontSize: 13)),
                              value: 'extend',
                              groupValue: _relationshipType,
                              dense: true,
                              onChanged: (value) {
                                setState(() {
                                  _relationshipType = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      // Source use case selection
                      Text(
                        'Source Use Case:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select Source',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        value: _useCases.contains(_sourceUseCase)
                            ? _sourceUseCase
                            : (_useCases.isNotEmpty ? _useCases[0] : null),
                        items: _useCases.map((useCase) {
                          Map<String, String> descriptions =
                              _extractUseCaseDescriptions();
                          return DropdownMenuItem<String>(
                            value: useCase,
                            child: Text('${descriptions[useCase] ?? useCase}',
                                style: TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _sourceUseCase = value;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 12),

                      // Target use case selection
                      Text(
                        'Target Use Case:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select Target',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        value: _useCases.contains(_targetUseCase)
                            ? _targetUseCase
                            : (_useCases.isNotEmpty ? _useCases[0] : null),
                        items: _useCases.map((useCase) {
                          Map<String, String> descriptions =
                              _extractUseCaseDescriptions();
                          return DropdownMenuItem<String>(
                            value: useCase,
                            child: Text('${descriptions[useCase] ?? useCase}',
                                style: TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _targetUseCase = value;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 16),

                      // Add relationship button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: _addRelationship,
                          child: Text('Add Relationship'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 8),
              title: Text('Remove Relationship'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Relationship to Remove:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      SizedBox(height: 8),

                      // Show message if no relationships exist
                      if (_existingRelationships.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'No include/extend relationships found in the diagram.',
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey),
                          ),
                        )
                      else
                        // List of existing relationships
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ListView.builder(
                            itemCount: _existingRelationships.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> relationship =
                                  _existingRelationships[index];
                              String source = relationship['source'];
                              String target = relationship['target'];
                              String type = relationship['type'];

                              // Get descriptions
                              Map<String, String> descriptions =
                                  _extractUseCaseDescriptions();
                              String sourceDesc =
                                  descriptions[source] ?? source;
                              String targetDesc =
                                  descriptions[target] ?? target;

                              return RadioListTile<int>(
                                title: Text(
                                  '$sourceDesc ${type == 'include' ? '→ includes →' : '→ extends →'} $targetDesc',
                                  style: TextStyle(fontSize: 13),
                                ),
                                value: index,
                                groupValue: _selectedRelationshipIndex,
                                dense: true,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRelationshipIndex = value!;
                                  });
                                },
                              );
                            },
                          ),
                        ),

                      SizedBox(height: 16),

                      // Remove button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: _existingRelationships.isEmpty
                              ? null
                              : _removeRelationship,
                          child: Text('Remove Relationship'),
                        ),
                      ),
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

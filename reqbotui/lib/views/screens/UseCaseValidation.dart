import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart'; // For zlib compression

class UseCaseValidation extends StatefulWidget {
  const UseCaseValidation({Key? key}) : super(key: key);

  @override
  _UseCaseValidationState createState() => _UseCaseValidationState();
}

class _UseCaseValidationState extends State<UseCaseValidation> {
  bool _isLoading = true;
  String? _imageUrl;
  String? _errorMessage;
  
  // Store the PlantUML code as a class variable so we can modify it
  String _plantUmlCode = '''@startuml
left to right direction
title Library Management System - Use Case Diagram

skinparam usecase {
    BackgroundColor LightBlue
    BorderColor DarkBlue
    ArrowColor DarkGray
    ActorBorderColor Navy
}

actor "Librarian" as Librarian
actor "Member" as Member
actor "Admin" as Admin

rectangle "Library Management System" {
    usecase "Search Books" as UC001
    usecase "Borrow Book" as UC002
    usecase "Return Book" as UC003
    usecase "Manage Books" as UC004
    usecase "Register Member" as UC005
    usecase "Generate Reports" as UC006

    UC002 ..> UC001 : <<include>>
    UC003 ..> UC001 : <<include>>
    note right of UC002 : Searching is required before borrowing
    note right of UC003 : Searching is required before returning

    Member --> UC001
    Member --> UC002
    Member --> UC003
    Librarian --> UC004
    Librarian --> UC005
    Librarian --> UC006
    Admin --> UC004
    Admin --> UC006
}
@enduml''';

  // List of actors extracted from the PlantUML code
  List<String> _actors = ['Librarian', 'Member', 'Admin'];
  String _selectedActor = 'Librarian'; // Default selected actor
  String _actorToRemove = 'Librarian'; // Default actor to remove
  final TextEditingController _newNameController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadDiagram();
  }
  
  @override
  void dispose() {
    _newNameController.dispose();
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
    } catch (e) {
      print('Exception: $e');
      setState(() {
        _errorMessage = 'Error encoding diagram: $e';
        _isLoading = false;
      });
    }
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
      actorDeclarationRegex, 
      'actor "$newName" as $newName'
    );
    
    // 2. Update references to the actor in relationships
    final RegExp actorReferenceRegex = RegExp(
      '$oldName\\s+-->',
      caseSensitive: true,
    );
    
    updatedCode = updatedCode.replaceAll(
      actorReferenceRegex, 
      '$newName -->'
    );
    
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
  }
  
  // Function to remove an actor from the PlantUML code
  void _removeActor() {
    if (_actors.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot remove the last actor from the diagram')),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Validate Your Use Case Diagram',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Check your diagram against standard UML rules and best practices.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            
            Expanded(
              child: _buildDiagramContent(),
            ),
            
            // Add validation tools section
            _buildValidationTools(),
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
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDiagram,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    } else if (_imageUrl != null) {
      return SingleChildScrollView(
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
                  Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Failed to load image: $error'),
                  SizedBox(height: 16),
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
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Validation Tools',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            
            // Rename Actor Tool
            ExpansionTile(
              title: Text('Rename Actor'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Actor selection dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select Actor',
                          border: OutlineInputBorder(),
                        ),
                        value: _actors.contains(_selectedActor) ? _selectedActor : (_actors.isNotEmpty ? _actors[0] : null),
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
                      SizedBox(height: 16),
                      
                      // New name text field
                      TextField(
                        controller: _newNameController,
                        decoration: InputDecoration(
                          labelText: 'New Actor Name',
                          hintText: 'Enter new name for the actor',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Apply button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 12),
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
            
            // Remove Actor Tool
            ExpansionTile(
              title: Text('Remove Actor'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Actor selection dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select Actor to Remove',
                          border: OutlineInputBorder(),
                        ),
                        value: _actors.contains(_actorToRemove) ? _actorToRemove : (_actors.isNotEmpty ? _actors[0] : null),
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
                      SizedBox(height: 16),
                      
                      // Warning text
                      Text(
                        'Warning: This will remove the actor and all its connections from the diagram.',
                        style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
                      ),
                      SizedBox(height: 16),
                      
                      // Remove button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 12),
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
            
            // You can add more validation tools here as ExpansionTile widgets
          ],
        ),
      ),
    );
  }
}
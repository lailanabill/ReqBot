import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart'; // For zlib compression
import 'package:provider/provider.dart';
import 'dart:convert';

import 'dart:html' as html;

import 'package:reqbot/services/providers/userProvider.dart';
import 'package:google_fonts/google_fonts.dart';

class UseCaseValidation extends StatefulWidget {
  const UseCaseValidation({Key? key}) : super(key: key);

  @override
  _UseCaseValidationState createState() => _UseCaseValidationState();
}

class _UseCaseValidationState extends State<UseCaseValidation> {
  String _plantUmlCode = "";
  bool _isLoading = true;
  String? _imageUrl;
  String? _errorMessage;

  // Lists and controllers
  List<String> _actors = [];
  List<String> _useCases = [];
  String _selectedActor = '';
  String _actorToRemove = '';
  String _selectedUseCase = '';
  String _sourceUseCase = '';
  String _targetUseCase = '';
  String _relationshipType = 'include';
  String _useCaseToRename = '';
  String _selectedActorForUseCaseRemoval = '';
  List<Map<String, dynamic>> _existingRelationships = [];
  int _selectedRelationshipIndex = -1;

  // Controllers
  final TextEditingController _newNameController = TextEditingController();
  final TextEditingController _newUseCaseNameController = TextEditingController();
  final TextEditingController _newUseCaseNameController2 = TextEditingController();
  final TextEditingController _newActorNameController = TextEditingController();

  // Additional variables
  final Set<String> _selectedExistingUseCases = <String>{};
  final List<String> _newUseCases = [];

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

  @override
  void dispose() {
    _newNameController.dispose();
    _newUseCaseNameController.dispose();
    _newUseCaseNameController2.dispose();
    _newActorNameController.dispose();
    super.dispose();
  }

  Future<void> downloadFile(String fileName) async {
    try {
      final contents = await rootBundle.loadString(
          'umls/use_case_diagram_${context.read<UserDataProvider>().SelectedProjectId}.puml');
      setState(() {
        _plantUmlCode = contents;
      });
      print("PUML Loaded:\n$_plantUmlCode");
      _extractActorsFromPuml();
      _extractUseCasesFromPuml();
      _loadDiagram();
    } catch (e) {
      print("Download failed: $e");
    }
  }

  void _extractActorsFromPuml() {
    final RegExp actorRegex = RegExp(r'actor\s+"([^"]+)"\s+as\s+(\w+)', multiLine: true);
    final matches = actorRegex.allMatches(_plantUmlCode);
    final extracted = matches.map((m) => m.group(2)!).toList();

    setState(() {
      _actors = extracted;
      _selectedActor = _actors.isNotEmpty ? _actors[0] : '';
      _actorToRemove = _actors.isNotEmpty ? _actors[0] : '';
    });
  }

  void _extractUseCasesFromPuml() {
    final RegExp useCaseRegex = RegExp(r'usecase\s+"[^"]+"\s+as\s+(\w+)', multiLine: true);
    final matches = useCaseRegex.allMatches(_plantUmlCode);
    final useCases = matches.map((m) => m.group(1)!).toList();

    setState(() {
      _useCases
        ..clear()
        ..addAll(useCases);
      _selectedUseCase = _useCases.isNotEmpty ? _useCases[0] : '';
      _sourceUseCase = _useCases.isNotEmpty ? _useCases[0] : '';
      _targetUseCase = _useCases.length > 1 ? _useCases[1] : '';
    });
  }

  void _extractExistingRelationships() {
    _existingRelationships.clear();
    final RegExp relationshipRegex = RegExp(r'(\w+)\s*\.\.\>\s*(\w+)\s*:\s*<<(include|extend)>>', multiLine: true);
    final matches = relationshipRegex.allMatches(_plantUmlCode);

    for (final match in matches) {
      _existingRelationships.add({
        'source': match.group(1)!,
        'target': match.group(2)!,
        'type': match.group(3)!,
      });
    }
  }

  Map<String, String> _extractUseCaseDescriptions() {
    final Map<String, String> descriptions = {};
    final RegExp useCaseRegex = RegExp(r'usecase\s+"([^"]+)"\s+as\s+(\w+)', multiLine: true);
    final matches = useCaseRegex.allMatches(_plantUmlCode);

    for (final match in matches) {
      descriptions[match.group(2)!] = match.group(1)!;
    }
    return descriptions;
  }

  Future<void> _loadDiagram() async {
    if (_plantUmlCode.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final encodedUml = base64Encode(utf8.encode(_plantUmlCode));
      final compressedUml = base64Encode(ZLibEncoder().encode(utf8.encode(_plantUmlCode)));
      
      setState(() {
        _imageUrl = 'https://www.plantuml.com/plantuml/png/$compressedUml';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate diagram: $e';
        _isLoading = false;
      });
    }
  }

  void _renameActor() {
    if (_newNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a new name for the actor')),
      );
      return;
    }

    final String newName = _newNameController.text;
    final updatedCode = _plantUmlCode.replaceAll(
      RegExp('actor\\s+"[^"]*"\\s+as\\s+$_selectedActor'),
      'actor "$newName" as $_selectedActor',
    );

    setState(() {
      _plantUmlCode = updatedCode;
    });

    _loadDiagram();
    _newNameController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Actor renamed to "$newName"')),
    );
  }

  void _removeActor() {
    if (_actorToRemove.isEmpty) return;

    List<String> lines = _plantUmlCode.split('\n');
    lines.removeWhere((line) => 
      line.contains('actor') && line.contains(_actorToRemove) ||
      line.contains('$_actorToRemove -->') || 
      line.contains('--> $_actorToRemove')
    );

    setState(() {
      _plantUmlCode = lines.join('\n');
      _actors.remove(_actorToRemove);
      if (_actors.isNotEmpty) {
        _actorToRemove = _actors[0];
      }
    });

    _loadDiagram();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Actor "$_actorToRemove" has been removed')),
    );
  }

  void _addRelationship() {
    if (_sourceUseCase == _targetUseCase) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Source and target use cases cannot be the same')),
      );
      return;
    }

    List<String> lines = _plantUmlCode.split('\n');
    
    // Check if relationship exists
    bool relationshipExists = lines.any((line) => 
      line.contains('$_sourceUseCase ..> $_targetUseCase') && 
      line.contains('<<$_relationshipType>>')
    );

    if (relationshipExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This relationship already exists')),
      );
      return;
    }

    // Add relationship before closing brace
    int closingBraceIndex = lines.lastIndexWhere((line) => line.trim() == '}');
    if (closingBraceIndex > 0) {
      lines.insert(closingBraceIndex, '    $_sourceUseCase ..> $_targetUseCase : <<$_relationshipType>>');
    }

    setState(() {
      _plantUmlCode = lines.join('\n');
    });

    _loadDiagram();
    _extractExistingRelationships();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added $_relationshipType relationship')),
    );
  }

  void _removeRelationship() {
    if (_selectedRelationshipIndex < 0 || _selectedRelationshipIndex >= _existingRelationships.length) {
      return;
    }

    final relationship = _existingRelationships[_selectedRelationshipIndex];
    final source = relationship['source'];
    final target = relationship['target'];
    final type = relationship['type'];

    List<String> lines = _plantUmlCode.split('\n');
    lines.removeWhere((line) => 
      line.contains('$source ..> $target') && 
      line.contains('<<$type>>')
    );

    setState(() {
      _plantUmlCode = lines.join('\n');
      _selectedRelationshipIndex = -1;
    });

    _loadDiagram();
    _extractExistingRelationships();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed $type relationship')),
    );
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
          'Use Case Diagram Editor',
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
                    Icons.account_tree_outlined,
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
                        'Use Case Diagram Editor',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage actors, use cases, and relationships',
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
                                child: _buildDiagramContent(),
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
                                    'Use Case Diagram Tools',
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
                                child: _buildValidationTools(),
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

  Widget _buildDiagramContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
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
            ElevatedButton(
              onPressed: _loadDiagram,
              child: const Text('Retry'),
            ),
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
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.broken_image, size: 36, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text('Failed to load image', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadDiagram,
                    child: const Text('Retry'),
                  ),
                ],
              );
            },
          ),
        ),
      );
    } else {
      return const Center(
        child: Text('No diagram available'),
      );
    }
  }

  Widget _buildValidationTools() {
    const primaryColor = Color.fromARGB(255, 0, 54, 218);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rename Actor Tool
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primaryColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Rename Actor',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Actor',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                    const SizedBox(height: 12),
                    TextField(
                      controller: _newNameController,
                      decoration: const InputDecoration(
                        labelText: 'New Actor Name',
                        hintText: 'Enter new name for the actor',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGradientButton(
                      text: 'Apply Rename',
                      icon: Icons.check_outlined,
                      onPressed: _renameActor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Add Relationship Tool
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primaryColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Row(
              children: [
                Icon(
                  Icons.link_outlined,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Add Relationship',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Relationship type selection
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Include', style: TextStyle(fontSize: 13)),
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
                            title: const Text('Extend', style: TextStyle(fontSize: 13)),
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
                    const SizedBox(height: 12),

                    // Source use case selection
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Source Use Case',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      value: _useCases.contains(_sourceUseCase) ? _sourceUseCase : (_useCases.isNotEmpty ? _useCases[0] : null),
                      items: _useCases.map((useCase) {
                        Map<String, String> descriptions = _extractUseCaseDescriptions();
                        return DropdownMenuItem<String>(
                          value: useCase,
                          child: Text(descriptions[useCase] ?? useCase, style: const TextStyle(fontSize: 13)),
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
                    const SizedBox(height: 12),

                    // Target use case selection
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Target Use Case',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      value: _useCases.contains(_targetUseCase) ? _targetUseCase : (_useCases.isNotEmpty ? _useCases[0] : null),
                      items: _useCases.map((useCase) {
                        Map<String, String> descriptions = _extractUseCaseDescriptions();
                        return DropdownMenuItem<String>(
                          value: useCase,
                          child: Text(descriptions[useCase] ?? useCase, style: const TextStyle(fontSize: 13)),
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
                    const SizedBox(height: 16),

                    _buildGradientButton(
                      text: 'Add Relationship',
                      icon: Icons.add_outlined,
                      onPressed: _addRelationship,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Remove Relationship Tool
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primaryColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Row(
              children: [
                Icon(
                  Icons.link_off_outlined,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Remove Relationship',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Relationship to Remove:',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (_existingRelationships.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'No include/extend relationships found in the diagram.',
                          style: GoogleFonts.inter(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          itemCount: _existingRelationships.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> relationship = _existingRelationships[index];
                            String source = relationship['source'];
                            String target = relationship['target'];
                            String type = relationship['type'];

                            Map<String, String> descriptions = _extractUseCaseDescriptions();
                            String sourceDesc = descriptions[source] ?? source;
                            String targetDesc = descriptions[target] ?? target;

                            return RadioListTile<int>(
                              title: Text(
                                '$sourceDesc ${type == 'include' ? '→ includes →' : '→ extends →'} $targetDesc',
                                style: const TextStyle(fontSize: 13),
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

                    const SizedBox(height: 16),

                    _buildSecondaryButton(
                      text: 'Remove Relationship',
                      icon: Icons.delete_outline,
                      onPressed: _existingRelationships.isEmpty ? null : _removeRelationship,
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton({
    required String text,
    required IconData icon,
    required VoidCallback? onPressed,
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
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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
    required String text,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isDestructive = false,
  }) {
    const primaryColor = Color.fromARGB(255, 0, 54, 218);
    final Color buttonColor = isDestructive ? Colors.red[600]! : primaryColor;
    
    return SizedBox(
      width: double.infinity,
      child: Material(
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: buttonColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: buttonColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: buttonColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    color: buttonColor,
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

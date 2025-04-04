import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClassManagement extends StatelessWidget {
  final String plantumlCode;
  final Function(String) onUpdate;

  ClassManagement({required this.plantumlCode, required this.onUpdate});

  final TextEditingController classNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: classNameController,
          decoration: const InputDecoration(
            labelText: 'Class Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blue),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.blueAccent;
                  }
                  return null;
                },
              ),
            ),
            onPressed: () => _addClassDialog(context),
            child: const Text('Add Class'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blue),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.blueAccent;
                  }
                  return null;
                },
              ),
            ),
            onPressed: () => _renameClassDialog(context),
            child: const Text('Rename Class'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.redAccent;
                  }
                  return null;
                },
              ),
            ),
            onPressed: () => _deleteClassDialog(context),
            child: const Text('Delete Class'),
          ),
        ),
      ],
    );
  }

  void _addClassDialog(BuildContext context) {
    String className = '';
    String classType = 'class'; // Default to regular class
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Class'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: classNameController,
                      onChanged: (value) {
                        className = value.trim();
                        if (className.isEmpty || RegExp(r'[^a-zA-Z0-9_]').hasMatch(className)) {
                          errorMessage = 'Class name must be a valid identifier (letters, numbers, underscores only)';
                        } else {
                          errorMessage = null;
                        }
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Class Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: classType,
                      decoration: const InputDecoration(
                        labelText: 'Class Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'class', child: Text('Class')),
                        DropdownMenuItem(value: 'abstract class', child: Text('Abstract Class')),
                        DropdownMenuItem(value: 'interface', child: Text('Interface')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          classType = value!;
                        });
                      },
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: errorMessage != null || className.isEmpty
                      ? null
                      : () {
                          Navigator.pop(context);
                          onUpdate(plantumlCode.replaceFirst(
                            '@enduml',
                            '$classType $className {\n}\n@enduml',
                          ));
                          classNameController.clear();
                        },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _renameClassDialog(BuildContext context) {
    String oldName = '';
    String newName = '';
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Rename Class'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        oldName = value.trim();
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Old Class Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        newName = value.trim();
                        if (newName.isEmpty || RegExp(r'[^a-zA-Z0-9_]').hasMatch(newName)) {
                          errorMessage = 'New class name must be a valid identifier (letters, numbers, underscores only)';
                        } else {
                          errorMessage = null;
                        }
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'New Class Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: oldName.isEmpty || newName.isEmpty || errorMessage != null
                      ? null
                      : () {
                          Navigator.pop(context);
                          // Match class, abstract class, or interface
                          final classRegex = RegExp(
                            r'(class|abstract class|interface)\s+' + RegExp.escape(oldName) + r'\s*\{[^}]*\}',
                            multiLine: true,
                          );
                          final match = classRegex.firstMatch(plantumlCode);
                          if (match != null) {
                            final classType = match.group(1); // e.g., "class", "abstract class", "interface"
                            String newCode = plantumlCode.replaceFirst(
                              classRegex,
                              '$classType $newName {\n${match.group(0)!.split('{')[1]}',
                            );
                            // Update relationships
                            newCode = newCode.replaceAll(
                              RegExp(r'\b' + RegExp.escape(oldName) + r'\b(?=.*-->.*)'),
                              newName,
                            );
                            onUpdate(newCode);
                          }
                        },
                  child: const Text('Rename'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteClassDialog(BuildContext context) {
    String className = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Class'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) => className = value.trim(),
                  decoration: const InputDecoration(
                    labelText: 'Class Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: className.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);
                      // Match class, abstract class, or interface
                      final classRegex = RegExp(
                        r'(class|abstract class|interface)\s+' + RegExp.escape(className) + r'\s*\{[^}]*\}',
                        multiLine: true,
                      );
                      String newCode = plantumlCode.replaceAll(classRegex, '');
                      // Remove relationships involving this class
                      newCode = newCode.replaceAll(
                        RegExp(r'.*\b' + RegExp.escape(className) + r'\b.*\n(?=.*(-->|..>|--|>|<|--\|>|\*-->|o-->))'),
                        '',
                      );
                      onUpdate(newCode);
                    },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class AttributeManagement extends StatelessWidget {
  final String plantumlCode;
  final Function(String) onUpdate;

  AttributeManagement({required this.plantumlCode, required this.onUpdate});

  final TextEditingController attributeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: attributeController,
          decoration: const InputDecoration(
            labelText: 'Attribute (e.g., -String name)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blue),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.blueAccent;
                  }
                  return null;
                },
              ),
            ),
            onPressed: () => _addAttributeDialog(context),
            child: const Text('Add Attribute'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blue),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.blueAccent;
                  }
                  return null;
                },
              ),
            ),
            onPressed: () => _editAttributeDialog(context),
            child: const Text('Edit Attribute'),
          ),
        ),
      ],
    );
  }

  void _addAttributeDialog(BuildContext context) {
    String className = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Attribute'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) => className = value.trim(),
                  decoration: const InputDecoration(
                    labelText: 'Class Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: attributeController,
                  decoration: const InputDecoration(
                    labelText: 'Attribute',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: className.isEmpty || attributeController.text.trim().isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);
                      final attribute = attributeController.text.trim();
                      // Match class, abstract class, or interface
                      final classRegex = RegExp(
                        r'(class|abstract class|interface)\s+' + RegExp.escape(className) + r'\s*\{',
                        multiLine: true,
                      );
                      onUpdate(plantumlCode.replaceFirst(
                        classRegex,
                        '\$1 $className {\n  $attribute',
                      ));
                      attributeController.clear();
                    },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editAttributeDialog(BuildContext context) {
    String className = '';
    String oldAttribute = '';
    String newAttribute = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Attribute'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) => className = value.trim(),
                  decoration: const InputDecoration(
                    labelText: 'Class Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) => oldAttribute = value.trim(),
                  decoration: const InputDecoration(
                    labelText: 'Old Attribute',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) => newAttribute = value.trim(),
                  decoration: const InputDecoration(
                    labelText: 'New Attribute',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: className.isEmpty || oldAttribute.isEmpty || newAttribute.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);
                      // Match class, abstract class, or interface
                      final classRegex = RegExp(
                        r'(class|abstract class|interface)\s+' + RegExp.escape(className) + r'\s*\{[^}]*\}',
                        multiLine: true,
                      );
                      final match = classRegex.firstMatch(plantumlCode);
                      if (match != null) {
                        String classDef = match.group(0)!;
                        classDef = classDef.replaceAll(oldAttribute, newAttribute);
                        onUpdate(plantumlCode.replaceFirst(classRegex, classDef));
                      }
                    },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }
}

class MethodManagement extends StatelessWidget {
  final String plantumlCode;
  final Function(String) onUpdate;

  MethodManagement({required this.plantumlCode, required this.onUpdate});

  final TextEditingController methodController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: methodController,
          decoration: const InputDecoration(
            labelText: 'Method (e.g., +getName(): String)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blue),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.blueAccent;
                  }
                  return null;
                },
              ),
            ),
            onPressed: () => _addMethodDialog(context),
            child: const Text('Add Method'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blue),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.blueAccent;
                  }
                  return null;
                },
              ),
            ),
            onPressed: () => _editMethodDialog(context),
            child: const Text('Edit Method'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.redAccent;
                  }
                  return null;
                },
              ),
            ),
            onPressed: () => _deleteMethodDialog(context),
            child: const Text('Delete Method'),
          ),
        ),
      ],
    );
  }

  void _addMethodDialog(BuildContext context) {
    String className = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Method'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) => className = value.trim(),
                  decoration: const InputDecoration(
                    labelText: 'Class Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: methodController,
                  decoration: const InputDecoration(
                    labelText: 'Method',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: className.isEmpty || methodController.text.trim().isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);
                      final method = methodController.text.trim();
                      // Match class, abstract class, or interface
                      final classRegex = RegExp(
                        r'(class|abstract class|interface)\s+' + RegExp.escape(className) + r'\s*\{',
                        multiLine: true,
                      );
                      onUpdate(plantumlCode.replaceFirst(
                        classRegex,
                        '\$1 $className {\n  $method',
                      ));
                      methodController.clear();
                    },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editMethodDialog(BuildContext context) {
    String className = '';
    String oldMethod = '';
    String newMethod = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Method'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) => className = value.trim(),
                  decoration: const InputDecoration(
                    labelText: 'Class Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) => oldMethod = value.trim(),
                  decoration: const InputDecoration(
                    labelText: 'Old Method',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) => newMethod = value.trim(),
                  decoration: const InputDecoration(
                    labelText: 'New Method',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: className.isEmpty || oldMethod.isEmpty || newMethod.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);
                      // Match class, abstract class, or interface
                      final classRegex = RegExp(
                        r'(class|abstract class|interface)\s+' + RegExp.escape(className) + r'\s*\{[^}]*\}',
                        multiLine: true,
                      );
                      final match = classRegex.firstMatch(plantumlCode);
                      if (match != null) {
                        String classDef = match.group(0)!;
                        classDef = classDef.replaceAll(oldMethod, newMethod);
                        onUpdate(plantumlCode.replaceFirst(classRegex, classDef));
                      }
                    },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMethodDialog(BuildContext context) {
    String className = '';
    String methodName = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Method'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) => className = value.trim(),
                  decoration: const InputDecoration(
                    labelText: 'Class Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) => methodName = value.trim(),
                  decoration: const InputDecoration(
                    labelText: 'Method Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: className.isEmpty || methodName.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);
                      // Match class, abstract class, or interface
                      final classRegex = RegExp(
                        r'(class|abstract class|interface)\s+' + RegExp.escape(className) + r'\s*\{[^}]*\}',
                        multiLine: true,
                      );
                      final match = classRegex.firstMatch(plantumlCode);
                      if (match != null) {
                        String classDef = match.group(0)!;
                        classDef = classDef.replaceAll(RegExp('  ' + RegExp.escape(methodName) + r'\n'), '');
                        onUpdate(plantumlCode.replaceFirst(classRegex, classDef));
                      }
                    },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class RelationshipManagement extends StatelessWidget {
  final String plantumlCode;
  final Function(String) onUpdate;

  RelationshipManagement({required this.plantumlCode, required this.onUpdate});

  // Map of relationship types to their PlantUML syntax
  final Map<String, String> relationshipTypes = {
    'Inheritance (extends)': '--|>',
    'Inheritance (implements)': '<|--',
    'Association': '-->',
    'Reverse Association': '<--',
    'Composition': '*-->',
    'Aggregation': 'o-->',
    'Reverse Aggregation': '<--o',
    'Dependency': '..>',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.green),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.greenAccent;
                  }
                  return null;
                },
              ),
            ),
            onPressed: () => _addRelationshipDialog(context),
            child: const Text('Add Relationship'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blue),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.blueAccent;
                  }
                  return null;
                },
              ),
            ),
            onPressed: () => _editRelationshipDialog(context),
            child: const Text('Edit Relationship'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.redAccent;
                  }
                  return null;
                },
              ),
            ),
            onPressed: () => _removeRelationshipDialog(context),
            child: const Text('Remove Relationship'),
          ),
        ),
      ],
    );
  }

  void _addRelationshipDialog(BuildContext context) {
    String fromClass = '';
    String toClass = '';
    String relationshipType = 'Association'; // Default to Association
    String multiplicityFrom = '';
    String multiplicityTo = '';
    String label = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Relationship'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        fromClass = value.trim();
                        setDialogState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'From Class',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        toClass = value.trim();
                        setDialogState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'To Class',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: relationshipType,
                      decoration: const InputDecoration(
                        labelText: 'Relationship Type',
                        border: OutlineInputBorder(),
                      ),
                      items: relationshipTypes.keys.map((String key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(key),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          relationshipType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        multiplicityFrom = value.trim();
                        setDialogState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Multiplicity (From) e.g., "1"',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        multiplicityTo = value.trim();
                        setDialogState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Multiplicity (To) e.g., "0..*"',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        label = value.trim();
                        setDialogState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Label (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: fromClass.isEmpty || toClass.isEmpty
                      ? null
                      : () {
                          Navigator.pop(context);
                          String relationshipSyntax = relationshipTypes[relationshipType]!;
                          String relationshipLine = '';
                          if (multiplicityFrom.isNotEmpty && multiplicityTo.isNotEmpty) {
                            relationshipLine = '"$multiplicityFrom" $relationshipSyntax "$multiplicityTo"';
                          } else if (multiplicityFrom.isNotEmpty) {
                            relationshipLine = '"$multiplicityFrom" $relationshipSyntax';
                          } else if (multiplicityTo.isNotEmpty) {
                            relationshipLine = '$relationshipSyntax "$multiplicityTo"';
                          } else {
                            relationshipLine = relationshipSyntax;
                          }
                          if (label.isNotEmpty) {
                            relationshipLine += ' : $label';
                          }
                          onUpdate(plantumlCode.replaceFirst(
                            '@enduml',
                            '$fromClass $relationshipLine $toClass\n@enduml',
                          ));
                        },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editRelationshipDialog(BuildContext context) {
    String fromClass = '';
    String toClass = '';
    String oldMultiplicityFrom = '';
    String oldMultiplicityTo = '';
    String oldLabel = '';
    String newMultiplicityFrom = '';
    String newMultiplicityTo = '';
    String newLabel = '';
    String oldRelationshipType = 'Association';
    String newRelationshipType = 'Association';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Relationship'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        fromClass = value.trim();
                        setDialogState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'From Class',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        toClass = value.trim();
                        setDialogState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'To Class',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: oldRelationshipType,
                      decoration: const InputDecoration(
                        labelText: 'Old Relationship Type',
                        border: OutlineInputBorder(),
                      ),
                      items: relationshipTypes.keys.map((String key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(key),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          oldRelationshipType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        oldMultiplicityFrom = value.trim();
                        setDialogState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Old Multiplicity (From) e.g., "1"',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        oldMultiplicityTo = value.trim();
                        setDialogState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Old Multiplicity (To) e.g., "0..*"',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        oldLabel = value.trim();
                        setDialogState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Old Label (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: newRelationshipType,
                      decoration: const InputDecoration(
                        labelText: 'New Relationship Type',
                        border: OutlineInputBorder(),
                      ),
                      items: relationshipTypes.keys.map((String key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(key),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          newRelationshipType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        newMultiplicityFrom = value.trim();
                        setDialogState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'New Multiplicity (From) e.g., "1"',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        newMultiplicityTo = value.trim();
                        setDialogState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'New Multiplicity (To) e.g., "0..*"',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        newLabel = value.trim();
                        setDialogState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'New Label (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: fromClass.isEmpty || toClass.isEmpty
                      ? null
                      : () {
                          Navigator.pop(context);
                          String oldRelationshipSyntax = relationshipTypes[oldRelationshipType]!;
                          String oldRelationshipLine = '';
                          if (oldMultiplicityFrom.isNotEmpty && oldMultiplicityTo.isNotEmpty) {
                            oldRelationshipLine = '"$oldMultiplicityFrom" $oldRelationshipSyntax "$oldMultiplicityTo"';
                          } else if (oldMultiplicityFrom.isNotEmpty) {
                            oldRelationshipLine = '"$oldMultiplicityFrom" $oldRelationshipSyntax';
                          } else if (oldMultiplicityTo.isNotEmpty) {
                            oldRelationshipLine = '$oldRelationshipSyntax "$oldMultiplicityTo"';
                          } else {
                            oldRelationshipLine = oldRelationshipSyntax;
                          }
                          if (oldLabel.isNotEmpty) {
                            oldRelationshipLine += ' : $oldLabel';
                          }

                          String newRelationshipSyntax = relationshipTypes[newRelationshipType]!;
                          String newRelationshipLine = '';
                          if (newMultiplicityFrom.isNotEmpty && newMultiplicityTo.isNotEmpty) {
                            newRelationshipLine = '"$newMultiplicityFrom" $newRelationshipSyntax "$newMultiplicityTo"';
                          } else if (newMultiplicityFrom.isNotEmpty) {
                            newRelationshipLine = '"$newMultiplicityFrom" $newRelationshipSyntax';
                          } else if (newMultiplicityTo.isNotEmpty) {
                            newRelationshipLine = '$newRelationshipSyntax "$newMultiplicityTo"';
                          } else {
                            newRelationshipLine = newRelationshipSyntax;
                          }
                          if (newLabel.isNotEmpty) {
                            newRelationshipLine += ' : $newLabel';
                          }

                          onUpdate(plantumlCode.replaceAll(
                            '$fromClass $oldRelationshipLine $toClass',
                            '$fromClass $newRelationshipLine $toClass',
                          ));
                        },
                  child: const Text('Edit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeRelationshipDialog(BuildContext context) {
    String fromClass = '';
    String toClass = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Relationship'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) => fromClass = value.trim(),
                  decoration: const InputDecoration(
                    labelText: 'From Class',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) => toClass = value.trim(),
                  decoration: const InputDecoration(
                    labelText: 'To Class',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: fromClass.isEmpty || toClass.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);
                      // Match any relationship type
                      onUpdate(plantumlCode.replaceAll(
                        RegExp(
                          r'.*\b' +
                              RegExp.escape(fromClass) +
                              r'\b.*(-->|..>|--|>|<|--\|>|\*-->|o-->).*\b' +
                              RegExp.escape(toClass) +
                              r'\b.*\n',
                        ),
                        '',
                      ));
                    },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}
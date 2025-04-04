import 'package:flutter/material.dart';

class TableManagement extends StatelessWidget {
  final String plantumlCode;
  final Function(String) onUpdate;

  TableManagement({required this.plantumlCode, required this.onUpdate});

  final TextEditingController tableNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: tableNameController,
          decoration: const InputDecoration(
            labelText: 'Table Name',
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
            ),
            onPressed: () => _addTableDialog(context),
            child: const Text('Add Table'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blue),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
            ),
            onPressed: () => _renameTableDialog(context),
            child: const Text('Rename Table'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
            ),
            onPressed: () => _deleteTableDialog(context),
            child: const Text('Delete Table'),
          ),
        ),
      ],
    );
  }

  void _addTableDialog(BuildContext context) {
    String tableName = '';
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Table'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tableNameController,
                      onChanged: (value) {
                        tableName = value.trim();
                        print('Table name input: $tableName');
                        if (tableName.isEmpty || RegExp(r'[^a-zA-Z0-9_]').hasMatch(tableName)) {
                          errorMessage = 'Table name must be a valid identifier (letters, numbers, underscores only)';
                        } else {
                          errorMessage = null;
                        }
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: 'Table Name',
                        border: const OutlineInputBorder(),
                        errorText: errorMessage,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (tableName.isEmpty) {
                      print('Add Table button disabled: Table name is empty');
                      return;
                    }
                    if (errorMessage != null) {
                      print('Add Table button disabled: $errorMessage');
                      return;
                    }
                    print('Adding table: $tableName');
                    Navigator.pop(context);
                    onUpdate(plantumlCode.replaceFirst(
                      '@enduml',
                      'entity "$tableName" {\n}\n@enduml',
                    ));
                    tableNameController.clear();
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

  void _renameTableDialog(BuildContext context) {
    String oldName = '';
    String newName = '';
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Rename Table'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        oldName = value.trim();
                        print('Old table name input: $oldName');
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Old Table Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        newName = value.trim();
                        print('New table name input: $newName');
                        if (newName.isEmpty || RegExp(r'[^a-zA-Z0-9_]').hasMatch(newName)) {
                          errorMessage = 'New table name must be a valid identifier';
                        } else {
                          errorMessage = null;
                        }
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: 'New Table Name',
                        border: const OutlineInputBorder(),
                        errorText: errorMessage,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (oldName.isEmpty || newName.isEmpty) {
                      print('Rename Table button disabled: Old or new name is empty');
                      return;
                    }
                    if (errorMessage != null) {
                      print('Rename Table button disabled: $errorMessage');
                      return;
                    }
                    print('Renaming table from $oldName to $newName');
                    Navigator.pop(context);
                    final tableRegex = RegExp(
                      r'entity\s*"' + RegExp.escape(oldName) + r'"\s*\{[^}]*\}',
                      multiLine: true,
                    );
                    final match = tableRegex.firstMatch(plantumlCode);
                    if (match != null) {
                      String newCode = plantumlCode.replaceFirst(
                        tableRegex,
                        'entity "$newName" {\n${match.group(0)!.split('{')[1]}',
                      );
                      newCode = newCode.replaceAll(
                        RegExp(r'\b' + RegExp.escape(oldName) + r'\b(?=.*(-->|o-->|\*-->))'),
                        newName,
                      );
                      onUpdate(newCode);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Table "$oldName" not found')),
                      );
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

  void _deleteTableDialog(BuildContext context) {
    String tableName = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Delete Table'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        tableName = value.trim();
                        print('Table name to delete: $tableName');
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Table Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (tableName.isEmpty) {
                      print('Delete Table button disabled: Table name is empty');
                      return;
                    }
                    print('Deleting table: $tableName');
                    Navigator.pop(context);
                    final tableRegex = RegExp(
                      r'entity\s*"' + RegExp.escape(tableName) + r'"\s*\{[^}]*\}',
                      multiLine: true,
                    );
                    String newCode = plantumlCode.replaceAll(tableRegex, '');
                    newCode = newCode.replaceAll(
                      RegExp(r'.*\b' + RegExp.escape(tableName) + r'\b.*\n(?=.*(-->|o-->|\*-->))'),
                      '',
                    );
                    if (newCode != plantumlCode) {
                      onUpdate(newCode);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Table "$tableName" not found')),
                      );
                    }
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class ColumnManagement extends StatelessWidget {
  final String plantumlCode;
  final Function(String) onUpdate;

  ColumnManagement({required this.plantumlCode, required this.onUpdate});

  final TextEditingController columnController = TextEditingController();
  final List<String> dataTypes = ['INT', 'VARCHAR', 'DATE', 'BOOLEAN', 'FLOAT'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: columnController,
          decoration: const InputDecoration(
            labelText: 'Column (e.g., id : INT <<PK>>)',
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
            ),
            onPressed: () => _addColumnDialog(context),
            child: const Text('Add Column'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blue),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
            ),
            onPressed: () => _editColumnDialog(context),
            child: const Text('Edit Column'),
          ),
        ),
      ],
    );
  }

  void _addColumnDialog(BuildContext context) {
    String tableName = '';
    String columnName = '';
    String dataType = 'INT';
    bool isPrimaryKey = false;
    bool isForeignKey = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Column'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        tableName = value.trim();
                        print('Table name for column: $tableName');
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Table Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: columnController,
                      onChanged: (value) {
                        columnName = value.trim();
                        print('Column name input: $columnName');
                        if (columnName.isEmpty || RegExp(r'[^a-zA-Z0-9_]').hasMatch(columnName)) {
                          errorMessage = 'Column name must be a valid identifier';
                        } else {
                          errorMessage = null;
                        }
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: 'Column Name',
                        border: const OutlineInputBorder(),
                        errorText: errorMessage,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: dataType,
                      decoration: const InputDecoration(
                        labelText: 'Data Type',
                        border: OutlineInputBorder(),
                      ),
                      items: dataTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          dataType = value!;
                          print('Data type selected: $dataType');
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Primary Key'),
                      value: isPrimaryKey,
                      onChanged: (value) {
                        setState(() {
                          isPrimaryKey = value!;
                          print('Primary Key: $isPrimaryKey');
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Foreign Key'),
                      value: isForeignKey,
                      onChanged: (value) {
                        setState(() {
                          isForeignKey = value!;
                          print('Foreign Key: $isForeignKey');
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (tableName.isEmpty || columnName.isEmpty) {
                      print('Add Column button disabled: Table or column name is empty');
                      return;
                    }
                    if (errorMessage != null) {
                      print('Add Column button disabled: $errorMessage');
                      return;
                    }
                    print('Adding column to $tableName: $columnName : $dataType');
                    Navigator.pop(context);
                    String columnDef = '$columnName : $dataType';
                    if (isPrimaryKey) columnDef = '*${columnDef} <<PK>>';
                    if (isForeignKey) columnDef += ' <<FK>>';
                    final tableRegex = RegExp(
                      r'entity\s*"' + RegExp.escape(tableName) + r'"\s*\{\s*([^\}]*?)\s*\}',
                      multiLine: true,
                    );
                    final match = tableRegex.firstMatch(plantumlCode);
                    if (match != null) {
                      final existingContent = match.group(1) ?? '';
                      final newContent = existingContent.isEmpty ? columnDef : '$existingContent\n  $columnDef';
                      onUpdate(plantumlCode.replaceFirst(
                        tableRegex,
                        'entity "$tableName" {\n  $newContent\n}',
                      ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Table "$tableName" not found')),
                      );
                    }
                    columnController.clear();
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

  void _editColumnDialog(BuildContext context) {
    String tableName = '';
    String oldColumnName = '';
    String newColumnName = '';
    String newDataType = 'INT';
    bool isPrimaryKey = false;
    bool isForeignKey = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Column'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        tableName = value.trim();
                        print('Table name for edit: $tableName');
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Table Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        oldColumnName = value.trim();
                        print('Old column name input: $oldColumnName');
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Old Column Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        newColumnName = value.trim();
                        print('New column name input: $newColumnName');
                        if (newColumnName.isEmpty || RegExp(r'[^a-zA-Z0-9_]').hasMatch(newColumnName)) {
                          errorMessage = 'New column name must be a valid identifier';
                        } else {
                          errorMessage = null;
                        }
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: 'New Column Name',
                        border: const OutlineInputBorder(),
                        errorText: errorMessage,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: newDataType,
                      decoration: const InputDecoration(
                        labelText: 'New Data Type',
                        border: OutlineInputBorder(),
                      ),
                      items: dataTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          newDataType = value!;
                          print('New data type selected: $newDataType');
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Primary Key'),
                      value: isPrimaryKey,
                      onChanged: (value) {
                        setState(() {
                          isPrimaryKey = value!;
                          print('Primary Key: $isPrimaryKey');
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Foreign Key'),
                      value: isForeignKey,
                      onChanged: (value) {
                        setState(() {
                          isForeignKey = value!;
                          print('Foreign Key: $isForeignKey');
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (tableName.isEmpty || oldColumnName.isEmpty || newColumnName.isEmpty) {
                      print('Edit Column button disabled: Table, old, or new column name is empty');
                      return;
                    }
                    if (errorMessage != null) {
                      print('Edit Column button disabled: $errorMessage');
                      return;
                    }
                    print('Editing column in $tableName: $oldColumnName -> $newColumnName : $newDataType');
                    Navigator.pop(context);
                    final tableRegex = RegExp(
                      r'entity\s*"' + RegExp.escape(tableName) + r'"\s*\{[^}]*\}',
                      multiLine: true,
                    );
                    final match = tableRegex.firstMatch(plantumlCode);
                    if (match != null) {
                      String tableDef = match.group(0)!;
                      String newColumnDef = '$newColumnName : $newDataType';
                      if (isPrimaryKey) newColumnDef = '*${newColumnDef} <<PK>>';
                      if (isForeignKey) newColumnDef += ' <<FK>>';
                      if (tableDef.contains(oldColumnName)) {
                        tableDef = tableDef.replaceAll(
                          RegExp(r'[*]?' + RegExp.escape(oldColumnName) + r'\s*:\s*[^\n]*(<<[^>]+>>)?'),
                          newColumnDef,
                        );
                        onUpdate(plantumlCode.replaceFirst(tableRegex, tableDef));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Column "$oldColumnName" not found in "$tableName"')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Table "$tableName" not found')),
                      );
                    }
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
}

class RelationshipManagement extends StatelessWidget {
  final String plantumlCode;
  final Function(String) onUpdate;

  RelationshipManagement({required this.plantumlCode, required this.onUpdate});

  final Map<String, String> relationshipTypes = {
    'One-to-Many': '||--o{',
    
    'One-to-One': '||--||',
    
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
              backgroundColor: WidgetStateProperty.all(Colors.red),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
            ),
            onPressed: () => _removeRelationshipDialog(context),
            child: const Text('Remove Relationship'),
          ),
        ),
      ],
    );
  }

  void _addRelationshipDialog(BuildContext context) {
    String fromTable = '';
    String toTable = '';
    String relationshipType = 'One-to-Many';
    String label = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Relationship'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        fromTable = value.trim();
                        print('From table input: $fromTable');
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'From Table',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        toTable = value.trim();
                        print('To table input: $toTable');
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'To Table',
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
                        setState(() {
                          relationshipType = value!;
                          print('Relationship type selected: $relationshipType');
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        label = value.trim();
                        print('Label input: $label');
                        setState(() {});
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
                  onPressed: () {
                    if (fromTable.isEmpty || toTable.isEmpty) {
                      print('Add Relationship button disabled: From or to table is empty');
                      return;
                    }
                    print('Adding relationship: $fromTable -> $toTable ($relationshipType)');
                    Navigator.pop(context);

                    // Check if tables exist; if not, add minimal definitions
                    String newCode = plantumlCode;
                    if (!plantumlCode.contains(RegExp(r'entity\s*"' + RegExp.escape(fromTable) + r'"'))) {
                      newCode = newCode.replaceFirst(
                        '@enduml',
                        'entity "$fromTable" {\n}\n@enduml',
                      );
                    }
                    if (!plantumlCode.contains(RegExp(r'entity\s*"' + RegExp.escape(toTable) + r'"'))) {
                      newCode = newCode.replaceFirst(
                        '@enduml',
                        'entity "$toTable" {\n}\n@enduml',
                      );
                    }

                    // Add the relationship
                    String relationshipSyntax = relationshipTypes[relationshipType]!;
                    String relationshipLine = '$fromTable $relationshipSyntax $toTable';
                    if (label.isNotEmpty) {
                      relationshipLine += ' : $label';
                    }
                    newCode = newCode.replaceFirst('@enduml', '$relationshipLine\n@enduml');

                    print('Generated PlantUML code:\n$newCode');
                    onUpdate(newCode.trim());
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

  void _removeRelationshipDialog(BuildContext context) {
    String fromTable = '';
    String toTable = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Remove Relationship'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        fromTable = value.trim();
                        print('From table to remove: $fromTable');
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'From Table',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        toTable = value.trim();
                        print('To table to remove: $toTable');
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'To Table',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (fromTable.isEmpty || toTable.isEmpty) {
                      print('Remove Relationship button disabled: From or to table is empty');
                      return;
                    }
                    print('Attempting to remove relationship: $fromTable -> $toTable');
                    Navigator.pop(context);
                    final relationshipRegex = RegExp(
                      r'^\s*' +
                          RegExp.escape(fromTable) +
                          r'\s+' +
                          r'([\|\*o]?[\|o]?--[\|o\*]?[\|o]?\{?)' +
                          r'\s+' +
                          RegExp.escape(toTable) +
                          r'(\s*:\s*[^#\n]+)?' +
                          r'\s*$',
                      multiLine: true,
                    );
                    print('Original code:\n$plantumlCode');
                    String newCode = plantumlCode.replaceAll(relationshipRegex, '');
                    print('New code after removal:\n$newCode');
                    if (newCode != plantumlCode) {
                      onUpdate(newCode.trim());
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Relationship between "$fromTable" and "$toTable" not found')),
                      );
                    }
                  },
                  child: const Text('Remove'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
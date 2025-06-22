import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TableManagement extends StatelessWidget {
  final String plantumlCode;
  final Function(String) onUpdate;

  TableManagement({required this.plantumlCode, required this.onUpdate});

  final TextEditingController tableNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromARGB(255, 0, 54, 218);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table Name Input
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: tableNameController,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Table Name',
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
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Action Buttons
        _buildGradientButton(
          context: context,
          text: 'Add Table',
          icon: Icons.add_outlined,
          onPressed: () => _addTableDialog(context),
          color: primaryColor,
        ),
        const SizedBox(height: 12),
        _buildSecondaryButton(
          context: context,
          text: 'Rename Table',
          icon: Icons.edit_outlined,
          onPressed: () => _renameTableDialog(context),
          color: primaryColor,
        ),
        const SizedBox(height: 12),
        _buildSecondaryButton(
          context: context,
          text: 'Delete Table',
          icon: Icons.delete_outline,
          onPressed: () => _deleteTableDialog(context),
          color: Colors.red,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildGradientButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
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
                  color,
                  color.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
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
    required Color color,
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: isDestructive ? Colors.red.withOpacity(0.1) : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDestructive ? Colors.red.withOpacity(0.3) : color.withOpacity(0.2),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isDestructive ? Colors.red : color,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    color: isDestructive ? Colors.red : color,
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

  void _addTableDialog(BuildContext context) {
    const primaryColor = Color.fromARGB(255, 0, 54, 218);
    String tableName = '';
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withOpacity(0.1),
                            primaryColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.table_chart_outlined,
                              color: primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Add New Table',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enter table details',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: errorMessage != null 
                                    ? Colors.red.withOpacity(0.3)
                                    : primaryColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: tableNameController,
                              style: GoogleFonts.inter(fontSize: 14),
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
                              ),
                            ),
                          ),
                          if (errorMessage != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      errorMessage!,
                                      style: GoogleFonts.inter(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Buttons
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.inter(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Material(
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: (tableName.isEmpty || errorMessage != null) ? null : () {
                                  print('Adding table: $tableName');
                                  Navigator.pop(context);
                                  String newCode = plantumlCode;
                                  if (!newCode.contains('@startuml')) {
                                    newCode = '@startuml\n$newCode';
                                  }
                                  if (!newCode.contains('@enduml')) {
                                    newCode = '$newCode\n@enduml';
                                  }
                                  newCode = newCode.replaceFirst('@enduml', 'entity "$tableName" {\n}\n@enduml');
                                  onUpdate(newCode);
                                  tableNameController.clear();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: (tableName.isEmpty || errorMessage != null) 
                                          ? [Colors.grey.shade300, Colors.grey.shade400]
                                          : [primaryColor, primaryColor.withOpacity(0.8)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: Text(
                                      'Add Table',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _renameTableDialog(BuildContext context) {
    String oldTableName = '';
    String newTableName = '';
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
                        oldTableName = value.trim();
                        print('Old table name input: $oldTableName');
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
                        newTableName = value.trim();
                        print('New table name input: $newTableName');
                        if (newTableName.isEmpty || RegExp(r'[^a-zA-Z0-9_]').hasMatch(newTableName)) {
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (oldTableName.isEmpty || newTableName.isEmpty) {
                      print('Rename Table button disabled: Old or new table name is empty');
                      return;
                    }
                    if (errorMessage != null) {
                      print('Rename Table button disabled: $errorMessage');
                      return;
                    }
                    print('Renaming table: $oldTableName -> $newTableName');
                    Navigator.pop(context);
                    final tableRegex = RegExp(
                      r'entity\s*"' + RegExp.escape(oldTableName) + r'"\s*\{[^}]*\}',
                      multiLine: true,
                    );
                    String newCode = plantumlCode.replaceAllMapped(tableRegex, (match) {
                      return match.group(0)!.replaceFirst(
                        RegExp(r'"' + RegExp.escape(oldTableName) + r'"'),
                        '"$newTableName"',
                      );
                    });
                    if (newCode != plantumlCode) {
                      onUpdate(newCode);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Table "$oldTableName" not found')),
                      );
                    }
                    tableNameController.clear();
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
                    const Text(
                      'Warning: This will permanently delete the table and all its relationships.',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        tableName = value.trim();
                        print('Table name to delete: $tableName');
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Table Name to Delete',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
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
    const primaryColor = Color.fromARGB(255, 0, 54, 218);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column Input
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: columnController,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Column (e.g., id : INT <<PK>>)',
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
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Action Buttons
        _buildGradientButton(
          context: context,
          text: 'Add Column',
          icon: Icons.add_outlined,
          onPressed: () => _addColumnDialog(context),
          color: primaryColor,
        ),
        const SizedBox(height: 12),
        _buildSecondaryButton(
          context: context,
          text: 'Edit Column',
          icon: Icons.edit_outlined,
          onPressed: () => _editColumnDialog(context),
          color: primaryColor,
        ),
      ],
    );
  }

  Widget _buildGradientButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
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
                  color,
                  color.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
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
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    color: color,
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
    const primaryColor = Color.fromARGB(255, 0, 54, 218);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGradientButton(
          context: context,
          text: 'Add Relationship',
          icon: Icons.link_outlined,
          onPressed: () => _addRelationshipDialog(context),
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildSecondaryButton(
          context: context,
          text: 'Remove Relationship',
          icon: Icons.link_off_outlined,
          onPressed: () => _removeRelationshipDialog(context),
          color: Colors.red,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildGradientButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
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
                  color,
                  color.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
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
    required Color color,
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: isDestructive ? Colors.red.withOpacity(0.1) : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDestructive ? Colors.red.withOpacity(0.3) : color.withOpacity(0.2),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isDestructive ? Colors.red : color,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    color: isDestructive ? Colors.red : color,
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
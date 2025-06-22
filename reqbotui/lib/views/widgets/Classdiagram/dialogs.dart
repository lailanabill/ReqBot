import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ClassManagement extends StatelessWidget {
  final String plantumlCode;
  final Function(String) onUpdate;

  ClassManagement({required this.plantumlCode, required this.onUpdate});

  final TextEditingController classNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromARGB(255, 0, 54, 218);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            controller: classNameController,
            style: GoogleFonts.inter(
              color: Colors.black87,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              labelText: 'Class Name',
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
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildGradientButton(
          context: context,
          text: 'Add Class',
          icon: Icons.add_circle_outline,
          onPressed: () => _addClassDialog(context),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSecondaryButton(
                context: context,
                text: 'Rename',
                icon: Icons.edit_outlined,
                onPressed: () => _renameClassDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSecondaryButton(
                context: context,
                text: 'Delete',
                icon: Icons.delete_outline,
                onPressed: () => _deleteClassDialog(context),
                isDestructive: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGradientButton({
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
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withBlue((primaryColor.blue + 40).clamp(0, 255)),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
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
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    const primaryColor = Color.fromARGB(255, 0, 54, 218);
    final color = isDestructive ? Colors.red : primaryColor;
    
    return SizedBox(
      width: double.infinity,
      child: Material(
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addClassDialog(BuildContext context) {
    String classType = 'class';
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            const primaryColor = Color.fromARGB(255, 0, 54, 218);
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.add_circle_outline,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Add Class',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Content
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
                        controller: classNameController,
                        style: GoogleFonts.inter(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value.trim().isEmpty || RegExp(r'[^a-zA-Z0-9_]').hasMatch(value.trim())) {
                              errorMessage = 'Class name must be a valid identifier (letters, numbers, underscores only)';
                            } else {
                              errorMessage = null;
                            }
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Class Name',
                          labelStyle: GoogleFonts.inter(
                            color: primaryColor,
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
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: classType,
                        style: GoogleFonts.inter(color: Colors.black87),
                        dropdownColor: Colors.white,
                        decoration: InputDecoration(
                          labelText: 'Class Type',
                          labelStyle: GoogleFonts.inter(
                            color: primaryColor,
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
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'class',
                            child: Text(
                              'Class',
                              style: GoogleFonts.inter(color: Colors.black87),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'abstract class',
                            child: Text(
                              'Abstract Class',
                              style: GoogleFonts.inter(color: Colors.black87),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'interface',
                            child: Text(
                              'Interface',
                              style: GoogleFonts.inter(color: Colors.black87),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            classType = value!;
                          });
                        },
                      ),
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
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
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Material(
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: classNameController.text.trim().isEmpty || errorMessage != null
                                  ? null
                                  : () {
                                      print('Adding class: ${classNameController.text.trim()}');
                                      Navigator.pop(context);
                                      onUpdate(plantumlCode.replaceFirst(
                                        '@enduml',
                                        '$classType ${classNameController.text.trim()} {\n}\n@enduml',
                                      ));
                                      classNameController.clear();
                                    },
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: classNameController.text.trim().isEmpty || errorMessage != null
                                      ? null
                                      : LinearGradient(
                                          colors: [
                                            primaryColor,
                                            primaryColor.withBlue((primaryColor.blue + 40).clamp(0, 255)),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                  color: classNameController.text.trim().isEmpty || errorMessage != null
                                      ? Colors.grey.shade300
                                      : null,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: classNameController.text.trim().isEmpty || errorMessage != null
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: primaryColor.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'Add',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    color: classNameController.text.trim().isEmpty || errorMessage != null
                                        ? Colors.grey.shade600
                                        : Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(
                'Rename Class',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      onChanged: (value) {
                        oldName = value.trim();
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: 'Old Class Name',
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      onChanged: (value) {
                        newName = value.trim();
                        if (newName.isEmpty || RegExp(r'[^a-zA-Z0-9_]').hasMatch(newName)) {
                          errorMessage = 'New class name must be a valid identifier';
                        } else {
                          errorMessage = null;
                        }
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: 'New Class Name',
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
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
                          print('Renaming class from $oldName to $newName');
                          Navigator.pop(context);
                          final classRegex = RegExp(
                            r'(class|abstract class|interface)\s+' + RegExp.escape(oldName) + r'\s*\{[^}]*\}',
                            multiLine: true,
                          );
                          final match = classRegex.firstMatch(plantumlCode);
                          if (match != null) {
                            final classType = match.group(1);
                            String newCode = plantumlCode.replaceFirst(
                              classRegex,
                              '$classType $newName {\n${match.group(0)!.split('{')[1]}',
                            );
                            newCode = newCode.replaceAll(
                              RegExp(r'\b' + RegExp.escape(oldName) + r'\b(?=.*-->.*)'),
                              newName,
                            );
                            onUpdate(newCode);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Class "$oldName" not found')),
                            );
                          }
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
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
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(
                'Delete Class',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        className = value.trim();
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: 'Class Name',
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
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
                          print('Deleting class: $className');
                          Navigator.pop(context);
                          final classRegex = RegExp(
                            r'(class|abstract class|interface)\s+' + RegExp.escape(className) + r'\s*\{[^}]*\}',
                            multiLine: true,
                          );
                          String newCode = plantumlCode.replaceAll(classRegex, '');
                          newCode = newCode.replaceAll(
                            RegExp(r'.*\b' + RegExp.escape(className) + r'\b.*\n(?=.*(-->|..>|--|>|<|--\|>|\*-->|o-->))'),
                            '',
                          );
                          if (newCode != plantumlCode) {
                            onUpdate(newCode);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Class "$className" not found')),
                            );
                          }
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
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
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: 'Attribute (e.g., -String name)',
            labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
              foregroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.onPrimary),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
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
              backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.secondary),
              foregroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.onSecondary),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
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
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(
                'Add Attribute',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      onChanged: (value) {
                        className = value.trim();
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: 'Class Name',
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: attributeController,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      onChanged: (value) {
                        setState(() {
                          if (value.trim().isEmpty) {
                            errorMessage = 'Attribute cannot be empty';
                          } else {
                            errorMessage = null;
                          }
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Attribute',
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: className.isEmpty || attributeController.text.trim().isEmpty || errorMessage != null
                      ? null
                      : () {
                          print('Adding attribute to $className: ${attributeController.text.trim()}');
                          Navigator.pop(context);
                          final attribute = attributeController.text.trim();
                          final classRegex = RegExp(
                            r'(class|abstract class|interface)\s+' + RegExp.escape(className) + r'\s*\{\s*([^\}]*?)\s*\}',
                            multiLine: true,
                          );
                          final match = classRegex.firstMatch(plantumlCode);
                          if (match != null) {
                            final classType = match.group(1);
                            final existingContent = match.group(2) ?? '';
                            final newContent = existingContent.isEmpty ? attribute : '$existingContent\n  $attribute';
                            onUpdate(plantumlCode.replaceFirst(
                              classRegex,
                              '$classType $className {\n  $newContent\n}',
                            ));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Class "$className" not found')),
                            );
                          }
                          attributeController.clear();
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editAttributeDialog(BuildContext context) {
    String className = '';
    String oldAttribute = '';
    String newAttribute = '';
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(
                'Edit Attribute',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      onChanged: (value) {
                        className = value.trim();
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: 'Class Name',
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      onChanged: (value) {
                        oldAttribute = value.trim();
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: 'Old Attribute',
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      onChanged: (value) {
                        newAttribute = value.trim();
                        if (newAttribute.isEmpty) {
                          errorMessage = 'New attribute cannot be empty';
                        } else {
                          errorMessage = null;
                        }
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: 'New Attribute',
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: className.isEmpty || oldAttribute.isEmpty || newAttribute.isEmpty || errorMessage != null
                      ? null
                      : () {
                          print('Editing attribute in $className: $oldAttribute -> $newAttribute');
                          Navigator.pop(context);
                          final classRegex = RegExp(
                            r'(class|abstract class|interface)\s+' + RegExp.escape(className) + r'\s*\{[^}]*\}',
                            multiLine: true,
                          );
                          final match = classRegex.firstMatch(plantumlCode);
                          if (match != null) {
                            String classDef = match.group(0)!;
                            if (classDef.contains(oldAttribute)) {
                              classDef = classDef.replaceAll(oldAttribute, newAttribute);
                              onUpdate(plantumlCode.replaceFirst(classRegex, classDef));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Attribute "$oldAttribute" not found in "$className"')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Class "$className" not found')),
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

class MethodManagement extends StatelessWidget {
  final String plantumlCode;
  final Function(String) onUpdate;

  MethodManagement({required this.plantumlCode, required this.onUpdate});

  final TextEditingController methodController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromARGB(255, 0, 54, 218);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            controller: methodController,
            style: GoogleFonts.inter(
              color: Colors.black87,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              labelText: 'Method (e.g., +getName(): String)',
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
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildGradientButton(
          context: context,
          text: 'Add Method',
          icon: Icons.add_circle_outline,
          onPressed: () => _addMethodDialog(context),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSecondaryButton(
                context: context,
                text: 'Edit',
                icon: Icons.edit_outlined,
                onPressed: () => _editMethodDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSecondaryButton(
                context: context,
                text: 'Delete',
                icon: Icons.delete_outline,
                onPressed: () => _deleteMethodDialog(context),
                isDestructive: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGradientButton({
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
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withBlue((primaryColor.blue + 40).clamp(0, 255)),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
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
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    const primaryColor = Color.fromARGB(255, 0, 54, 218);
    final color = isDestructive ? Colors.red : primaryColor;
    
    return SizedBox(
      width: double.infinity,
      child: Material(
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: GoogleFonts.inter(
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addMethodDialog(BuildContext context) {
    String className = '';
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Method'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        className = value.trim();
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Class Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: methodController,
                      onChanged: (value) {
                        setState(() {
                          if (value.trim().isEmpty) {
                            errorMessage = 'Method cannot be empty';
                          } else {
                            errorMessage = null;
                          }
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Method',
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
                  onPressed: className.isEmpty || methodController.text.trim().isEmpty || errorMessage != null
                      ? null
                      : () {
                          print('Adding method to $className: ${methodController.text.trim()}');
                          Navigator.pop(context);
                          final method = methodController.text.trim();
                          final classRegex = RegExp(
                            r'(class|abstract class|interface)\s+' + RegExp.escape(className) + r'\s*\{\s*([^\}]*?)\s*\}',
                            multiLine: true,
                          );
                          final match = classRegex.firstMatch(plantumlCode);
                          if (match != null) {
                            final classType = match.group(1);
                            final existingContent = match.group(2) ?? '';
                            final newContent = existingContent.isEmpty ? method : '$existingContent\n  $method';
                            onUpdate(plantumlCode.replaceFirst(
                              classRegex,
                              '$classType $className {\n  $newContent\n}',
                            ));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Class "$className" not found')),
                            );
                          }
                          methodController.clear();
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

  void _editMethodDialog(BuildContext context) {
    String className = '';
    String oldMethod = '';
    String newMethod = '';
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Method'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        className = value.trim();
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Class Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        oldMethod = value.trim();
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Old Method',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        newMethod = value.trim();
                        if (newMethod.isEmpty) {
                          errorMessage = 'New method cannot be empty';
                        } else {
                          errorMessage = null;
                        }
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'New Method',
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
                  onPressed: className.isEmpty || oldMethod.isEmpty || newMethod.isEmpty || errorMessage != null
                      ? null
                      : () {
                          print('Editing method in $className: $oldMethod -> $newMethod');
                          Navigator.pop(context);
                          final classRegex = RegExp(
                            r'(class|abstract class|interface)\s+' + RegExp.escape(className) + r'\s*\{[^}]*\}',
                            multiLine: true,
                          );
                          final match = classRegex.firstMatch(plantumlCode);
                          if (match != null) {
                            String classDef = match.group(0)!;
                            if (classDef.contains(oldMethod)) {
                              classDef = classDef.replaceAll(oldMethod, newMethod);
                              onUpdate(plantumlCode.replaceFirst(classRegex, classDef));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Method "$oldMethod" not found in "$className"')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Class "$className" not found')),
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

 void _deleteMethodDialog(BuildContext context) {
    String className = '';
    String methodName = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Delete Method'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        className = value.trim();
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Class Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        methodName = value.trim();
                        setState(() {});
                      },
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
                          print('Attempting to delete method "$methodName" from "$className"');
                          Navigator.pop(context);
                          final classRegex = RegExp(
                            r'(class|abstract class|interface)\s+' + RegExp.escape(className) + r'\s*\{\s*([^\}]*?)\s*\}',
                            multiLine: true,
                          );
                          final match = classRegex.firstMatch(plantumlCode);
                          if (match != null) {
                            String classDef = match.group(0)!;
                            final classType = match.group(1)!;
                            final classContent = match.group(2) ?? '';
                            // Split content into lines and filter out the method
                            final lines = classContent.split('\n').map((line) => line.trim()).toList();
                            final updatedLines = lines.where((line) => line != methodName).join('\n  ');
                            if (lines.length != updatedLines.split('\n').length) {
                              final newClassDef = updatedLines.isEmpty
                                  ? '$classType $className {}'
                                  : '$classType $className {\n  $updatedLines\n}';
                              print('New class definition: $newClassDef');
                              onUpdate(plantumlCode.replaceFirst(classRegex, newClassDef));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Method "$methodName" not found in "$className"')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Class "$className" not found')),
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

class RelationshipManagement extends StatelessWidget {
  final String plantumlCode;
  final Function(String) onUpdate;

  RelationshipManagement({required this.plantumlCode, required this.onUpdate});

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
    String relationshipType = 'Association';
    String multiplicityFrom = '';
    String multiplicityTo = '';
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
                        fromClass = value.trim();
                        setState(() {});
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
                        setState(() {});
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
                        setState(() {
                          relationshipType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        multiplicityFrom = value.trim();
                        setState(() {});
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
                        setState(() {});
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
                  onPressed: fromClass.isEmpty || toClass.isEmpty
                      ? null
                      : () {
                          print('Adding relationship: $fromClass -> $toClass ($relationshipType)');
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
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Relationship'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        fromClass = value.trim();
                        setState(() {});
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
                        setState(() {});
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
                        setState(() {
                          oldRelationshipType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        oldMultiplicityFrom = value.trim();
                        setState(() {});
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
                        setState(() {});
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
                        setState(() {});
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
                        setState(() {
                          newRelationshipType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        newMultiplicityFrom = value.trim();
                        setState(() {});
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
                        setState(() {});
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
                        setState(() {});
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
                          print('Editing relationship: $fromClass -> $toClass');
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

                          String newCode = this.plantumlCode.replaceAll(
                            '$fromClass $oldRelationshipLine $toClass',
                            '$fromClass $newRelationshipLine $toClass',
                          );
                          if (newCode != this.plantumlCode) {
                            this.onUpdate(newCode);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Relationship not found')),
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

  void _removeRelationshipDialog(BuildContext context) {
    String fromClass = '';
    String toClass = '';

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
                        fromClass = value.trim();
                        setState(() {});
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
                        setState(() {});
                      },
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
                          print('Removing relationship: $fromClass -> $toClass');
                          Navigator.pop(context);
                          String newCode = this.plantumlCode.replaceAll(
                            RegExp(
                              r'.*\b' +
                                  RegExp.escape(fromClass) +
                                  r'\b.*(-->|..>|--|>|<|--\|>|\*-->|o-->).*\b' +
                                  RegExp.escape(toClass) +
                                  r'\b.*\n',
                            ),
                            '',
                          );
                          if (newCode != this.plantumlCode) {
                            this.onUpdate(newCode);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Relationship not found')),
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
import 'package:flutter/material.dart';
import 'dialogs.dart';

class EditorTools extends StatelessWidget {
  final String plantumlCode;
  final TextEditingController plantumlController;
  final Function(String) onUpdate;
  final VoidCallback onCopy;
  final VoidCallback onRevert;

  const EditorTools({
    super.key,
    required this.plantumlCode,
    required this.plantumlController,
    required this.onUpdate,
    required this.onCopy,
    required this.onRevert,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16),
      color: Theme.of(context).colorScheme.surface,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Editor Tools',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: Text(
                'Class Management',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              iconColor: Theme.of(context).colorScheme.primary,
              collapsedIconColor: Theme.of(context).colorScheme.onSurfaceVariant,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClassManagement(
                    plantumlCode: plantumlCode,
                    onUpdate: onUpdate,
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: Text(
                'Attributes',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              iconColor: Theme.of(context).colorScheme.primary,
              collapsedIconColor: Theme.of(context).colorScheme.onSurfaceVariant,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AttributeManagement(
                    plantumlCode: plantumlCode,
                    onUpdate: onUpdate,
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: Text(
                'Methods',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              iconColor: Theme.of(context).colorScheme.primary,
              collapsedIconColor: Theme.of(context).colorScheme.onSurfaceVariant,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: MethodManagement(
                    plantumlCode: plantumlCode,
                    onUpdate: onUpdate,
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: Text(
                'Relationships',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              iconColor: Theme.of(context).colorScheme.primary,
              collapsedIconColor: Theme.of(context).colorScheme.onSurfaceVariant,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RelationshipManagement(
                    plantumlCode: plantumlCode,
                    onUpdate: onUpdate,
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: Text(
                'PlantUML Code',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              iconColor: Theme.of(context).colorScheme.primary,
              collapsedIconColor: Theme.of(context).colorScheme.onSurfaceVariant,
              initiallyExpanded: true,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: plantumlController,
                        maxLines: 10,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'monospace',
                        ),
                        decoration: InputDecoration(
                          labelText: 'PlantUML Code',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        onChanged: (value) => onUpdate(value),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => onUpdate(plantumlController.text),
                          child: const Text('Update Diagram'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: onCopy,
                          child: const Text('Copy Code'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.tertiary,
                            foregroundColor: Theme.of(context).colorScheme.onTertiary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: onRevert,
                          child: const Text('Revert to Last Version'),
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
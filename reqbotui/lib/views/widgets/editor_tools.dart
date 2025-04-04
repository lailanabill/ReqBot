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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Editor Tools',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Class Management'),
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
              title: const Text('Attributes'),
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
              title: const Text('Methods'),
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
              title: const Text('Relationships'),
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
              title: const Text('PlantUML Code'),
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
                        decoration: const InputDecoration(
                          labelText: 'PlantUML Code',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => onUpdate(value),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
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
                            backgroundColor: Colors.blue,
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
                            backgroundColor: Colors.orange,
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
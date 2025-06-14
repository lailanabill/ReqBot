import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reqbot/services/providers/userProvider.dart';
import 'package:reqbot/views/screens/context_diagram_editor_screen.dart';
import 'package:reqbot/views/screens/database_schema_editor.dart';
import 'package:reqbot/views/screens/sequence_diagram_screen.dart';
import 'class_diagram_editor.dart';
import 'UseCaseValidation.dart';
import '../widgets/dark_mode_toggle.dart';

class DiagramPage extends StatelessWidget {
  final String diagramName;
  final String dgrnam;

  const DiagramPage({Key? key, required this.diagramName, required this.dgrnam})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final int diagramIndex = context.read<UserDataProvider>().SelectedProjectId;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios,
                            color: Theme.of(context).colorScheme.onSurface, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            diagramName,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Preview & Edit Mode',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.auto_graph_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CompactDarkModeToggle(),
                    ],
                  ),
                ],
              ),
            ),

            Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),

            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Diagram type and info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Diagram Preview',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            diagramName,
                            style: GoogleFonts.inter(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Diagram Display Card
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            // "https://storage.googleapis.com/diagrams-data/images/${dgrnam}_diagram_5.png",
                            "https://storage.googleapis.com/diagrams-data/images/${dgrnam}_diagram_${diagramIndex}.png",
                            width: screenWidth * 0.9,
                            height: screenHeight * 0.6,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Image failed to load",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigate to the appropriate editor based on diagram type
                                if (diagramName == 'Class Diagram') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ClassDiagramEditor(),
                                    ),
                                  );
                                } else if (diagramName == 'Use Case Diagram') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const UseCaseValidation(),
                                    ),
                                  );
                                } else if (diagramName == 'Database Schema') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DatabaseSchemaEditor(),
                                    ),
                                  );
                                } else if (diagramName == 'Sequence Diagram') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SequenceDiagramScreen(),
                                    ),
                                  );
                                } else if (diagramName == 'Context Diagram') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ContextDiagramEditorScreen(),
                                    ),
                                  );
                                } else {
                                  // For other diagram types, show a placeholder message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Editor for $diagramName not implemented yet')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 0),
                              ),
                              child: Text(
                                "Edit Diagram",
                                style: GoogleFonts.inter(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () {
                              // Download or share diagram functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Downloading diagram...')),
                              );
                            },
                            icon: Icon(
                              Icons.download_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            tooltip: 'Download Diagram',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'diagram_page.dart';

class DiagramsMenu extends StatefulWidget {
  const DiagramsMenu({Key? key}) : super(key: key);

  @override
  State<DiagramsMenu> createState() => _DiagramsMenuState();
}

class _DiagramsMenuState extends State<DiagramsMenu> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> diagrams = [
    {
      'name': 'Use Case Diagram',
      'description': 'Visualize user interactions with the system',
      'diagramName': 'use_case',
      'icon': Icons.account_tree_outlined
    },
    {
      'name': 'Sequence Diagram',
      'description': 'Show object interactions arranged in time sequence',
      'diagramName': 'sequence',
      'icon': Icons.timeline_outlined
    },
    {
      'name': 'Database Schema',
      'description': 'Structure of database with tables and relationships',
      'diagramName': 'database',
      'icon': Icons.storage_outlined
    },
    {
      'name': 'Class Diagram',
      'description': 'Show structure of the system with classes and relationships',
      'diagramName': 'class',
      'icon': Icons.schema_outlined
    },
    {
      'name': 'Context Diagram',
      'description': 'Illustrate system boundaries and external entities',
      'diagramName': 'context',
      'icon': Icons.blur_circular_outlined
    },
  ];

  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Diagram Gallery',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Select a diagram type',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 0, 54, 218).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.auto_graph_rounded,
                        color: Color.fromARGB(255, 0, 54, 218),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            
            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Diagrams',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select a diagram type to view and edit',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Diagram List
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 600) {
                            return _buildWideLayout(context);
                          } else {
                            return _buildNarrowLayout(context);
                          }
                        },
                      ),
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

  Widget _buildWideLayout(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: diagrams.length,
      itemBuilder: (context, index) {
        return _buildAnimatedDiagramCard(context, index);
      },
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: diagrams.length,
      separatorBuilder: (context, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildAnimatedDiagramCard(context, index);
      },
    );
  }

  Widget _buildAnimatedDiagramCard(BuildContext context, int index) {
  final Animation<double> animation = CurvedAnimation(
    parent: _animationController,
    curve: Interval(
      (index / diagrams.length) * 0.75,
      0.75 + (index / diagrams.length) * 0.25,
      curve: Curves.easeOut, // Changed from easeOutBack to a safer curve
    ),
  );
  
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      // Clamp the opacity value to ensure it stays between 0.0 and 1.0
      final double safeOpacity = animation.value.clamp(0.0, 1.0);
      
      return Transform.translate(
        offset: Offset(0, 50 * (1 - animation.value)),
        child: Opacity(
          opacity: safeOpacity, // Use the clamped value
          child: child,
        ),
      );
    },
    child: _buildDiagramCard(context, index),
  );
}

  Widget _buildDiagramCard(BuildContext context, int index) {
    final Map<String, dynamic> diagram = diagrams[index];
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiagramPage(
                  diagramName: diagram['name'],
                  dgrnam: diagram['diagramName'],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: MediaQuery.of(context).size.width > 600
                ? _buildGridCardContent(diagram)
                : _buildListCardContent(diagram),
          ),
        ),
      ),
    );
  }

  Widget _buildGridCardContent(Map<String, dynamic> diagram) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 54, 218).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Icon(
              diagram['icon'],
              size: 32,
              color: const Color.fromARGB(255, 0, 54, 218),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          diagram['name'],
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Text(
            diagram['description'],
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.black54,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildListCardContent(Map<String, dynamic> diagram) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 54, 218).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              diagram['icon'],
              size: 28,
              color: const Color.fromARGB(255, 0, 54, 218),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                diagram['name'],
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                diagram['description'],
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.black54,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const Icon(
          Icons.chevron_right,
          color: Colors.black38,
          size: 20,
        ),
      ],
    );
  }
}
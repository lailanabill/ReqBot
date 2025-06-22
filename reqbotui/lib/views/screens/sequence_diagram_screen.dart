import 'package:flutter/material.dart';
import 'package:reqbot/views/widgets/Sequencediagram/sequence_diagram_editor.dart';
import 'package:google_fonts/google_fonts.dart';

class SequenceDiagramScreen extends StatefulWidget {
  const SequenceDiagramScreen({Key? key}) : super(key: key);

  @override
  _SequenceDiagramScreenState createState() => _SequenceDiagramScreenState();
}

class _SequenceDiagramScreenState extends State<SequenceDiagramScreen> {
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromARGB(255, 0, 54, 218);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Text(
          'Sequence Diagram Editor',
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
                    Icons.timeline_outlined,
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
                        'Sequence Diagram Editor',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage lifelines, messages, and sequence interactions',
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
              child: SequenceDiagramEditor(), // Delegate to the modernized editor widget
            ),
          ),
        ],
      ),
    );
  }
}

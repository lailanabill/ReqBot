import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:archive/archive.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';
import 'package:reqbot/services/providers/userProvider.dart';
import 'dart:convert';

class SRSScreen extends StatefulWidget {
  const SRSScreen({super.key});

  @override
  _SRSScreenState createState() => _SRSScreenState();
}

class _SRSScreenState extends State<SRSScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String _statusMessage = '';
  List<String> _includedImages = []; // Track included images

  // List of diagram types to include
  final List<String> _diagramTypes = [
    'class',
    'context',
    'database',
    'sequence',
    'usecase'
  ];

  Future<Map<String, dynamic>> _fetchProjectData(int projectId, int analyzerId) async {
    print('Fetching project data for projectId: $projectId, analyzerId: $analyzerId');
    final projectResponse = await _supabase
        .from('projects')
        .select('name, transcription, summary, status')
        .eq('id', projectId)
        .eq('analyzer_id', analyzerId)
        .single();

    return {
      'project': projectResponse,
    };
  }

  String _generateLatex(Map<String, dynamic> data, int projectId) {
    final project = data['project'];
    final projectName = project['name'] ?? 'Untitled Project';
    final transcription = project['transcription']?.replaceAll('\n', '\\\\') ?? 'No transcription available';
    final summary = project['summary']?.replaceAll('\n', '\\\\') ?? 'No summary available';
    final requirements = project['status']?.replaceAll('\n', '\\\\') ?? 'No requirements available';

    // Generate diagram includes for each diagram type
    String diagramSection = '';
    for (var type in _diagramTypes) {
      // Only include diagrams that were successfully added to the ZIP
      if (_includedImages.contains('${type}_diagram_$projectId.png')) {
        diagramSection += '''
\\begin{figure}[h]
    \\centering
    \\includegraphics[width=0.8\\textwidth]{${type}_diagram_${projectId}.png}
    \\caption{${type[0].toUpperCase() + type.substring(1)} Diagram}
    \\label{fig:${type}_diagram}
\\end{figure}
''';
      }
    }

    return '''
\\documentclass[12pt]{article}
\\usepackage[utf8]{inputenc}
\\usepackage{graphicx}
\\usepackage{geometry}
\\geometry{a4paper, margin=1in}
\\usepackage{parskip}
\\usepackage{enumitem}
\\setlist{noitemsep}
\\usepackage{titlesec}
\\titleformat{\\section}{\\Large\\bfseries}{\\thesection}{1em}{}
\\titleformat{\\subsection}{\\large\\bfseries}{\\thesubsection}{1em}{}

\\begin{document}

\\begin{titlepage}
    \\centering
    \\vspace*{1cm}
    \\Huge
    \\textbf{Software Requirements Specification}
    \\vspace{0.5cm}
    \\LARGE
    for
    \\vspace{0.5cm}
    \\textbf{${projectName}}
    \\vspace{1.5cm}
    \\large
    Prepared by: Your Name
    \\vspace{0.5cm}
    \\today
\\end{titlepage}

\\tableofcontents
\\newpage

\\section{Introduction}
This Software Requirements Specification (SRS) outlines the functional and non-functional requirements for the ${projectName} system, along with relevant diagrams and meeting details.

\\subsection{Purpose}
This document defines the requirements and system design for ${projectName}, ensuring all stakeholders have a clear understanding of the system's capabilities and constraints.

\\subsection{Scope}
The ${projectName} system aims to provide a comprehensive solution as described in the project requirements.

\\section{Overall Description}
\\subsection{Background}
The project was initiated based on client-manager meetings, with details captured in transcriptions and summaries.

\\subsection{Transcription}
The following is the transcription of relevant meetings:\\\\
${transcription}

\\subsection{Summary}
The meeting summary is as follows:\\\\
${summary}

\\section{Requirements}
\\subsection{Functional and Non-Functional Requirements}
The extracted requirements are listed below:\\\\
${requirements}

\\section{System Design}
\\subsection{UML Diagrams}
The following diagrams illustrate the system architecture and interactions:\\\\
${diagramSection}

\\section{Conclusion}
This SRS provides a complete specification for ${projectName}, to be used by developers, testers, and stakeholders.

\\end{document}
''';
  }

  Future<void> _generateSRSZip(int projectId, int analyzerId) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Generating SRS...';
      _includedImages = []; // Reset included images
    });
  }
}
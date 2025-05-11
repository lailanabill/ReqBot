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
  List<String> _includedImages = [];

  final List<String> _diagramTypes = [
    'class',
    'context',
    'database',
    'sequence',
    'usecase'
  ];

  Future<Map<String, dynamic>> _fetchProjectData(
      int projectId, int analyzerId) async {
    print(
        'Fetching project data for projectId: $projectId, analyzerId: $analyzerId');
    final projectResponse = await _supabase
        .from('projects')
        .select('name, transcription, summary, status')
        .eq('id', projectId)
        .eq('analyzer_id', analyzerId)
        .single();

    return {'project': projectResponse};
  }

  String _generateLatex(Map<String, dynamic> data, int projectId) {
    final project = data['project'];
    final projectName = project['name'] ?? 'Untitled Project';
    final transcription = project['transcription']?.replaceAll('\n', '\\\\') ??
        'No transcription available';
    final summary =
        project['summary']?.replaceAll('\n', '\\\\') ?? 'No summary available';
    final requirements = project['status']?.replaceAll('\n', '\\\\') ??
        'No requirements available';

    String diagramSection = '';
    for (var type in _diagramTypes) {
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
    \\vspace*{2cm}
    \\Huge
    \\textbf{Software Requirements Specification} \\\\
    \\vspace{0.5cm}
    \\LARGE
    for \\\\
    \\textbf{${projectName}} \\\\
    \\vfill
    Prepared by: Your Name \\\\
    \\today
\\end{titlepage}

\\tableofcontents
\\newpage

\\section{Introduction}
\\subsection{Purpose}
This document outlines the software requirements for the system named "${projectName}".

\\subsection{Document Conventions}
This document follows the IEEE 830-1998 SRS standard. All diagrams are included as figures.

\\subsection{Intended Audience and Reading Suggestions}
This document is intended for developers, testers, project managers, and stakeholders.

\\subsection{Project Scope}
The system aims to provide the following functionalities: \\\\
${summary}

\\subsection{References}
References to meeting notes and diagrams are embedded throughout this document.

\\section{Overall Description}
\\subsection{Product Perspective}
This project was derived from discussions and requirements gathered in client-manager meetings.

\\subsection{Product Functions}
The system performs the following high-level functions: \\\\
${summary}

\\subsection{User Characteristics}
Users are expected to have a basic understanding of system operations and interfaces.

\\subsection{Constraints}
Project constraints include development time, technological stack, and user requirements.

\\subsection{Assumptions and Dependencies}
This system depends on proper deployment infrastructure and up-to-date client requirements.

\\section{Specific Requirements}
\\subsection{Functional Requirements}
${requirements}

\\subsection{External Interface Requirements}
Interfaces will be finalized based on further stakeholder meetings and are out of scope for this draft.

\\subsection{Non-Functional Requirements}
The system must be reliable, scalable, and secure.

\\subsection{Other Requirements}
None at this time.

\\section{Supporting Information}
\\subsection{Meeting Transcriptions}
${transcription}

\\subsection{System Diagrams}
${diagramSection}

\\section*{Appendices}
Appendices include references, acronyms, or additional supporting materials.

\\end{document}
''';
  }

  Future<void> _generateSRSZip(int projectId, int analyzerId) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Generating SRS...';
      _includedImages = [];
    });

    try {
      final data = await _fetchProjectData(projectId, analyzerId);
      final project = data['project'];
      final archive = Archive();

      for (var type in _diagramTypes) {
        try {
          final assetPath = 'assets/images/${type}_diagram_153.png';
          print('Attempting to load: $assetPath');
          final imageBytes =
              await DefaultAssetBundle.of(context).load(assetPath);
          final imageData = imageBytes.buffer.asUint8List();

          final imageName = '${type}_diagram_$projectId.png';
          archive.addFile(ArchiveFile(imageName, imageData.length, imageData));
          _includedImages.add(imageName);
          print('Added $imageName to ZIP');
        } catch (e) {
          print('Error loading asset for ${type}_diagram_$projectId.png: $e');
          setState(() {
            _statusMessage +=
                '\nFailed to include ${type}_diagram_$projectId.png';
          });
        }
      }

      final latexContent = _generateLatex(data, projectId);
      final latexBytes = utf8.encode(latexContent);
      archive.addFile(ArchiveFile('srs.tex', latexBytes.length, latexBytes));
      print('Added srs.tex to ZIP');

      final zipEncoder = ZipEncoder();
      final zipBytes = zipEncoder.encode(archive);

      if (zipBytes == null) {
        throw Exception('Failed to encode ZIP file');
      }

      final blob = html.Blob([zipBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'srs_${project['name'] ?? 'project'}.zip')
        ..click();
      html.Url.revokeObjectUrl(url);

      await launchUrl(Uri.parse('https://www.overleaf.com/login'));

      setState(() {
        _statusMessage =
            'SRS generated and downloaded! Upload the ZIP to Overleaf.\nIncluded images: ${_includedImages.join(", ")}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error generating SRS: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDataProvider = context.read<UserDataProvider>();
    final projectId = userDataProvider.SelectedProjectId;
    final analyzerId = userDataProvider.AnalyzerID;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Draft SRS',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generate SRS Document',
                style: GoogleFonts.inter(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a Software Requirements Specification based on project data.',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Center(
                child: _isLoading
                    ? CircularProgressIndicator(
                        color: Color.fromARGB(255, 0, 54, 218))
                    : ElevatedButton(
                        onPressed: () => _generateSRSZip(projectId, analyzerId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 0, 54, 218),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                        ),
                        child: Text(
                          'Generate SRS',
                          style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              if (_statusMessage.isNotEmpty)
                Text(
                  _statusMessage,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _statusMessage.contains('Error') ||
                            _statusMessage.contains('Failed')
                        ? Colors.red
                        : Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:archive/archive.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';
import 'package:reqbot/services/providers/userProvider.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:lottie/lottie.dart';
import '../widgets/dark_mode_toggle.dart';
import 'package:http/http.dart' as http;

class SRSScreen extends StatefulWidget {
  const SRSScreen({super.key});

  @override
  _SRSScreenState createState() => _SRSScreenState();
}

class _SRSScreenState extends State<SRSScreen> with TickerProviderStateMixin {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = false;
  bool _isSuccess = false;
  String _statusMessage = '';
  List<String> _includedImages = [];

  // Animation controllers
  late AnimationController _mainAnimationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;

  // Button animation
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  final List<String> _diagramTypes = [
    'class',
    'context',
    'database',
    'sequence',
    'use_case'
  ];

  @override
  void initState() {
    super.initState();

    // Main animations for content
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Button animation
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _mainAnimationController.forward();
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

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

  Future<Map<String, String>> _generateSRSSectionsWithLlama({
    required String transcription,
    required String summary,
    required String requirements,
  }) async {
    final url =
        Uri.parse('https://srserver-761462343691.europe-west1.run.app/srs/');
    final body = {
      'transcript': transcription,
      'summary': summary,
      'requirements': requirements,
    };
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Llama should return all SRS static sections
        return {
          'purpose': data['purpose'] ?? '',
          'scope': data['scope'] ?? '',
          'background': data['background'] ?? '',
          'conclusion': data['conclusion'] ?? '',
        };
      } else {
        throw Exception('Llama API error: \\${response.statusCode}');
      }
    } catch (e) {
      print('Llama API call failed: $e');
      // If Llama fails, do not use static text. Instead, throw error to be handled by caller.
      throw Exception('Failed to generate SRS sections with Llama: $e');
    }
  }

  String _generateLatex(
    Map<String, dynamic> data,
    int projectId, {
    required String purpose,
    required String scope,
    required String background,
    required String conclusion,
  }) {
    final project = data['project'];
    final projectName = project['name'] ?? 'Appointment Booking System';
    final transcription = project['transcription']?.replaceAll('\n', '\\\\') ??
        'Meeting transcription not available.';
    final summary = project['summary']?.replaceAll('\n', '\\\\') ??
        'Meeting summary not available.';
    final requirements = project['status']?.replaceAll('\n', '\\\\') ??
        'No requirements provided.';

    // Generate diagram includes
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
    \\vspace*{1cm}
    \\Huge
    \\textbf{Appointment Booking System}
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
${background}

\\subsection{Purpose}
${purpose}

\\subsection{Scope}
${scope}

\\section{Overall Description}
\\subsection{Background}
${background}

\\subsection{Transcription}
${transcription}

\\subsection{Summary}
${summary}

\\section{Requirements}
\\subsection{Functional and Non-Functional Requirements}
${requirements}

\\section{System Design}
\\subsection{UML Diagrams}
${diagramSection}

\\section{Conclusion}
${conclusion}

\\end{document}
''';
  }

  Future<void> _generateSRSZip(int projectId, int analyzerId) async {
    setState(() {
      _isLoading = true;
      _isSuccess = false;
      _statusMessage = 'Generating SRS document...';
      _includedImages = [];
    });

    try {
      HapticFeedback.mediumImpact();
      final data = await _fetchProjectData(projectId, analyzerId);
      final project = data['project'];
      final archive = Archive();

      for (var type in _diagramTypes) {
        try {
          final assetPath = 'assets/images/${type}_diagram_194.png';
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

      // Call Llama API to generate SRS sections
      Map<String, String> llamaSections;
      try {
        llamaSections = await _generateSRSSectionsWithLlama(
          transcription: project['transcription'] ?? '',
          summary: project['summary'] ?? '',
          requirements: project['status'] ?? '',
        );
      } catch (e) {
        setState(() {
          _isSuccess = false;
          _statusMessage =
              'Error: Could not generate SRS sections with Llama. $e';
        });
        return;
      }

      final latexContent = _generateLatex(
        data,
        projectId,
        purpose: llamaSections['purpose'] ?? '',
        scope: llamaSections['scope'] ?? '',
        background: llamaSections['background'] ?? '',
        conclusion: llamaSections['conclusion'] ?? '',
      );
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
        _isSuccess = true;
        _statusMessage = 'SRS generated successfully!';
      });
    } catch (e) {
      setState(() {
        _isSuccess = false;
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
    // Always use the latest selected project and analyzer from the provider.
    // This ensures SRS is generated for the currently selected project.
    final userDataProvider = context.watch<UserDataProvider>();
    final projectId = userDataProvider.SelectedProjectId;
    final analyzerId = userDataProvider.AnalyzerID;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(projectId, analyzerId),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.primary,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios,
            size: 20, color: Theme.of(context).colorScheme.onPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: Text(
        'Software Requirements Spec',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: CompactDarkModeToggle(),
        ),
      ],
    );
  }

  Widget _buildBody(int projectId, int analyzerId) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: AnimatedBuilder(
        animation: _mainAnimationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeInAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: child,
            ),
          );
        },
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildInfoCard(),
                  const SizedBox(height: 40),
                  _isLoading
                      ? _buildLoadingState()
                      : _buildGenerateButton(projectId, analyzerId),
                  const SizedBox(height: 30),
                  if (_statusMessage.isNotEmpty && !_isLoading)
                    _buildStatusMessage(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.description_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generate SRS Document',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Create a professional Software Requirements Specification',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
                SizedBox(width: 10),
                Text(
                  'SRS Document',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          // Card content
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoItem(
                  icon: Icons.article_outlined,
                  title: 'IEEE 830-1998 Format',
                  description:
                      'Professional document following industry standards',
                ),
                SizedBox(height: 16),
                _buildInfoItem(
                  icon: Icons.auto_awesome_motion,
                  title: 'Complete Package',
                  description:
                      'Includes requirements, diagrams, and project details',
                ),
                SizedBox(height: 16),
                _buildInfoItem(
                  icon: Icons.open_in_new_rounded,
                  title: 'Editable in Overleaf',
                  description:
                      'The ZIP file can be uploaded directly to Overleaf for editing',
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'After generating, the ZIP file will download automatically. You will then be redirected to Overleaf where you can upload and edit it.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            height: 1.5,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      {required IconData icon,
      required String title,
      required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 100,
            width: 100,
            child: Lottie.network(
              'https://assets5.lottiefiles.com/packages/lf20_usmfx6bp.json',
              repeat: true,
            ),
          ),
          SizedBox(height: 24),
          Text(
            _statusMessage,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'This may take a moment...',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(int projectId, int analyzerId) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTapDown: (_) => _buttonAnimationController.forward(),
            onTapUp: (_) {
              _buttonAnimationController.reverse();
              _generateSRSZip(projectId, analyzerId);
            },
            onTapCancel: () => _buttonAnimationController.reverse(),
            child: AnimatedBuilder(
              animation: _buttonScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _buttonScaleAnimation.value,
                  child: Container(
                    height: 56,
                    width: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.8),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.4),
                          offset: Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: () => _generateSRSZip(projectId, analyzerId),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.download_rounded,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 22,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Generate SRS Document',
                                style: GoogleFonts.inter(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Generate a complete SRS document with diagrams',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage() {
    return AnimatedOpacity(
      opacity: _statusMessage.isNotEmpty ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isSuccess
              ? Colors.green.withOpacity(0.1)
              : Theme.of(context).colorScheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isSuccess
                ? Colors.green.withOpacity(0.3)
                : Theme.of(context).colorScheme.error.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: _isSuccess
                  ? Colors.green
                  : Theme.of(context).colorScheme.error,
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isSuccess ? 'Success!' : 'Error',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _isSuccess
                          ? Colors.green
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _statusMessage,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (_isSuccess) ...[
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You will be redirected to Overleaf where you can upload the generated ZIP file.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    if (_includedImages.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Included diagrams:',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _includedImages.map((image) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    image.split('_')[0],
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

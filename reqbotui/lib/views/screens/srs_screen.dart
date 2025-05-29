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

  // Using the exact color specified
  final Color primaryColor = const Color.fromARGB(255, 0, 54, 218);
  final Color backgroundColor = Colors.white;
  final Color textPrimaryColor = Color(0xFF333333);
  final Color textSecondaryColor = Color(0xFF737373);
  final Color cardColor = Color(0xFFF5F9FF);

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

  String _generateLatex(Map<String, dynamic> data, int projectId) {
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
${projectName} is an online platform that facilitates scheduling and managing appointments between users and service providers. The system supports user account creation, appointment browsing, booking, and notifications, ensuring a streamlined and user-friendly experience.

\\subsection{Purpose}
The system provides a centralized interface for appointment-related operations. It is intended to serve users who need to book or manage time slots and administrators who handle service availability. Notification mechanisms ensure that users remain informed of confirmations and reminders.

\\subsection{Scope}
The platform supports the following features:
\\begin{itemize}
  \\item User registration and account management
  \\item Browsing of available time slots
  \\item Booking, rescheduling, and cancellation of appointments
  \\item Delivery of appointment confirmations and reminders via email or SMS
\\end{itemize}
It operates as a responsive web application and is designed for reliability, performance, and secure data handling.

\\section{Overall Description}
\\subsection{Background}
Development of the system began after a series of planning sessions between stakeholders. The goal was to replace manual booking processes with a digital alternative that is more efficient, transparent, and scalable.

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
The platform described in this specification provides a robust solution for appointment scheduling and management. Its functionality addresses both user-facing needs and backend operational efficiency. The requirements and design components outlined here form the basis for implementation and future enhancements.

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
    final userDataProvider = context.read<UserDataProvider>();
    final projectId = userDataProvider.SelectedProjectId;
    final analyzerId = userDataProvider.AnalyzerID;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(projectId, analyzerId),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: primaryColor,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: Text(
        'Software Requirements Spec',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBody(int projectId, int analyzerId) {
    return Container(
      color: backgroundColor,
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
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.description_outlined,
              color: primaryColor,
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
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Create a professional Software Requirements Specification',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.5,
                    color: textSecondaryColor,
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
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: primaryColor,
                  size: 22,
                ),
                SizedBox(width: 10),
                Text(
                  'SRS Document',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimaryColor,
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
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: primaryColor,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'After generating, the ZIP file will download automatically. You will then be redirected to Overleaf where you can upload and edit it.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            height: 1.5,
                            color: textSecondaryColor,
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
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: primaryColor,
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
                  color: textPrimaryColor,
                ),
              ),
              SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: textSecondaryColor,
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
              color: primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'This may take a moment...',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: textSecondaryColor,
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
                          primaryColor,
                          Color.fromARGB(255, 39, 90, 240),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.4),
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
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Generate SRS Document',
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
              color: textSecondaryColor,
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
              : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isSuccess
                ? Colors.green.withOpacity(0.3)
                : Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: _isSuccess ? Colors.green : Colors.red,
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
                      color: _isSuccess ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _statusMessage,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: textPrimaryColor,
                    ),
                  ),
                  if (_isSuccess) ...[
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: primaryColor,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You will be redirected to Overleaf where you can upload the generated ZIP file.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: textSecondaryColor,
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
                          color: Colors.white,
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
                                color: textPrimaryColor,
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
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    image.split('_')[0],
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: primaryColor,
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

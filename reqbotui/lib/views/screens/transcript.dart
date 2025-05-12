import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:reqbot/services/providers/data_providers.dart';
import 'package:reqbot/services/providers/userProvider.dart';
import 'package:reqbot/views/screens/RequirementsMenuScreen.Dart';
import 'package:reqbot/views/screens/functional_requirements_screen.dart';
import 'package:reqbot/views/screens/summary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/requirement_item.dart';
import '../widgets/custom_dialog.dart';

class TranscriptScreen extends StatefulWidget {
  const TranscriptScreen({super.key});

  @override
  _TranscriptScreenState createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends State<TranscriptScreen>
    with TickerProviderStateMixin {
  String transcription = "";
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = "";

  // Animation controllers
  late AnimationController _mainAnimationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;

  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  final TextEditingController _editingController = TextEditingController();
  final Color primaryColor = const Color.fromARGB(255, 0, 54, 218); // Updated to match ProjectToDB

  void getTranscript() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await Supabase.instance.client
          .from('projects')
          .select('transcription')
          .eq('analyzer_id', context.read<UserDataProvider>().AnalyzerID)
          .eq('id', context.read<UserDataProvider>().SelectedProjectId);

      setState(() {
        transcription = response.isNotEmpty && response[0]['transcription'] != null 
            ? response[0]['transcription'] 
            : "";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = "Failed to load transcription. Please try again.";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getTranscript();
    
    // Set up main animations
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Set up pulse animation for FAB
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.elasticInOut,
      ),
    );

    _pulseAnimationController.repeat(reverse: true);
    _mainAnimationController.forward();
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _pulseAnimationController.dispose();
    _editingController.dispose();
    super.dispose();
  }

  void _refreshTranscript() {
    HapticFeedback.mediumImpact();
    getTranscript();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: FadeTransition(
        opacity: _fadeInAnimation,
        child: Text(
          'Transcription',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _refreshTranscript,
          tooltip: 'Refresh Transcription',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor.withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Expanded(child: _buildTranscriptContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.text_snippet_rounded,
              color: primaryColor,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              'Meeting Transcript',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Your conversation has been transcribed and is ready for review.',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTranscriptContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: Lottie.network(
                'https://assets7.lottiefiles.com/packages/lf20_vniburp3.json',
                repeat: true,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading Transcription...',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              _errorMessage,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshTranscript,
              icon: const Icon(Icons.refresh),
              label: Text(
                'Try Again',
                style: GoogleFonts.inter(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (transcription.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic_off_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No transcription available yet',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Record your conversation first to see the transcription here.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.03,
                child: Image.network(
                  'https://www.transparenttextures.com/patterns/notebook-dark.png',
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.format_quote_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Transcript Content',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    MarkdownBody(
                      data: transcription,
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.inter(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                        h1: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        h2: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        h3: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        listBullet: GoogleFonts.inter(
                          fontSize: 15,
                          color: primaryColor,
                        ),
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

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SummaryScreen(),
            ),
          );
        },
        icon: const Icon(Icons.list_alt_rounded),
        label: Text(
          'View Summary',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
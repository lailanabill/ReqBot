import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:reqbot/services/providers/data_providers.dart';
import 'package:reqbot/services/providers/userProvider.dart';
import 'package:reqbot/views/screens/RequirementsMenuScreen.Dart';
import 'package:reqbot/views/screens/transcript.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../widgets/requirement_item.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/dark_mode_toggle.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen>
    with TickerProviderStateMixin {
  String summary = "";
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = "";

  // Animation controllers
  late AnimationController _mainAnimationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  late AnimationController _refreshIconController;

  final TextEditingController _editingController = TextEditingController();

  // Using the exact color specified
  final Color primaryColor = const Color.fromARGB(255, 0, 54, 218);
  final Color backgroundColor = Colors.white;
  final Color cardColor = Color(0xFFF5F9FF);
  final Color textPrimaryColor = Color(0xFF333333);
  final Color textSecondaryColor = Color(0xFF737373);

  Future<void> _getSummary() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await Supabase.instance.client
          .from('projects')
          .select('summary')
          .eq('analyzer_id', context.read<UserDataProvider>().AnalyzerID)
          .eq('id', context.read<UserDataProvider>().SelectedProjectId);

      setState(() {
        summary = response.isNotEmpty && response[0]['summary'] != null
            ? response[0]['summary']
            : "";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = "Failed to load summary. Please try again later.";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getSummary();

    // Main animations for content
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Floating action button animation
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    );

    // Refresh icon animation
    _refreshIconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Start animations
    _mainAnimationController.forward();
    Future.delayed(Duration(milliseconds: 400), () {
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _fabAnimationController.dispose();
    _refreshIconController.dispose();
    _editingController.dispose();
    super.dispose();
  }

  void _refreshSummary() {
    HapticFeedback.mediumImpact();
    _refreshIconController.reset();
    _refreshIconController.forward();
    _getSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.primary,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, size: 20, color: Theme.of(context).colorScheme.onPrimary),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 500),
              pageBuilder: (_, __, ___) => RequirementsMenuScreen(
                projectID: context.read<UserDataProvider>().SelectedProjectId,
              ),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          );
        },
      ),
      centerTitle: true,
      title: FadeTransition(
        opacity: _fadeInAnimation,
        child: Text(
          'Project Summary',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
      actions: [
        RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(_refreshIconController),
          child: IconButton(
            icon: Icon(Icons.refresh_rounded, color: Theme.of(context).colorScheme.onPrimary),
            onPressed: _refreshSummary,
            tooltip: 'Refresh Summary',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: CompactDarkModeToggle(),
        ),
      ],
    );
  }

  Widget _buildBody() {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                Expanded(child: _buildSummaryContent()),
              ],
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
              Icons.summarize_rounded,
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
                  'Project Summary',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'AI generated overview of your project requirements',
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

  Widget _buildSummaryContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading Summary...',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Preparing your project overview',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _refreshSummary,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'Try Again',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (summary.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.document_scanner_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 32),
            Text(
              'No summary available yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Your project summary will appear here once it\'s been generated.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: _refreshSummary,
              icon: Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Check Again',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Top decoration
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 6,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      Theme.of(context).colorScheme.primary,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Column(
                children: [
                  // Summary header
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
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
                          'AI Summary',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.copy_rounded,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                            size: 20,
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: summary));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Summary copied to clipboard',
                                  style: GoogleFonts.inter(),
                                ),
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          tooltip: 'Copy to clipboard',
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  // Summary content
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.surface,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 24),
                        child: MarkdownBody(
                          data: summary,
                          styleSheet: MarkdownStyleSheet(
                            p: GoogleFonts.inter(
                              fontSize: 15,
                              height: 1.7,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            h1: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.3,
                            ),
                            h2: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.3,
                            ),
                            h3: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.3,
                            ),
                            blockquote: GoogleFonts.inter(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              height: 1.7,
                            ),
                            blockquoteDecoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                  width: 4,
                                ),
                              ),
                            ),
                            blockquotePadding:
                                EdgeInsets.only(left: 16, top: 8, bottom: 8),
                            listBullet: GoogleFonts.inter(
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.primary,
                              height: 1.7,
                            ),
                            listBulletPadding: EdgeInsets.only(right: 8),
                            strong: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            em: GoogleFonts.inter(
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            code: GoogleFonts.sourceCodePro(
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 14,
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            codeblockPadding: EdgeInsets.all(16),
                            horizontalRuleDecoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  width: 1,
                                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                ),
                              ),
                            ),
                            tableHead: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            tableBody: GoogleFonts.inter(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            tableBorder: TableBorder.all(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              width: 1,
                            ),
                            tableCellsPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
              offset: Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Material(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 500),
                  pageBuilder: (_, __, ___) => const TranscriptScreen(),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.3),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.record_voice_over_rounded,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'View Transcript',
                    style: GoogleFonts.inter(
                      color: Theme.of(context).colorScheme.onPrimary,
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
  }
}

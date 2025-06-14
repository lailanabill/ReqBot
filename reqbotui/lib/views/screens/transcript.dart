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
import '../widgets/dark_mode_toggle.dart';

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

  Future<void> getTranscript() async {
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

  void _refreshTranscript() {
    HapticFeedback.mediumImpact();
    _refreshIconController.reset();
    _refreshIconController.forward();
    getTranscript();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
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
          'Meeting Transcript',
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
            onPressed: _refreshTranscript,
            tooltip: 'Refresh Transcription',
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
              Icons.chat_bubble_outline_rounded,
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
                  'Meeting Conversation',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'The meeting transcript is displayed in a chat-style interface',
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

  Widget _buildTranscriptContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: Lottie.network(
                'https://assets1.lottiefiles.com/packages/lf20_s4tubmwf.json', // Document scanning animation
                repeat: true,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading Transcript...',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Preparing your meeting notes',
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
              onPressed: _refreshTranscript,
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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

    if (transcription.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 32),
            Text(
              'No transcript available yet',
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
                'Your conversation transcript will appear here once it\'s been processed.',
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
              onPressed: _refreshTranscript,
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Parse the transcript into individual messages
    List<TranscriptMessage> messages = _parseTranscriptMessages(transcription);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
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
            Column(
              children: [
                // Transcript header
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
                        Icons.chat_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Meeting Conversation',
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
                          Clipboard.setData(ClipboardData(text: transcription));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Transcript copied to clipboard',
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
                // Chat messages
                Expanded(
                  child: Container(
                    width: double.infinity,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return _buildMessageBubble(message);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(TranscriptMessage message) {
    // Determine if message is from system or a specific speaker
    final bool isSystem = message.speaker.toUpperCase() == "SYSTEM";
    
    // Extract speaker number to determine bubble color
    String speakerNumber = "0";
    if (message.speaker.toUpperCase().startsWith("SPEAKER_")) {
      final parts = message.speaker.split("_");
      if (parts.length > 1) {
        speakerNumber = parts[1].replaceAll(RegExp(r'^0+'), '');
        if (speakerNumber.isEmpty) speakerNumber = "0";
      }
    }
    
    // Choose color based on speaker with theme awareness
    Color avatarColor;
    Color bubbleColor;
    Color textColor;
    
    if (isSystem) {
      avatarColor = Theme.of(context).colorScheme.outline;
      bubbleColor = Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5);
      textColor = Theme.of(context).colorScheme.onSurfaceVariant;
    } else {
      // Create different colors for different speakers
      switch (int.parse(speakerNumber) % 5) {
        case 0:
          avatarColor = Theme.of(context).colorScheme.primary;
          bubbleColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
          textColor = Theme.of(context).colorScheme.onSurface;
          break;
        case 1:
          avatarColor = Colors.green.shade600;
          bubbleColor = Colors.green.withOpacity(0.1);
          textColor = Theme.of(context).colorScheme.onSurface;
          break;
        case 2:
          avatarColor = Colors.orange.shade700;
          bubbleColor = Colors.orange.withOpacity(0.1);
          textColor = Theme.of(context).colorScheme.onSurface;
          break;
        case 3:
          avatarColor = Colors.purple.shade600;
          bubbleColor = Colors.purple.withOpacity(0.1);
          textColor = Theme.of(context).colorScheme.onSurface;
          break;
        case 4:
          avatarColor = Colors.teal.shade600;
          bubbleColor = Colors.teal.withOpacity(0.1);
          textColor = Theme.of(context).colorScheme.onSurface;
          break;
        default:
          avatarColor = Theme.of(context).colorScheme.primary;
          bubbleColor = Theme.of(context).colorScheme.surface;
          textColor = Theme.of(context).colorScheme.onSurface;
      }
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar/Icon for the speaker
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: avatarColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                isSystem ? Icons.settings : Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          SizedBox(width: 12),
          // Message content
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Speaker name
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
                  child: Text(
                    message.displayName,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: avatarColor,
                    ),
                  ),
                ),
                // Message bubble
                Container(
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 3,
                        spreadRadius: 0,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Text(
                      message.text,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.5,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to parse the transcript text into a list of message objects
  List<TranscriptMessage> _parseTranscriptMessages(String transcript) {
    List<TranscriptMessage> messages = [];
    
    // Split the transcript by newlines
    List<String> lines = transcript.split('\n');
    
    // Process each line
    for (String line in lines) {
      // Skip empty lines
      if (line.trim().isEmpty) continue;
      
      // Check for speaker pattern like "SPEAKER_00:"
      RegExp speakerRegex = RegExp(r'(SPEAKER_\d+):\s*(.+)');
      var match = speakerRegex.firstMatch(line);
      
      if (match != null && match.groupCount >= 2) {
        String speaker = match.group(1)!;
        String text = match.group(2)!.trim();
        
        // Only add if there's actual text content
        if (text.isNotEmpty) {
          messages.add(TranscriptMessage(speaker: speaker, text: text));
        }
      } else {
        // Try finding any colon that might separate speaker and text
        int colonIndex = line.indexOf(':');
        
        if (colonIndex > 0) {
          String speaker = line.substring(0, colonIndex).trim();
          String text = line.substring(colonIndex + 1).trim();
          
          // Only add if there's actual text content
          if (text.isNotEmpty) {
            messages.add(TranscriptMessage(speaker: speaker, text: text));
          }
        } else {
          // If line doesn't follow speaker:message format, add as system message
          messages.add(TranscriptMessage(speaker: "SYSTEM", text: line.trim()));
        }
      }
    }
    
    return messages;
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
                  pageBuilder: (_, __, ___) => const SummaryScreen(),
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
                    Icons.summarize_rounded,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'View Summary',
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

class TranscriptMessage {
  final String speaker;
  final String text;
  
  TranscriptMessage({required this.speaker, required this.text});
  
  // Format speaker name for display (e.g., "SPEAKER_00" -> "Speaker 0")
  String get displayName {
    if (speaker.toUpperCase().startsWith("SPEAKER_")) {
      final parts = speaker.split("_");
      if (parts.length > 1) {
        String speakerNumber = parts[1];
        
        // Remove leading zeros
        if (speakerNumber.startsWith('0') && speakerNumber.length > 1) {
          speakerNumber = speakerNumber.replaceFirst(RegExp(r'^0+'), '');
        }
        
        return "Speaker $speakerNumber";
      }
    }
    
    // If it's a system message
    if (speaker.toUpperCase() == "SYSTEM") {
      return "System";
    }
    
    // Otherwise use the original speaker name
    return speaker;
  }
}
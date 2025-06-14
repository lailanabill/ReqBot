import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reqbot/services/providers/userProvider.dart';
import 'package:reqbot/views/screens/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import 'package:reqbot/views/screens/choose_action_screen.dart';
import '../widgets/dark_mode_toggle.dart';

class ProjectToDB extends StatefulWidget {
  const ProjectToDB({Key? key}) : super(key: key);

  @override
  _ProjectToDBState createState() => _ProjectToDBState();
}

class _ProjectToDBState extends State<ProjectToDB>
    with SingleTickerProviderStateMixin {
  bool _accepted = false;
  final projNameController = TextEditingController();
  bool _isLoading = false;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkboxAnimation;

  @override
  void initState() {
    super.initState();

    // Set up animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _checkboxAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
      ),
    );

    // Start the animations
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    projNameController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (!_accepted || projNameController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      HapticFeedback.mediumImpact();

      // Show loading dialog
      _showLoadingDialog();

      // Insert project into Supabase
      final response = await Supabase.instance.client.from('projects').insert({
        "analyzer_id": context.read<UserDataProvider>().AnalyzerID,
        "name": projNameController.text
      }).select();

      // Set project ID in provider
      context.read<UserDataProvider>().setProjectId(response[0]['id']);

      // Close loading dialog
      Navigator.pop(context);

      // Show success animation
      _showSuccessDialog();
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating project: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Lottie.network(
                    'https://assets7.lottiefiles.com/packages/lf20_vniburp3.json',
                    repeat: true,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Creating Your Project...',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This will just take a moment',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: Lottie.network(
                  'https://assets1.lottiefiles.com/packages/lf20_ydo1amjm.json',
                  repeat: false,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Project Created!',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ready to start working on your project',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    // Navigate to Choose Action screen instead of Record
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChooseActionScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Continue",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom App Bar
            _buildCustomAppBar(),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with title and description
                      _buildAnimatedHeader(),

                      const SizedBox(height: 40),

                      // Project Name Input
                      _buildAnimatedProjectNameInput(),

                      const SizedBox(height: 40),

                      // Terms & Conditions
                      _buildAnimatedTermsAndConditions(),

                      const SizedBox(height: 40),

                      // Information Card
                      _buildAnimatedInfoCard(),
                    ],
                  ),
                ),
              ),
            ),

            // Continue Button at bottom
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios, 
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Project',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Step 1 of 3',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const CompactDarkModeToggle(),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.rocket_launch_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedHeader() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Let\'s Name Your Project',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Give your project a meaningful name. This will help you and your team identify it easily.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedProjectNameInput() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value * 1.2),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Project Name',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: projNameController,
              autofocus: true,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'e.g., Project Alpha',
                hintStyle: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                prefixIcon: Icon(
                  Icons.folder_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                suffixIcon: projNameController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          projNameController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                filled: true,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTermsAndConditions() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value * 1.5),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            _accepted = !_accepted;
          });
          HapticFeedback.selectionClick();
        },
        child: Container(
          decoration: BoxDecoration(
            color: _accepted 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.05) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _accepted
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _checkboxAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _accepted ? _checkboxAnimation.value : 1.0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _accepted 
                            ? Theme.of(context).colorScheme.primary 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _accepted
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: _accepted
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                            )
                          : null,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "I accept the Terms and Conditions",
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: _accepted 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: _accepted ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedInfoCard() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value * 1.8),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.amber.withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.amber.shade800,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What\'s Next?',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'After creating your project, you\'ll be able to record requirements through audio transcription.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.mic,
                        color: Colors.amber.shade800,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Record your voice to capture requirements',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.text_format,
                        color: Colors.amber.shade800,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Transcription will be automatically generated',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final bool isValid = _accepted && projNameController.text.isNotEmpty;

    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _fadeInAnimation.value)),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: isValid && !_isLoading ? _handleContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              disabledBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.onPrimary,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Creating Project...",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Continue",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

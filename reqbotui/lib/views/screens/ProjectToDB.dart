import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reqbot/services/providers/userProvider.dart';
import 'package:reqbot/views/screens/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

class ProjectToDB extends StatefulWidget {
  const ProjectToDB({Key? key}) : super(key: key);

  @override
  _ProjectToDBState createState() => _ProjectToDBState();
}

class _ProjectToDBState extends State<ProjectToDB> with SingleTickerProviderStateMixin {
  bool _accepted = false;
  final projNameController = TextEditingController();
  final Color primaryColor = const Color.fromARGB(255, 0, 54, 218);
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
      final response = await Supabase.instance.client
        .from('projects')
        .insert({
          "analyzer_id": context.read<UserDataProvider>().AnalyzerID,
          "name": projNameController.text
        })
        .select();
      
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
          backgroundColor: Colors.red,
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
          backgroundColor: Colors.white,
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
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This will just take a moment',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.black54,
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
        backgroundColor: Colors.white,
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
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ready to start recording requirements',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    // Navigate to Record screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Record(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Continue to Recording",
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
      backgroundColor: Colors.white,
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
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
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
                      ),
                    ),
                    Text(
                      'Step 1 of 2',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.rocket_launch_rounded,
                      color: primaryColor,
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
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Give your project a meaningful name. This will help you and your team identify it easily.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.black54,
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
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Project Name',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.08),
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
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'e.g., Project Alpha',
                hintStyle: GoogleFonts.inter(
                  color: Colors.black38,
                ),
                prefixIcon: Icon(
                  Icons.folder_outlined,
                  color: primaryColor,
                ),
                suffixIcon: projNameController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
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
                fillColor: Colors.grey.shade50,
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
            color: _accepted ? primaryColor.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _accepted ? primaryColor.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
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
                        color: _accepted ? primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _accepted ? primaryColor : Colors.grey.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: _accepted
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
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
                    color: _accepted ? primaryColor : Colors.black87,
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
                      color: Colors.black54,
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
                            color: Colors.black54,
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
                            color: Colors.black54,
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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
              backgroundColor: primaryColor,
              disabledBackgroundColor: primaryColor.withOpacity(0.3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                const SizedBox(width: 12),
                Text(
                  _isLoading ? "Processing..." : "Continue",
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
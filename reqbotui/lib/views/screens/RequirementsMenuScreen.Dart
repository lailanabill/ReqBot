import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reqbot/services/providers/userProvider.dart';
import 'package:reqbot/views/screens/diagramsmenu.dart';
import 'package:reqbot/views/screens/functional_requirements_screen.dart';
import 'package:reqbot/views/screens/non_functional_requirements_screen.dart';
import 'package:reqbot/views/screens/summary.dart';
import 'package:reqbot/views/screens/reqsMark.dart';
import 'package:reqbot/views/screens/transcript.dart';
import 'package:reqbot/views/screens/srs_screen.dart'; // Add import

class RequirementsMenuScreen extends StatefulWidget {
  final int projectID;
  const RequirementsMenuScreen({Key? key, required this.projectID})
      : super(key: key);

  @override
  State<RequirementsMenuScreen> createState() => _RequirementsMenuScreenState();
}

class _RequirementsMenuScreenState extends State<RequirementsMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late int projectID;

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Functional Requirements',
      'subtitle': 'System capabilities and features',
      'icon': Icons.check_circle_outlined,
      'route': const FunctionalRequirementsScreen(),
    },
    {
      'title': 'Non-Functional Requirements',
      'subtitle': 'System qualities and constraints',
      'icon': Icons.speed_outlined,
      'route': const NonFunctionalRequirementsScreen(),
    },
    {
      'title': 'Requirements',
      'subtitle': 'Requirements',
      'icon': Icons.mark_as_unread_outlined,
      'route': const ReqsMarkScreen(),
    },
    {
      'title': 'Summary',
      'subtitle': 'Overview of all requirements',
      'icon': Icons.summarize_outlined,
      'route': const SummaryScreen(),
    },
    {
      'title': 'Transcription',
      'subtitle': 'Interview and meeting notes',
      'icon': Icons.record_voice_over_outlined,
      'route': const TranscriptScreen(),
    },
    {
      'title': 'Diagrams',
      'subtitle': 'Visual system representations',
      'icon': Icons.schema_outlined,
      'route': DiagramsMenu(),
    },
    {
      'title': 'Draft SRS',
      'subtitle': 'Software Requirements Specification',
      'icon': Icons.description_outlined,
      'route': const SRSScreen(), // Enable route
    },
  ];

  @override
  void initState() {
    super.initState();
    projectID = widget.projectID;
    context.read<UserDataProvider>().setSelectedProjectId(projectID);
    context.read<UserDataProvider>().setProjectId(projectID);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();

    print("Requirements Menu Screen initialized ${projectID}");
  }

  @override
  void dispose() {
    // _animationController.dispose();
    super.dispose();
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.black87, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Requirements',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Select a category',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 0, 54, 218)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.layers_outlined,
                        color: Color.fromARGB(255, 0, 54, 218),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requirement Categories',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Browse and manage your project requirements',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Menu Items List with animations
                    Expanded(
                      child: ListView.separated(
                        itemCount: _menuItems.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildAnimatedMenuItem(index);
                        },
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

  Widget _buildAnimatedMenuItem(int index) {
    final Map<String, dynamic> item = _menuItems[index];
    final bool isDisabled = item['route'] == null;

    // Create staggered animations
    final Animation<double> animation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        index * 0.1,
        (index * 0.1 + 0.5).clamp(0.0, 1.0),
        curve: Curves.easeOut,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double safeOpacity = animation.value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(100 * (1 - animation.value), 0),
          child: Opacity(
            opacity: safeOpacity,
            child: child,
          ),
        );
      },
      child: _buildMenuItem(item, isDisabled),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item, bool isDisabled) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isDisabled
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon!')),
                  );
                }
              : () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          item['route'],
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOutCubic;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: offsetAnimation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                    ),
                  );
                },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isDisabled
                          ? Colors.grey.withOpacity(0.1)
                          : const Color.fromARGB(255, 0, 54, 218)
                              .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        item['icon'],
                        size: 24,
                        color: isDisabled
                            ? Colors.grey
                            : const Color.fromARGB(255, 0, 54, 218),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDisabled ? Colors.grey : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['subtitle'],
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDisabled
                              ? Colors.grey.shade400
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDisabled ? Colors.grey.shade300 : Colors.black38,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
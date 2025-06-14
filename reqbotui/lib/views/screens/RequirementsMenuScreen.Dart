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
import '../widgets/dark_mode_toggle.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        icon: Icon(Icons.arrow_back_ios,
                            color: Theme.of(context).colorScheme.onSurface, size: 20),
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
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Select a category',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.layers_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CompactDarkModeToggle(),
                    ],
                  ),
                ],
              ),
            ),

            Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),

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
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Browse and manage your project requirements',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
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
                    SnackBar(
                      content: Text('Coming soon!'),
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    ),
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
                          ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5)
                          : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        item['icon'],
                        size: 24,
                        color: isDisabled
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.primary,
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
                          color: isDisabled 
                              ? Theme.of(context).colorScheme.onSurfaceVariant 
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['subtitle'],
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:reqbot/services/providers/data_providers.dart';
import 'package:reqbot/views/screens/summary.dart';
import 'package:provider/provider.dart';
import 'package:reqbot/views/screens/diagramsmenu.dart';
import '../widgets/dark_mode_toggle.dart';

class ReqsMarkScreen extends StatefulWidget {
  const ReqsMarkScreen({Key? key}) : super(key: key);

  @override
  State<ReqsMarkScreen> createState() => _ReqsMarkScreenState();
}

class _ReqsMarkScreenState extends State<ReqsMarkScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TextEditingController _editingController = TextEditingController();
  String Requirements = "";

  Future<void> getReqs() async {
    // final dataProvider = Provider.of<DataProvider>(context, listen: false);
    // setState(() {
    //   Requirements = dataProvider.requirements;
    // });
  }

  @override
  void initState() {
    super.initState();
    // getReqs();
    Requirements = context.read<DataProvider>().requirements;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _editingController.dispose();
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
                            'Project requirements overview',
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
                            Icons.description_outlined,
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
                    // Header with count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Requirements Overview',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            Requirements.isEmpty ? 'No Items' : '1 Item',
                            style: GoogleFonts.inter(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Requirements content
                    Expanded(
                      child: Requirements.isEmpty
                          ? _buildEmptyState()
                          : _buildRequirementsContent(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DiagramsMenu(),
            ),
          );
        },
        icon: Icon(
          Icons.schema_outlined,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        label: Text(
          'Show Diagrams',
          style: GoogleFonts.inter(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementsContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(Requirements),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(_animation),
                  child: Markdown(
                    data: Requirements,
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.inter(
                        fontSize: 16,
                        height: 1.6,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      h1: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      h2: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      h3: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      blockquote: GoogleFonts.inter(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      code: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_outlined,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Requirements Yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Requirements will appear here once they are added to your project',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

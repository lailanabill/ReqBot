import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:reqbot/services/providers/data_providers.dart';
import 'package:reqbot/views/screens/RequirementsMenuScreen.Dart';
import 'package:reqbot/views/screens/functional_requirements_screen.dart';
import 'package:reqbot/views/screens/summary.dart';
import '../widgets/requirement_item.dart';
import '../widgets/custom_dialog.dart';

class TranscriptScreen extends StatefulWidget {
  const TranscriptScreen({super.key});

  @override
  _TranscriptScreenState createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends State<TranscriptScreen>
    with TickerProviderStateMixin {
  String Trasncription = "";
  final TextEditingController _editingController = TextEditingController();
  // String? _editingKey;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final Color primaryColor = const Color.fromARGB(255, 173, 138, 223);

  @override
  void initState() {
    Trasncription = context.read<DataProvider>().summary;
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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
      appBar: AppBar(
        title: Center(
          child: const Text(
            'Transcription',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 0,
        backgroundColor: primaryColor,
        // actions: [
        //   TextButton.icon(
        //     icon: const Icon(Icons.arrow_back, color: Colors.white),
        //     label: const Text(
        //       '',
        //       style: TextStyle(color: Colors.white),
        //     ),
        //     onPressed: () {
        //       Navigator.pushReplacement(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => RequirementsMenuScreen(),
        //         ),
        //       );
        //     },
        //   ),
        // ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // _buildAddButton(),
              const SizedBox(height: 24),
              Expanded(child: _buildRequirementsList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.swap_horiz),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SummaryScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequirementsList() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return FadeTransition(
            opacity: _animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(_animation),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: MarkdownBody(
                              data: Trasncription.isEmpty
                                  ? "Trasncription is yet to be provided"
                                  : Trasncription,
                              styleSheet: MarkdownStyleSheet(
                                p: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Transform.scale(
                            scale: 1.2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

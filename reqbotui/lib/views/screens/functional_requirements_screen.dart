import 'package:flutter/material.dart';
import 'package:reqbot/views/screens/non_functional_requirements_screen.dart';
import '../widgets/requirement_item.dart';
import '../widgets/custom_dialog.dart';

class FunctionalRequirementsScreen extends StatefulWidget {
  const FunctionalRequirementsScreen({super.key});

  @override
  _FunctionalRequirementsScreenState createState() =>
      _FunctionalRequirementsScreenState();
}

class _FunctionalRequirementsScreenState
    extends State<FunctionalRequirementsScreen> with TickerProviderStateMixin {
  final Map<String, bool> _requirements = {
    "Functional Requirement 1": false,
    "Functional Requirement 2": false,
  };
  final TextEditingController _editingController = TextEditingController();
  String? _editingKey;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final Color primaryColor = const Color.fromARGB(255, 187, 151, 236);

  @override
  void initState() {
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
        title: const Text(
          'Functional Requirements',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: primaryColor,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.swap_horiz, color: Colors.white),
            label: const Text(
              'Non-Functional',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NonFunctionalRequirementsScreen(),
                ),
              );
            },
          ),
        ],
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
              _buildAddButton(),
              const SizedBox(height: 24),
              Expanded(child: _buildRequirementsList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.swap_horiz),

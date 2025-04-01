import 'package:flutter/material.dart';
import 'package:reqbot/views/screens/functional_requirements_screen.dart';
import '../widgets/requirement_item.dart';
import '../widgets/custom_dialog.dart';

class NonFunctionalRequirementsScreen extends StatefulWidget {
  const NonFunctionalRequirementsScreen({super.key});

  @override
  _NonFunctionalRequirementsScreenState createState() =>
      _NonFunctionalRequirementsScreenState();
}

class _NonFunctionalRequirementsScreenState
    extends State<NonFunctionalRequirementsScreen>
    with TickerProviderStateMixin {
  final Map<String, bool> _requirements = {
    "Non-Functional Requirement 1": false,
    "Non-Functional Requirement 2": false,
  };
  final TextEditingController _editingController = TextEditingController();
  String? _editingKey;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final Color primaryColor = const Color.fromARGB(255, 173, 138, 223);

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
          'Non-Functional Requirements',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: primaryColor,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.swap_horiz, color: Colors.white),
            label: const Text(
              'Functional',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const FunctionalRequirementsScreen(),
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
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const FunctionalRequirementsScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton.icon(
      onPressed: _showAddDialog,
      icon: const Icon(Icons.add),
      label: const Text("Add Requirement"),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 4,
      ),
    );
  }

  Widget _buildRequirementsList() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ListView.builder(
        itemCount: _requirements.length,
        itemBuilder: (context, index) {
          String key = _requirements.keys.elementAt(index);
          return RequirementItem(
            title: key,
            isSelected: _requirements[key]!,
            animation: _animation,
            primaryColor: primaryColor,
            onCheckboxChanged: (bool? newValue) {
              setState(() => _requirements[key] = newValue ?? false);
            },
            onDelete: () {
              setState(() => _requirements.remove(key));
            },
            onTap: () {
              _editingController.text = key;
              _editingKey = key;
              _showEditDialog();
            },
          );
        },
      ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: "Edit Requirement",
        actionText: "Save",
        controller: _editingController,
        primaryColor: primaryColor,
        onAction: () {
          setState(() {
            if (_editingKey != null && _editingController.text.isNotEmpty) {
              bool value = _requirements[_editingKey!] ?? false;
              _requirements.remove(_editingKey);
              _requirements[_editingController.text] = value;
              _editingKey = null;
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showAddDialog() {
    _editingController.clear();
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: "Add Requirement",
        actionText: "Add",
        controller: _editingController,
        primaryColor: primaryColor,
        onAction: () {
          setState(() {
            if (_editingController.text.isNotEmpty) {
              _requirements[_editingController.text] = false;
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}

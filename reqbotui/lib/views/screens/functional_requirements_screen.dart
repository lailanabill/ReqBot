import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reqbot/services/providers/images_provider.dart';
// import 'package:reqbot/views/screens/functional_requirements_screen.dart';
import 'package:flutter/services.dart';
import 'package:reqbot/views/screens/non_functional_requirements_screen.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:reqbot/services/providers/data_providers.dart';

class FunctionalRequirementsScreen extends StatefulWidget {
  const FunctionalRequirementsScreen({super.key});

  @override
  _FunctionalRequirementsScreenState createState() =>
      _FunctionalRequirementsScreenState();
}

class _FunctionalRequirementsScreenState
    extends State<FunctionalRequirementsScreen> with TickerProviderStateMixin {
  // Use a map for requirements and persistence
  // Map<String, bool> _requirements = {
  //   "Performance": false,
  //   "Security": false,
  // };

  late List<Map<String, dynamic>> allRequirements, _requirements;

  final TextEditingController _editingController = TextEditingController();
  String? _editingKey;
  bool _isDirty = false; // Track if changes have been made

  // Animation controllers
  late AnimationController _listAnimationController;
  late AnimationController _fabAnimationController;
  late AnimationController _addButtonAnimationController;
  late AnimationController _removeAnimationController;
  late AnimationController _switchTypeController;

  // Main color scheme
  final Color primaryColor = const Color.fromARGB(255, 0, 54, 218);

  // Track if a requirement is being removed
  String? _removingRequirement;
  String? _lastRemovedRequirement;
  bool? _lastRemovedValue;

  bool get _hasSelectedItems =>
      _requirements.any((item) => item['selected'] == true);
  @override
  void initState() {
    super.initState();
    allRequirements = context.read<DataProvider>().detailedRequirements;
    _requirements = allRequirements
        .where((req) => req['Type']?.toLowerCase() == 'functional')
        .toList();
    // List item animations
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // FAB animations
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Add button animation
    _addButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Remove animation
    _removeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Switch type animation
    _switchTypeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Start animations
    _listAnimationController.forward();
    _fabAnimationController.forward();
    _addButtonAnimationController.forward();

    // Load saved requirements
    // _loadRequirements();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _fabAnimationController.dispose();
    _addButtonAnimationController.dispose();
    _removeAnimationController.dispose();
    _switchTypeController.dispose();
    _editingController.dispose();
    super.dispose();
  }

  void _removeRequirement(String title) {
    setState(() {
      final index = _requirements.indexWhere((r) => r['Requirement'] == title);
      if (index != -1) {
        _removingRequirement = title;
        _lastRemovedRequirement = title;
        _lastRemovedValue = _requirements[index]['selected'] ?? false;
        _requirements.removeAt(index);
        _isDirty = true;
      }
    });
  }

  // Method to save requirements to persistent storage
  Future<void> _saveRequirements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // final String requirementsJson = json.encode(_requirements);
      // await prefs.setString('non_functional_requirements', requirementsJson);
      await prefs.setString(
          'functional_requirements', json.encode(_requirements));
    } catch (e) {
      print('Error saving requirements: $e');
    }
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
                  Expanded(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.black87, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Functional Requirements',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'System qualities and constraints',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildSwitchButton(),
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
                    // Header with count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Requirements List',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_requirements.length} Items',
                            style: GoogleFonts.inter(
                              color: primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Requirements list with Add button at the bottom
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: _requirements.isEmpty
                                ? _buildEmptyState()
                                : _buildRequirementsList(),
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              if (_hasSelectedItems) _buildConvertButton(),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: _buildAnimatedAddButton(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Save button always visible
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // Save Button
  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _isDirty = false;
            });

            _saveRequirements();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Text('Changes saved successfully'),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green.shade600,
                duration: const Duration(seconds: 2),
              ),
            );
            HapticFeedback.mediumImpact();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Save Changes',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // Beautiful Add Button with Bouncy Animation
  Widget _buildAnimatedAddButton() {
    final Animation<double> scaleAnimation = CurvedAnimation(
      parent: _addButtonAnimationController,
      curve: Curves.elasticOut,
    );

    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: child,
        );
      },
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          _addButtonAnimationController.reset();
          _addButtonAnimationController.forward();
          _showAddDialog();
        },
        splashColor: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor,
                primaryColor.withBlue(min(primaryColor.blue + 40, 255)),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_circle_outline,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                "Add Requirement",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Requirements List with Staggered Animations
  Widget _buildRequirementsList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _requirements.length,
      itemBuilder: (context, index) {
        final req = _requirements[index];
        final String title = req['Requirement'];
        final bool isSelected = req['selected'] ?? false;

        // Create staggered animation for each item
        final Animation<double> animation = CurvedAnimation(
          parent: _listAnimationController,
          curve: Interval(
            index * 0.1,
            index * 0.1 + 0.6,
            curve: Curves.easeOutQuart,
          ),
        );

        // Animate item removal
        // final bool isRemoving = _removingRequirement == key;
        final bool isRemoving = _removingRequirement == title;
        final Animation<double> removeAnimation = CurvedAnimation(
          parent: _removeAnimationController,
          curve: Curves.easeInOut,
        );

        return AnimatedBuilder(
          animation: isRemoving ? removeAnimation : animation,
          builder: (context, child) {
            if (isRemoving) {
              return Opacity(
                opacity: 1 - removeAnimation.value,
                child: Transform.translate(
                  offset: Offset(300 * removeAnimation.value, 0),
                  child: Transform.scale(
                    scale: 1 - (0.2 * removeAnimation.value),
                    child: child,
                  ),
                ),
              );
            }

            return Transform.translate(
              offset: Offset(0, 50 * (1 - animation.value)),
              child: Opacity(
                opacity: animation.value.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: _buildRequirementItem(title, isSelected, index),
        );
      },
    );
  }

  // Individual Requirement Item
  Widget _buildRequirementItem(String title, bool isSelected, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? primaryColor.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              _editingController.text = title;
              _editingKey = title;
              _showEditDialog();
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Animated Checkbox
                  TweenAnimationBuilder<double>(
                    tween:
                        Tween<double>(begin: 0.0, end: isSelected ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, value, child) {
                      return InkWell(
                        onTap: () {
                          // setState(() {
                          //   _requirements[title] = !isSelected;
                          //   _isDirty = true;
                          // });
                          setState(() {
                            _requirements[index]['selected'] =
                                !_requirements[index]['selected'];
                            _isDirty = true;
                          });
                          HapticFeedback.selectionClick();
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Color.lerp(
                              Colors.transparent,
                              primaryColor.withOpacity(0.2),
                              value,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color.lerp(
                                Colors.grey.shade300,
                                primaryColor,
                                value,
                              )!,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.check,
                              size: 16 * value,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),

                  // Requirement Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? primaryColor : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to edit',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Button Row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit Icon
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _editingController.text = title;
                            _editingKey = title;
                            _showEditDialog();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.edit_outlined,
                              color: primaryColor.withOpacity(0.7),
                              size: 22,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Delete Icon
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showDeleteConfirmation(title),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.delete_outline,
                              color: Colors.red.shade400,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Empty State with Animation
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
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 60,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Requirements Yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Add your first functional requirement to get started',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Switch Button with Improved Animation
  Widget _buildSwitchButton() {
    return GestureDetector(
      onTap: () {
        // Start the transition animation
        _switchTypeController.reset();
        _switchTypeController.forward().then((_) {
          // Navigate to Functional requirements after animation
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, animation, __) =>
                  const NonFunctionalRequirementsScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        });

        HapticFeedback.mediumImpact();
      },
      child: AnimatedBuilder(
        animation: _switchTypeController,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _switchTypeController.value < 0.5
                  ? primaryColor.withOpacity(0.1)
                  : Colors.indigo.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              boxShadow: _switchTypeController.value > 0.2
                  ? [
                      BoxShadow(
                        color: Colors.indigo
                            .withOpacity(0.2 * _switchTypeController.value),
                        blurRadius: 10 * _switchTypeController.value,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Transform.rotate(
                  angle: _switchTypeController.value * 2 * pi,
                  child: Icon(
                    Icons.swap_horiz_outlined,
                    size: 18,
                    color: ColorTween(
                      begin: primaryColor,
                      end: Colors.indigo,
                    ).transform(_switchTypeController.value)!,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Switch Type',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: ColorTween(
                      begin: primaryColor,
                      end: Colors.indigo,
                    ).transform(_switchTypeController.value)!,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Delete Confirmation Dialog
  void _showDeleteConfirmation(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.delete_outline,
              color: primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Requirement',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this requirement?',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeRequirement(title);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildAnimatedDialog(
        title: "Edit Requirement",
        actionText: "Save Changes",
        onAction: () {
          setState(() {
            if (_editingKey != null && _editingController.text.isNotEmpty) {
              final index = _requirements.indexWhere(
                  (element) => element['Requirement'] == _editingKey);
              if (index != -1) {
                _requirements[index]['Requirement'] = _editingController.text;
                _editingKey = null;
                _isDirty = true;

                // Reset list animations to play again
                _listAnimationController.reset();
                _listAnimationController.forward();
              }
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
      builder: (context) => _buildAnimatedDialog(
        title: "Add New Requirement",
        actionText: "Add Requirement",
        onAction: () {
          setState(() {
            if (_editingController.text.isNotEmpty) {
              // _requirements[_editingController.text] = false;
              _requirements.add({
                "Requirement": _editingController.text,
                "Type": "Functional",
              });
              _isDirty = true;

              // Reset list animations to play again
              _listAnimationController.reset();
              _listAnimationController.forward();
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  // Animated Custom Dialog
  Widget _buildAnimatedDialog({
    required String title,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    title.contains("Edit") ? Icons.edit_note : Icons.add_task,
                    color: primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _editingController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Enter requirement description",
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  prefixIcon: Icon(
                    Icons.assignment_outlined,
                    color: Colors.grey.shade500,
                  ),
                ),
                style: GoogleFonts.inter(
                  fontSize: 15,
                ),
                onSubmitted: (_) => onAction(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      actionText,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConvertButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.sync_alt),
      label: const Text("Convert to Non-Functional"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        setState(() {
          for (var item in _requirements) {
            if (item['selected'] == true) {
              item['Type'] = 'Non Functional';
              item['selected'] = false; // Optional: deselect after conversion
            }
          }
          // Remove them from the local _requirements list since their type changed
          _requirements.removeWhere((item) => item['Type'] == 'Non Functional');
          _isDirty = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                "Selected requirements converted to non functional."),
            backgroundColor: Colors.green.shade600,
          ),
        );
      },
    );
  }
}

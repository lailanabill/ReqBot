import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reqbot/views/screens/functional_requirements_screen.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/dark_mode_toggle.dart';

class NonFunctionalRequirementsScreen extends StatefulWidget {
  const NonFunctionalRequirementsScreen({super.key});

  @override
  _NonFunctionalRequirementsScreenState createState() =>
      _NonFunctionalRequirementsScreenState();
}

class _NonFunctionalRequirementsScreenState
    extends State<NonFunctionalRequirementsScreen> with TickerProviderStateMixin {
  // Use a map for requirements and persistence
  Map<String, bool> _requirements = {
    "Performance": false,
    "Security": false,
  };
  
  final TextEditingController _editingController = TextEditingController();
  String? _editingKey;
  bool _isDirty = false; // Track if changes have been made
  
  // Animation controllers
  late AnimationController _listAnimationController;
  late AnimationController _fabAnimationController;
  late AnimationController _addButtonAnimationController;
  late AnimationController _removeAnimationController;
  late AnimationController _switchTypeController;
  
  // Track if a requirement is being removed
  String? _removingRequirement;
  String? _lastRemovedRequirement;
  bool? _lastRemovedValue;
  
  @override
  void initState() {
    super.initState();
    
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
    _loadRequirements();
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
      _removingRequirement = title;
      _lastRemovedRequirement = title;
      _lastRemovedValue = _requirements[title];
    });
    
    _removeAnimationController.reset();
    _removeAnimationController.forward().then((_) {
      setState(() {
        _requirements.remove(title);
        _removingRequirement = null;
        _isDirty = true;
      });

      // Show snackbar with undo option
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Requirement removed'),
          action: SnackBarAction(
            label: 'Undo',
            textColor: Theme.of(context).colorScheme.primary,
            onPressed: () {
              if (_lastRemovedRequirement != null && _lastRemovedValue != null) {
                setState(() {
                  _requirements[_lastRemovedRequirement!] = _lastRemovedValue!;
                  _isDirty = true;
                });
                // Reset list animations
                _listAnimationController.reset();
                _listAnimationController.forward();
              }
            },
          ),
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  // Method to load requirements from persistent storage
  Future<void> _loadRequirements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? requirementsJson = prefs.getString('non_functional_requirements');
      
      if (requirementsJson != null) {
        final Map<String, dynamic> decodedMap = json.decode(requirementsJson);
        setState(() {
          _requirements = Map<String, bool>.from(decodedMap);
        });
      }
    } catch (e) {
      print('Error loading requirements: $e');
    }
  }

  // Method to save requirements to persistent storage
  Future<void> _saveRequirements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String requirementsJson = json.encode(_requirements);
      await prefs.setString('non_functional_requirements', requirementsJson);
    } catch (e) {
      print('Error saving requirements: $e');
    }
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
                  Expanded(
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Non-Functional Requirements',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'System qualities and constraints',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildSwitchButton(),
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
                          'Requirements List',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_requirements.length} Items',
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
                          Align(
                            alignment: Alignment.centerRight,
                            child: _buildAnimatedAddButton(),
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
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
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
                    Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.onPrimary),
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
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Save Changes',
            style: GoogleFonts.inter(
              color: Theme.of(context).colorScheme.onPrimary,
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
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withBlue(min(Theme.of(context).colorScheme.primary.blue + 40, 255)),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
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
        final String key = _requirements.keys.elementAt(index);
        final bool isSelected = _requirements[key]!;
        
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
        final bool isRemoving = _removingRequirement == key;
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
          child: _buildRequirementItem(key, isSelected, index),
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
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.05) : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.outline.withOpacity(0.05),
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
                    tween: Tween<double>(begin: 0.0, end: isSelected ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, value, child) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _requirements[title] = !isSelected;
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
                              Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              value,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color.lerp(
                                Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                Theme.of(context).colorScheme.primary,
                                value,
                              )!,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.check,
                              size: 16 * value,
                              color: Theme.of(context).colorScheme.primary,
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
                            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to edit',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
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
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_outlined,
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
                'Add your first non-functional requirement to get started',
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
              pageBuilder: (_, animation, __) => const FunctionalRequirementsScreen(),
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
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              boxShadow: _switchTypeController.value > 0.2 ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.2 * _switchTypeController.value),
                  blurRadius: 10 * _switchTypeController.value,
                  offset: const Offset(0, 2),
                )
              ] : null,
            ),
            child: Row(
              children: [
                Transform.rotate(
                  angle: _switchTypeController.value * 2 * pi,
                  child: Icon(
                    Icons.swap_horiz_outlined,
                    size: 18,
                    color: ColorTween(
                      begin: Theme.of(context).colorScheme.primary,
                      end: Theme.of(context).colorScheme.secondary,
                    ).transform(_switchTypeController.value)!,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Switch Type',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: ColorTween(
                      begin: Theme.of(context).colorScheme.primary,
                      end: Theme.of(context).colorScheme.secondary,
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
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Requirement',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this requirement?',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
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

  // Custom Dialog Methods
  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildAnimatedDialog(
        title: "Edit Requirement",
        actionText: "Save Changes",
        onAction: () {
          setState(() {
            if (_editingKey != null && _editingController.text.isNotEmpty) {
              bool value = _requirements[_editingKey!] ?? false;
              _requirements.remove(_editingKey);
              _requirements[_editingController.text] = value;
              _editingKey = null;
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
              _requirements[_editingController.text] = false;
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
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
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
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
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
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                  prefixIcon: Icon(
                    Icons.assignment_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                      foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
}

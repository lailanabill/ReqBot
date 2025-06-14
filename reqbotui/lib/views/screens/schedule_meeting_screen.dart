import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reqbot/views/screens/meeting_confirmation_screen.dart';
import '../widgets/dark_mode_toggle.dart';

class ScheduleMeetingScreen extends StatefulWidget {
  @override
  _ScheduleMeetingScreenState createState() => _ScheduleMeetingScreenState();
}

class _ScheduleMeetingScreenState extends State<ScheduleMeetingScreen> with TickerProviderStateMixin {
  final List<TimeSlot> timeSlots = [];
  
  // Controllers
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  bool _isLoading = false;
  
  // Animation controllers
  late AnimationController _removeAnimationController;
  int? _removingSlotIndex;

  @override
  void initState() {
    super.initState();
    
    // Setup animation controllers
    _removeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _removeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _selectedStartTime = picked;
          _startTimeController.text = picked.format(context);
        } else {
          _selectedEndTime = picked;
          _endTimeController.text = picked.format(context);
        }
      });
    }
  }

  void _addTimeSlot() {
    if (_selectedDate == null || _selectedStartTime == null || _selectedEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select date and time'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Check if end time is after start time
    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedStartTime!.hour,
      _selectedStartTime!.minute,
    );
    
    final endDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedEndTime!.hour,
      _selectedEndTime!.minute,
    );
    
    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    setState(() {
      timeSlots.add(
        TimeSlot(
          date: _selectedDate!,
          startTime: _selectedStartTime!,
          endTime: _selectedEndTime!,
        ),
      );
      
      // Clear the inputs
      _dateController.clear();
      _startTimeController.clear();
      _endTimeController.clear();
      _selectedDate = null;
      _selectedStartTime = null;
      _selectedEndTime = null;
    });
  }
  
  void _removeTimeSlot(int index) {
    setState(() {
      _removingSlotIndex = index;
    });
    
    _removeAnimationController.reset();
    _removeAnimationController.forward().then((_) {
      setState(() {
        timeSlots.removeAt(index);
        _removingSlotIndex = null;
      });
    });
  }
  
  void _editTimeSlot(int index) {
    final slot = timeSlots[index];
    
    setState(() {
      _selectedDate = slot.date;
      _selectedStartTime = slot.startTime;
      _selectedEndTime = slot.endTime;
      
      _dateController.text = "${slot.date.day}/${slot.date.month}/${slot.date.year}";
      _startTimeController.text = slot.startTime.format(context);
      _endTimeController.text = slot.endTime.format(context);
    });
    
    // Remove the slot being edited
    _removeTimeSlot(index);
    
    // Scroll to the top to show the form
    // This assumes you have a ScrollController
    Future.delayed(Duration(milliseconds: 300), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Edit the time slot and click "Add Time Slot"'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }
  
  void _submitAvailability() {
    if (timeSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add at least one time slot'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      
      // Navigate to confirmation screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MeetingConfirmationScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Column(
          children: [
            Text(
              'Schedule Meeting',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            Text(
              'Step 3 of 3',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios, 
            size: 20,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CompactDarkModeToggle(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Your Availability',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Add your available time slots for a meeting with your client.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 30),

                      // Date picker
                      Text(
                        'Date',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: _getInputDecoration(hintText: 'Select Date', icon: Icons.calendar_today),
                      ),
                      SizedBox(height: 20),

                      // Time range
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Start Time',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: _startTimeController,
                                  readOnly: true,
                                  onTap: () => _selectTime(context, true),
                                  decoration: _getInputDecoration(hintText: 'Start', icon: Icons.access_time),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'End Time',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: _endTimeController,
                                  readOnly: true,
                                  onTap: () => _selectTime(context, false),
                                  decoration: _getInputDecoration(hintText: 'End', icon: Icons.access_time),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Add button
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: _addTimeSlot,
                          icon: Icon(Icons.add),
                          label: Text('Add Time Slot'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            foregroundColor: Theme.of(context).colorScheme.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),

                      // Time slots list
                      if (timeSlots.isNotEmpty) ...[
                        Text(
                          'Your Available Time Slots',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 16),
                        ..._buildTimeSlotsList(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            // Submit button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitAvailability,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    disabledBackgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    disabledForegroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary
                            ),
                          ),
                        )
                      : Text(
                          'Submit Availability',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration({required String hintText, required IconData icon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      suffixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
    );
  }

  // Time slots list widgets
  List<Widget> _buildTimeSlotsList() {
    return timeSlots.asMap().entries.map((entry) {
      final index = entry.key;
      final slot = entry.value;
      
      // Animate item removal
      final bool isRemoving = _removingSlotIndex == index;
      final Animation<double> removeAnimation = CurvedAnimation(
        parent: _removeAnimationController,
        curve: Curves.easeInOut,
      );
      
      return AnimatedBuilder(
        animation: isRemoving ? removeAnimation : const AlwaysStoppedAnimation(0),
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
          return child!;
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${slot.date.day}/${slot.date.month}/${slot.date.year}",
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "${slot.startTime.format(context)} - ${slot.endTime.format(context)}",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                      onPressed: () => _editTimeSlot(index),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                      onPressed: () => _removeTimeSlot(index),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}

class TimeSlot {
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  
  TimeSlot({
    required this.date,
    required this.startTime,
    required this.endTime,
  });
} 
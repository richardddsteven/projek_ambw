import 'package:flutter/material.dart';
import 'package:projek_ambw/models/doctor.dart';
import 'package:projek_ambw/utils/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:projek_ambw/services/supabase_service.dart';
import 'package:projek_ambw/services/auth_service.dart';

class DoctorDetailScreen extends StatefulWidget {
  final Doctor doctor;
  
  const DoctorDetailScreen({
    Key? key,
    required this.doctor,
  }) : super(key: key);

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  // Get current user ID from AuthService
  String get userId => AuthService.currentUser?.id ?? '';
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  final List<TimeOfDay> _allTimeSlots = [
    const TimeOfDay(hour: 9, minute: 0),
    const TimeOfDay(hour: 10, minute: 0),
    const TimeOfDay(hour: 11, minute: 0),
    const TimeOfDay(hour: 14, minute: 0),
    const TimeOfDay(hour: 15, minute: 0),
    const TimeOfDay(hour: 16, minute: 0),
  ];
  List<TimeOfDay> _bookedTimeSlots = [];
  bool _isLoading = false;
  bool _isLoadingTimeSlots = false;
  
  @override
  void initState() {
    super.initState();
    _loadBookedTimeSlots();
  }
  
  Future<void> _loadBookedTimeSlots() async {
    setState(() {
      _isLoadingTimeSlots = true;
    });
    
    try {
      final bookedSlots = await SupabaseService.getUnavailableTimeSlots(
        doctorId: widget.doctor.id,
        date: _selectedDate,
        allTimeSlots: _allTimeSlots,
      );
      
      setState(() {
        _bookedTimeSlots = bookedSlots;
        _isLoadingTimeSlots = false;
      });
    } catch (e) {
      print('Error loading booked time slots: $e');
      setState(() {
        _isLoadingTimeSlots = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Doctor header image
          Container(
            height: 250,
            width: double.infinity,
            color: AppColors.primaryColor.withOpacity(0.1),
            child: CachedNetworkImage(
              imageUrl: widget.doctor.photoUrl,
              fit: BoxFit.cover,
              height: 250,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.person, size: 80),
              ),
            ),
          ),
          
          // Doctor details
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 220),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Doctor name and specialty
                    Text(
                      'Dr. ${widget.doctor.name}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.doctor.specialty,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Doctor stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Experience', '${widget.doctor.experience} years', Icons.calendar_today),
                        _buildStatItem('Patients', '1,500+', Icons.people),
                        _buildStatItem('Rating', '${widget.doctor.rating ?? 4.5}', Icons.star),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // About doctor
                    const Text(
                      'About Doctor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.doctor.about ?? 'Dr. ${widget.doctor.name} is a ${widget.doctor.specialty} with ${widget.doctor.experience} years of experience in diagnosing and treating patients.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Select date
                    const Text(
                      'Select Date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 60)),
                      focusedDay: _selectedDate,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDate, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDate = selectedDay;
                          _selectedTime = null;
                        });
                        // Reload booked time slots for the new date
                        _loadBookedTimeSlots();
                      },
                      calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: const TextStyle(fontSize: 16),
                        leftChevronIcon: const Icon(
                          Icons.chevron_left,
                          color: AppColors.primaryColor,
                        ),
                        rightChevronIcon: const Icon(
                          Icons.chevron_right,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Available time slots
                    const Text(
                      'Available Time Slots',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _isLoadingTimeSlots
                    ? const Center(child: CircularProgressIndicator())
                    : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _allTimeSlots.map((time) {
                        final isSelected = _selectedTime == time;
                        final isBooked = _isTimeSlotBooked(time);
                        
                        // Determine colors based on status
                        final backgroundColor = isSelected 
                          ? AppColors.primaryColor 
                          : isBooked 
                              ? Colors.red[100] 
                              : Colors.white;
                              
                        final textColor = isSelected 
                          ? Colors.white 
                          : isBooked 
                              ? Colors.red[700] 
                              : Colors.grey[700];
                              
                        final borderColor = isSelected 
                          ? AppColors.primaryColor 
                          : isBooked 
                              ? Colors.red[300]! 
                              : Colors.grey[300]!;
                        
                        return GestureDetector(
                          onTap: isBooked 
                            ? null  // Disable tap for booked slots
                            : () {
                                setState(() {
                                  _selectedTime = time;
                                });
                              },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: borderColor,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                if (isBooked)
                                  const SizedBox(width: 4),
                                if (isBooked)
                                  Icon(Icons.block, size: 14, color: Colors.red[700])
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    
                    // Book button
                    ElevatedButton(
                      onPressed: (_selectedTime == null || _isTimeSlotBooked(_selectedTime!))
                          ? null
                          : () => _bookAppointment(),
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: Colors.grey[300],
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white),
                            )
                          : const Text('Book Appointment'),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          // Back button (moved to last so it's always on top)
          Positioned(
            top: 40,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back, size: 24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  // Check if a time slot is already booked
  bool _isTimeSlotBooked(TimeOfDay time) {
    for (var bookedTime in _bookedTimeSlots) {
      if (bookedTime.hour == time.hour && bookedTime.minute == time.minute) {
        return true;
      }
    }
    return false;
  }
    void _bookAppointment() async {
    if (_selectedTime == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Create the appointment date by combining the selected date and time
      final appointmentDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      
      // Double-check if the slot is available
      final isBooked = await SupabaseService.isDoctorBooked(
        doctorId: widget.doctor.id,
        appointmentDate: appointmentDate
      );
      
      if (isBooked) {
        // Show error that the slot is no longer available
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Time Slot Not Available'),
              content: const Text('Sorry, this time slot has just been booked by someone else. Please select another time.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _loadBookedTimeSlots(); // Reload time slots
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }
      
      final appointmentType = '${widget.doctor.specialty} Consultation';
      
      await SupabaseService.createAppointment(
        userId: userId,
        doctorId: widget.doctor.id,
        appointmentDate: appointmentDate,
        type: appointmentType,
      );
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: Text(
              'Your appointment with Dr. ${widget.doctor.name} has been booked for ${DateFormat('EEEE, MMM d').format(_selectedDate)} at ${_selectedTime!.format(context)}.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Go back to previous screen, trigger refresh
                  // Show custom floating notification at the top
                  OverlayEntry? overlayEntry;
                  overlayEntry = OverlayEntry(
                    builder: (context) => Positioned(
                      top: 40,
                      left: 24,
                      right: 24,
                      child: Material(
                        color: Colors.transparent,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.green[600],
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.check_circle, color: Colors.white, size: 28),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Appointment booked successfully!',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                  Overlay.of(context, rootOverlay: true)?.insert(overlayEntry);
                  Future.delayed(const Duration(seconds: 2), () {
                    overlayEntry?.remove();
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Check if it's an RLS policy violation error
        final errorMessage = e.toString();
        final isRLSError = errorMessage.contains('violates row-level security policy');
        
        // Show a more user-friendly error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Booking Failed'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'We couldn\'t complete your booking.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Error details:  ￼e.toString()}'),
                const SizedBox(height: 12),
                if (isRLSError)
                  const Text(
                    'This is a Row Level Security (RLS) policy error. Please run the "fix_rls_policies.sql" script in the Supabase SQL Editor to fix this issue.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )
                else
                  const Text(
                    'Please make sure the Supabase database has been set up correctly with the provided schema.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Show custom floating error notification at the top
                  OverlayEntry? overlayEntry;
                  overlayEntry = OverlayEntry(
                    builder: (context) => Positioned(
                      top: 40,
                      left: 24,
                      right: 24,
                      child: Material(
                        color: Colors.transparent,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.red[700],
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.error, color: Colors.white, size: 28),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Failed to book appointment!',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                  Overlay.of(context, rootOverlay: true)?.insert(overlayEntry);
                  Future.delayed(const Duration(seconds: 2), () {
                    overlayEntry?.remove();
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}

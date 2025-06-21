import 'package:flutter/material.dart';
import 'package:projek_ambw/models/appointment.dart';
import 'package:projek_ambw/services/supabase_service.dart';
import 'package:projek_ambw/services/auth_service.dart';
import 'package:projek_ambw/utils/app_theme.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Get current user ID from AuthService
  String get userId => AuthService.currentUser?.id ?? '';
  late Future<List<Appointment>> _appointmentsFuture;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _appointmentsFuture = _loadAppointments();
  }
  
  Future<List<Appointment>> _loadAppointments() async {
    try {
      final appointmentsData = await SupabaseService.getUserAppointments(userId);
      return appointmentsData.map((data) => Appointment.fromJson(data)).toList();
    } catch (e) {
      // Return dummy data for testing if Supabase table isn't set up yet
      return [
        Appointment(
          id: '1',
          userId: userId,
          doctor: await _getDummyDoctor('1'),
          appointmentDate: DateTime.now().add(const Duration(days: 5)),
          type: 'Orthopedic',
          status: 'scheduled',
          notes: 'Foot & Ankle',
        ),
        Appointment(
          id: '2',
          userId: userId,
          doctor: await _getDummyDoctor('2'),
          appointmentDate: DateTime.now().subtract(const Duration(days: 10)),
          type: 'Neurology',
          status: 'completed',
          notes: 'Headache consultation',
        ),
      ];
    }
  }
  
  Future<dynamic> _getDummyDoctor(String id) async {
    if (id == '1') {
      return {
        'id': '1',
        'name': 'Jennifer Smith',
        'specialty': 'Orthopedist',
        'photo_url': 'https://randomuser.me/api/portraits/women/32.jpg',
        'experience': 8,
        'about': 'Orthopedic surgeon specializing in foot and ankle disorders.',
        'rating': 4.8,
      };
    } else {
      return {
        'id': '2',
        'name': 'Warner',
        'specialty': 'Neurologist',
        'photo_url': 'https://randomuser.me/api/portraits/men/42.jpg',
        'experience': 5,
        'about': 'Neurologist with expertise in headache disorders and stroke management.',
        'rating': 4.5,
      };
    }
  }
  
  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      await SupabaseService.cancelAppointment(appointmentId);
      setState(() {
        _appointmentsFuture = _loadAppointments();
      });
      
      if (mounted) {
        // Floating green notification at the top for success
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
                        'Appointment cancelled successfully!',
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
        Overlay.of(context, rootOverlay: true).insert(overlayEntry);
        Future.delayed(const Duration(seconds: 2), () {
          overlayEntry?.remove();
        });
      }
    } catch (e) {
      if (mounted) {
        // Floating red notification at the top for error
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
                        'Failed to cancel appointment!',
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
        Overlay.of(context, rootOverlay: true).insert(overlayEntry);
        Future.delayed(const Duration(seconds: 2), () {
          overlayEntry?.remove();
        });
      }
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('My Appointments'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryColor,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentsList(isUpcoming: true),
          _buildAppointmentsList(isUpcoming: false),
        ],
      ),
    );
  }
  
  Widget _buildAppointmentsList({required bool isUpcoming}) {
    return FutureBuilder<List<Appointment>>(
      future: _appointmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No ${isUpcoming ? 'upcoming' : 'past'} appointments',
                  style: TextStyle(fontSize: 18, color: Colors.grey[500], fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  isUpcoming
                      ? 'You have no scheduled appointments.'
                      : 'No appointment history found.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
              ],
            ),
          );
        }

        final now = DateTime.now();
        final appointments = snapshot.data!
            .where((appointment) {
              final isInFuture = appointment.appointmentDate.isAfter(now);
              return isUpcoming ? isInFuture && appointment.status != 'cancelled' : !isInFuture || appointment.status == 'cancelled';
            })
            .toList()
          ..sort((a, b) =>
              isUpcoming
                  ? a.appointmentDate.compareTo(b.appointmentDate)
                  : b.appointmentDate.compareTo(a.appointmentDate)
          );

        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No ${isUpcoming ? 'upcoming' : 'past'} appointments',
                  style: TextStyle(fontSize: 18, color: Colors.grey[500], fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          itemCount: appointments.length,
          separatorBuilder: (context, index) => const SizedBox(height: 18),
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.07),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: appointment.status == 'cancelled'
                      ? Colors.red[100]!
                      : AppColors.primaryColor.withOpacity(0.08),
                  width: 1.2,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.13),
                  backgroundImage: NetworkImage(appointment.doctor.photoUrl),
                ),
                title: Text(
                  'Dr. ${appointment.doctor.name}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.medical_services, size: 16, color: AppColors.primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          appointment.doctor.specialty,
                          style: TextStyle(fontSize: 13, color: AppColors.primaryColor, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 15, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          '${appointment.appointmentDate.day.toString().padLeft(2, '0')}-${appointment.appointmentDate.month.toString().padLeft(2, '0')}-${appointment.appointmentDate.year}',
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time, size: 15, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          '${appointment.appointmentDate.hour.toString().padLeft(2, '0')}:${appointment.appointmentDate.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 15, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          appointment.status == 'cancelled'
                              ? 'Cancelled'
                              : appointment.status == 'completed'
                                  ? 'Completed'
                                  : 'Scheduled',
                          style: TextStyle(
                            fontSize: 13,
                            color: appointment.status == 'cancelled'
                                ? Colors.red[400]
                                : appointment.status == 'completed'
                                    ? Colors.green[600]
                                    : AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: isUpcoming && appointment.status != 'cancelled'
                    ? IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red, size: 26),
                        tooltip: 'Cancel Appointment',
                        onPressed: () => _showCancelConfirmationDialog(appointment),
                      )
                    : null,
                onTap: () {
                  // TODO: Show appointment details dialog/page if needed
                },
              ),
            );
          },
        );
      },
    );
  }
  
  void _showCancelConfirmationDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: Text('Are you sure you want to cancel your appointment with Dr. ${appointment.doctor.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelAppointment(appointment.id);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}

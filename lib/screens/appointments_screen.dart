import 'package:flutter/material.dart';
import 'package:projek_ambw/models/appointment.dart';
import 'package:projek_ambw/services/supabase_service.dart';
import 'package:projek_ambw/utils/app_theme.dart';
import 'package:projek_ambw/widgets/appointment_card.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Use a valid UUID for our test user
  final String userId = 'd0e70ba1-0e15-49e0-a7e9-5d26dfdc07d1'; // Test user ID
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment cancelled successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel appointment: $e')),
        );
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
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No appointments found'),
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
            child: Text('No ${isUpcoming ? 'upcoming' : 'past'} appointments'),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            return AppointmentCard(
              appointment: appointment,
              onTap: () {
                // Could navigate to appointment details screen
              },
              onCancel: isUpcoming && appointment.status != 'cancelled'
                  ? () => _showCancelConfirmationDialog(appointment)
                  : null,
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

import 'package:flutter/material.dart';
import 'package:projek_ambw/models/appointment.dart';
import 'package:projek_ambw/models/doctor.dart';
import 'package:projek_ambw/services/supabase_service.dart';
import 'package:projek_ambw/services/auth_service.dart';
import 'package:projek_ambw/utils/app_theme.dart';
import 'package:projek_ambw/widgets/appointment_card.dart';
import 'package:projek_ambw/widgets/doctor_card.dart';
import 'package:projek_ambw/widgets/specialty_card.dart';
import 'package:projek_ambw/screens/doctor_list_screen.dart';
import 'package:projek_ambw/screens/doctor_detail_screen.dart';
import 'package:projek_ambw/screens/appointments_screen.dart';
import 'package:projek_ambw/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Get current user ID from AuthService
  String get userId => AuthService.currentUser?.id ?? '';
  late Future<List<Doctor>> _doctorsFuture;
  late Future<List<Appointment>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _doctorsFuture = _loadDoctors();
    _appointmentsFuture = _loadAppointments();
  }

  Future<List<Doctor>> _loadDoctors() async {
    try {
      final doctorsData = await SupabaseService.getDoctors();
      return doctorsData.map((data) => Doctor.fromJson(data)).toList();
    } catch (e) {
      // For testing, return dummy data if Supabase table isn't set up yet
      return [
        Doctor(
          id: '1',
          name: 'Jennifer Smith',
          specialty: 'Orthopedist',
          photoUrl: 'https://randomuser.me/api/portraits/women/32.jpg',
          experience: 8,
          about: 'Orthopedic surgeon specializing in foot and ankle disorders.',
          rating: 4.8,
        ),
        Doctor(
          id: '2',
          name: 'Warner',
          specialty: 'Neurologist',
          photoUrl: 'https://randomuser.me/api/portraits/men/42.jpg',
          experience: 5,
          about: 'Neurologist with expertise in headache disorders and stroke management.',
          rating: 4.5,
        ),
        Doctor(
          id: '3',
          name: 'Raj Patel',
          specialty: 'Cardiologist',
          photoUrl: 'https://randomuser.me/api/portraits/men/56.jpg',
          experience: 12,
          about: 'Interventional cardiologist with focus on heart diseases.',
          rating: 4.9,
        ),
      ];
    }
  }

  Future<List<Appointment>> _loadAppointments() async {
    try {
      final appointmentsData = await SupabaseService.getUserAppointments(userId);
      return appointmentsData.map((data) => Appointment.fromJson(data)).toList();
    } catch (e) {
      final doctors = await _doctorsFuture;
      if (doctors.isNotEmpty) {
        // Return dummy appointment data for testing
        return [
          Appointment(
            id: '1',
            userId: userId,
            doctor: doctors[0],
            appointmentDate: DateTime(2024, 9, 7, 10, 30),
            type: 'Orthopedic',
            status: 'scheduled',
            notes: 'Foot & Ankle',
          ),
        ];
      }
      return [];
    }
  }
  @override
  Widget build(BuildContext context) {
    final userName = AuthService.currentUser?.name ?? 'User';
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hello,',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          userName + '!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.logout),
                          tooltip: 'Logout',
                          onPressed: () async {
                            await _showLogoutDialog(context);
                          },
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            _showProfileOptions(context);
                          },
                          child: CircleAvatar(
                            backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Search box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.textTertiary),
                      const SizedBox(width: 12),
                      Text(
                        'Search Doctor',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Specialty Categories
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      SpecialtyCard(
                        title: 'Neurologist',
                        iconPath: 'assets/icons/brain.png',
                        backgroundColor: AppColors.neurologistColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DoctorListScreen(specialty: 'Neurologist'),
                            ),
                          );
                        },
                      ),
                      SpecialtyCard(
                        title: 'Cardiologist',
                        iconPath: 'assets/icons/heart.png',
                        backgroundColor: AppColors.cardiologistColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DoctorListScreen(specialty: 'Cardiologist'),
                            ),
                          );
                        },
                      ),
                      SpecialtyCard(
                        title: 'Orthopedist',
                        iconPath: 'assets/icons/bone.png',
                        backgroundColor: AppColors.orthopedistColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DoctorListScreen(specialty: 'Orthopedist'),
                            ),
                          );
                        },
                      ),
                      SpecialtyCard(
                        title: 'Pulmonologist',
                        iconPath: 'assets/icons/lung.png',
                        backgroundColor: AppColors.pulmonologistColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DoctorListScreen(specialty: 'Pulmonologist'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Upcoming Appointment
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Upcoming Appointment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FutureBuilder<List<Appointment>>(
                      future: _appointmentsFuture,
                      builder: (context, snapshot) {
                        return TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AppointmentsScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'See All',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                FutureBuilder<List<Appointment>>(
                  future: _appointmentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading appointments: ${snapshot.error}',
                          style: const TextStyle(color: AppColors.errorColor),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No upcoming appointments'),
                      );
                    }
                    
                    // Get the nearest upcoming appointment
                    final upcomingAppointments = snapshot.data!
                        .where((appointment) => 
                            appointment.appointmentDate.isAfter(DateTime.now()) && 
                            appointment.status != 'cancelled')
                        .toList()
                      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
                    
                    if (upcomingAppointments.isEmpty) {
                      return const Center(
                        child: Text('No upcoming appointments'),
                      );
                    }
                    
                    return AppointmentCard(
                      appointment: upcomingAppointments.first,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AppointmentsScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // My Recent Visit
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Recent Visit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DoctorListScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                FutureBuilder<List<Doctor>>(
                  future: _doctorsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading doctors: ${snapshot.error}',
                          style: const TextStyle(color: AppColors.errorColor),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No recent visits'),
                      );
                    }
                    
                    // Get the first 2 doctors as recent visits (for demo purposes)
                    final doctors = snapshot.data!.take(2).toList();
                    
                    return Column(
                      children: doctors.map((doctor) {
                        return DoctorCard(
                          doctor: doctor,
                          isSmall: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorDetailScreen(doctor: doctor),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            label: 'Doctors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment_outlined),
            label: 'Hospital',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await AuthService.signOut();
                if (!mounted) return;
                
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Profile Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('View Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to profile screen
                  // We could add a profile screen here in the future
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to edit profile screen
                  // We could add an edit profile screen here in the future
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.errorColor),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: AppColors.errorColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

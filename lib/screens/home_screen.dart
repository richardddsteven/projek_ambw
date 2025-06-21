import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:projek_ambw/screens/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:flutter/widgets.dart' show ScrollDirection;

const ScrollDirection_reverse = 'ScrollDirection.reverse';
const ScrollDirection_forward = 'ScrollDirection.forward';

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
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _searchDebounce;
  bool _isNavigatingToDoctorList = false;
  bool _showBottomNavBar = true;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _doctorsFuture = _loadDoctors();
    _appointmentsFuture = _loadAppointments();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection.toString() == ScrollDirection_reverse) {
      if (_showBottomNavBar) {
        setState(() {
          _showBottomNavBar = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection.toString() == ScrollDirection_forward) {
      if (!_showBottomNavBar) {
        setState(() {
          _showBottomNavBar = true;
        });
      }
    }
  }

  Future<List<Doctor>> _loadDoctors() async {
    try {
      final doctorsData = await SupabaseService.getDoctors();
      return doctorsData.map((data) => Doctor.fromJson(data)).toList();
    } catch (e) {
      return [];
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
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = AuthService.currentUser?.name ?? 'User';
    final size = MediaQuery.of(context).size;
    final width = size.width;
    // Responsive breakpoints
    double categoryHeight;
    double iconSize;
    double fontSize;
    double horizontalPadding;
    double headerFontSize;
    double headerAvatarRadius;
    bool useConstrainedBox;
    if (width >= 900) {
      // Large screen
      categoryHeight = 140;
      iconSize = 48;
      fontSize = 18;
      horizontalPadding = 0;
      headerFontSize = 32;
      headerAvatarRadius = 32;
      useConstrainedBox = true;
    } else if (width >= 600) {
      // Medium screen
      categoryHeight = 120;
      iconSize = 36;
      fontSize = 16;
      horizontalPadding = 12;
      headerFontSize = 24;
      headerAvatarRadius = 24;
      useConstrainedBox = true;
    } else {
      // Small screen (HP)
      categoryHeight = 125;
      iconSize = 32;
      fontSize = 14;
      horizontalPadding = 16;
      headerFontSize = 18;
      headerAvatarRadius = 18;
      useConstrainedBox = false;
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Enhanced gradient background with additional decorative circles
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF60A5FA), Color(0xFF38BDF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Top left decorative circle
                  Positioned(
                    top: -80,
                    left: -80,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  // Bottom right decorative circle
                  Positioned(
                    bottom: -60,
                    right: -60,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.10),
                      ),
                    ),
                  ),
                  // Center right decorative circle
                  Positioned(
                    top: 200,
                    right: -40,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Curved white overlay for content area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _TopCurveClipper(),
              child: Container(
                height: width > 600 ? 420 : 340,
                color: Colors.white,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Align(
                alignment: Alignment.topCenter,
                child: useConstrainedBox
                    ? ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: _buildHomeContent(
                            userName,
                            headerFontSize,
                            headerAvatarRadius,
                            fontSize,
                            categoryHeight,
                            iconSize,
                            context,
                            width,
                          ),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: _buildHomeContent(
                          userName,
                          headerFontSize,
                          headerAvatarRadius,
                          fontSize,
                          categoryHeight,
                          iconSize,
                          context,
                          width,
                        ),
                      ),
              ),
            ),
          ),
          // Floating Bottom Navigation Bar (match DoctorListScreen)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset: _showBottomNavBar ? Offset.zero : const Offset(0, 1),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showBottomNavBar ? 1.0 : 0.0,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: width > 1000 ? 800 : (width > 600 ? 600 : 400),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: BottomNavigationBar(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            type: BottomNavigationBarType.fixed,
                            selectedItemColor: AppColors.primaryColor,
                            unselectedItemColor: Colors.grey[400],
                            showSelectedLabels: true,
                            showUnselectedLabels: false,
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
                                icon: Icon(Icons.person_outline),
                                label: 'Profile',
                              ),
                            ],
                            onTap: (index) {
                              if (index == 1) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DoctorListScreen(),
                                  ),
                                );
                              } else if (index == 2) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileScreen(),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tambahkan method baru _buildHomeContent agar kode lebih rapi
  Widget _buildHomeContent(
    String userName,
    double headerFontSize,
    double headerAvatarRadius,
    double fontSize,
    double categoryHeight,
    double iconSize,
    BuildContext context,
    double width,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: headerFontSize > 20 ? 40 : 24),
        // Header with avatar and greeting
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome,',
                    style: GoogleFonts.poppins(
                      fontSize: fontSize,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    userName + '!',
                    style: GoogleFonts.poppins(
                      fontSize: headerFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                _showProfileOptions(context);
              },
              child: CircleAvatar(
                backgroundColor: AppColors.primaryColor.withOpacity(0.15),
                radius: headerAvatarRadius,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: headerFontSize - 4,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: width > 600 ? 32 : 20),
        // Search bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: width > 600 ? 24 : 16, vertical: width > 600 ? 18 : 12),
          child: Row(
            children: [
              Icon(Icons.search, color: AppColors.primaryColor, size: width > 600 ? 28 : 22),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
                    if (value.trim().isNotEmpty) {
                      _searchDebounce = Timer(const Duration(milliseconds: 500), () {
                        if (!_isNavigatingToDoctorList) {
                          _isNavigatingToDoctorList = true;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorListScreen(searchQuery: value.trim()),
                            ),
                          ).then((_) {
                            _isNavigatingToDoctorList = false;
                          });
                        }
                      });
                    }
                  },
                  onSubmitted: (value) {
                    final query = value.trim();
                    if (query.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorListScreen(searchQuery: query),
                        ),
                      );
                      // Optionally clear search after navigation
                      // _searchController.clear();
                      // _searchQuery = '';
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Search doctor, specialist... ',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: GoogleFonts.poppins(
                    color: Colors.grey[800],
                    fontSize: width > 600 ? 18 : 15,
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                  child: Icon(Icons.close, color: Colors.grey[500], size: 20),
                ),
            ],
          ),
        ),
        SizedBox(height: width > 600 ? 32 : 20),
        // Categories
        Text(
          'Categories',
          style: GoogleFonts.poppins(
            fontSize: width > 600 ? 22 : 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: width > 600 ? 20 : 12),
        SizedBox(
          height: categoryHeight,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SpecialtyCard(
                title: 'Neurologist',
                iconPath: 'https://cdn-icons-png.flaticon.com/512/10154/10154420.png',
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
                iconPath: 'https://cdn-icons-png.flaticon.com/512/10154/10154525.png',
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
                iconPath: 'https://cdn-icons-png.freepik.com/512/4006/4006302.png', // tulang/ortho
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
                iconPath: 'https://cdn-icons-png.flaticon.com/512/4006/4006309.png',
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
              SpecialtyCard(
                title: 'Dermatologist',
                iconPath: 'https://cdn-icons-png.freepik.com/512/6330/6330293.png', // kulit/dermatologi
                backgroundColor: AppColors.dermatologistColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DoctorListScreen(specialty: 'Dermatologist'),
                    ),
                  );
                },
              ),
              SpecialtyCard(
                title: 'Ophthalmologist',
                iconPath: 'https://cdn-icons-png.flaticon.com/512/159/159604.png',
                backgroundColor: AppColors.ophthalmologistColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DoctorListScreen(specialty: 'Ophthalmologist'),
                    ),
                  );
                },
              ),
              SpecialtyCard(
                title: 'Pediatrician',
                iconPath: 'https://cdn-icons-png.flaticon.com/512/5996/5996109.png', // anak/pediatri
                backgroundColor: AppColors.pediatricianColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DoctorListScreen(specialty: 'Pediatrician'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        SizedBox(height: width > 600 ? 32 : 20),
        // Upcoming Appointment Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Appointment',
              style: GoogleFonts.poppins(
                fontSize: width > 600 ? 22 : 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            FutureBuilder<List<Appointment>>(
              future: _appointmentsFuture,
              builder: (context, snapshot) {
                return TextButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppointmentsScreen(),
                      ),
                    );
                    if (result == true) {
                      setState(() {
                        _appointmentsFuture = _loadAppointments();
                      });
                    }
                  },
                  child: Text(
                    'See All',
                    style: GoogleFonts.poppins(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                      fontSize: width > 600 ? 16 : 14,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        SizedBox(height: width > 600 ? 16 : 8),
        Container(
          padding: EdgeInsets.all(width > 600 ? 28 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF60A5FA).withOpacity(0.18), Color(0xFF2563EB).withOpacity(0.10)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FutureBuilder<List<Appointment>>(
            future: _appointmentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading appointments',
                    style: TextStyle(color: AppColors.errorColor),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No upcoming appointments'));
              }
              final upcomingAppointments = snapshot.data!
                  .where((appointment) => appointment.appointmentDate.isAfter(DateTime.now()) && appointment.status != 'cancelled')
                  .toList()
                ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
              if (upcomingAppointments.isEmpty) {
                return const Center(child: Text('No upcoming appointments'));
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
        ),
        SizedBox(height: width > 600 ? 32 : 24),
        // Nearby Doctors Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Doctors',
              style: GoogleFonts.poppins(
                fontSize: width > 600 ? 22 : 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
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
              child: Text(
                'See All',
                style: GoogleFonts.poppins(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.bold,
                  fontSize: width > 600 ? 16 : 14,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: width > 600 ? 16 : 8),
        Align(
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.all(width > 600 ? 28 : 16),
            child: FutureBuilder<List<Doctor>>(
              future: _doctorsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading doctors',
                      style: TextStyle(color: AppColors.errorColor),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No available doctors'));
                }
                final doctors = snapshot.data!;
                // Tampilkan 3 dokter terdekat tanpa filter search
                final filteredDoctors = doctors.take(5).toList();
                if (width < 600) {
                  return Column(
                    children: filteredDoctors.map((doctor) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: width > 600 ? 20.0 : 12.0),
                        child: DoctorCard(
                          doctor: doctor,
                          isSmall: width > 600 ? true : false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorDetailScreen(doctor: doctor),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                } else {
                  // Tampilkan dalam bentuk grid 3 kolom horizontal, jika lebih dari 3 maka ke bawah
                  int crossAxisCount = 3;
                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1300),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 1.15,
                          crossAxisSpacing: 32,
                          mainAxisSpacing: 32,
                        ),
                        itemCount: filteredDoctors.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final doctor = filteredDoctors[index];
                          return Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 400, minWidth: 260),
                              child: DoctorCard(
                                doctor: doctor,
                                isSmall: false,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DoctorDetailScreen(doctor: doctor),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
        SizedBox(height: width > 600 ? 32 : 24),
      ],
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
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
                ),
              ],
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
              ListTile(
                leading: const Icon(Icons.person, color: AppColors.primaryColor),
                title: const Text('Profile', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
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

class _TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 100);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

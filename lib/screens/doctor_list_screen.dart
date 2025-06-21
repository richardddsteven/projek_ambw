import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projek_ambw/models/doctor.dart';
import 'package:projek_ambw/services/supabase_service.dart';
import 'package:projek_ambw/utils/app_theme.dart';
import 'package:projek_ambw/widgets/doctor_card.dart';
import 'package:projek_ambw/screens/doctor_detail_screen.dart';
import 'package:projek_ambw/screens/profile_screen.dart';
import 'package:projek_ambw/screens/home_screen.dart';

// Tambahan agar tidak error jika ScrollDirection tidak dikenali
// Hapus jika environment Flutter Anda sudah benar
const ScrollDirection_reverse = 'ScrollDirection.reverse';
const ScrollDirection_forward = 'ScrollDirection.forward';

class DoctorListScreen extends StatefulWidget {
  final String? specialty;
  final String? searchQuery;
  const DoctorListScreen({Key? key, this.specialty, this.searchQuery}) : super(key: key);

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  late Future<List<Doctor>> _doctorsFuture;
  List<Doctor> _allDoctors = [];
  List<Doctor> _filteredDoctors = [];
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showBottomNavBar = true;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _doctorsFuture = _loadDoctors();
    _searchController.addListener(_filterDoctors);
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      _searchController.text = widget.searchQuery!;
      _searchQuery = widget.searchQuery!;
    }
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

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _filterDoctors() {
    if (_allDoctors.isEmpty) return;
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchQuery = _searchController.text;
      _filteredDoctors = _allDoctors.where((doctor) {
        return doctor.name.toLowerCase().contains(query) || 
               doctor.specialty.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<List<Doctor>> _loadDoctors() async {
    try {
      final doctorsData = widget.specialty != null 
          ? await SupabaseService.getDoctorsBySpecialty(widget.specialty!)
          : await SupabaseService.getDoctors();
      final doctors = doctorsData.map((data) => Doctor.fromJson(data)).toList();
      _allDoctors = doctors;
      // Jika ada searchQuery, langsung filter _filteredDoctors
      final query = _searchController.text.trim().toLowerCase();
      if (query.isNotEmpty) {
        _filteredDoctors = doctors.where((doctor) {
          return doctor.name.toLowerCase().contains(query) ||
                 doctor.specialty.toLowerCase().contains(query);
        }).toList();
      } else {
        _filteredDoctors = doctors;
      }
      return doctors;
    } catch (e) {
      // Jika error, kembalikan list kosong saja (tanpa dummy)
      _allDoctors = [];
      _filteredDoctors = [];
      return [];
    }
  }

  Future<void> _refreshDoctors() async {
    setState(() {
      _doctorsFuture = _loadDoctors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Hilangkan tombol back
        title: widget.specialty != null
            ? Text(
                '${widget.specialty} Doctors',
                style: GoogleFonts.poppins(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: width > 600 ? 22 : 18,
                ),
              )
            : null, // Hilangkan judul jika tidak ada specialty
        toolbarHeight: 0, // Hilangkan seluruh AppBar jika tidak ada specialty
      ),
      body: Stack(
        children: [
          // Enhanced gradient background with additional decorative circles (match HomeScreen)
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
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
              child: Container(
                height: width > 600 ? 220 : 160,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: width > 600 ? 16 : 8,
              right: width > 600 ? 16 : 8,
              top: 0,
              bottom: 0,
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: RefreshIndicator(
                onRefresh: _refreshDoctors,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: width > 1000 ? 900 : (width > 600 ? 700 : 500),
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Search bar
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width > 1000 ? 32 : (width > 600 ? 24 : 10),
                                  vertical: width > 600 ? 16 : 8,
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.search, color: AppColors.primaryColor, size: width > 1000 ? 32 : (width > 600 ? 28 : 20)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        decoration: InputDecoration(
                                          hintText: 'Search doctor, specialist... ',
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey[800],
                                          fontSize: width > 1000 ? 22 : (width > 600 ? 18 : 14),
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
                                        child: Icon(Icons.close, color: Colors.grey[500], size: width > 1000 ? 24 : 18),
                                      ),
                                  ],
                                ),
                              ),
                              if (widget.specialty != null)
                                SizedBox(height: width > 600 ? 20 : 8),
                              if (widget.specialty != null)
                                Row(
                                  children: [
                                    Icon(Icons.people_alt_rounded, color: AppColors.primaryColor, size: width > 600 ? 28 : 22),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${widget.specialty} Doctors',
                                      style: GoogleFonts.poppins(
                                        fontSize: width > 600 ? 20 : 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              if (widget.specialty != null)
                                SizedBox(height: width > 600 ? 20 : 12),
                              FutureBuilder<List<Doctor>>(
                                future: _doctorsFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(
                                      child: Text('Error: ${snapshot.error}'),
                                    );
                                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Center(
                                      child: Text('No doctors available'),
                                    );
                                  }
                                  final showList = _searchController.text.isEmpty ? _allDoctors : _filteredDoctors;
                                  if (showList.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.sentiment_dissatisfied, color: const Color.fromARGB(255, 255, 255, 255), size: 64),
                                          const SizedBox(height: 12),
                                          Text(
                                            'No doctors found',
                                            style: GoogleFonts.poppins(fontSize: 16, color: const Color.fromARGB(255, 255, 255, 255)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  if (width < 600) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: List.generate(showList.length, (index) {
                                        return Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Flexible(
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: DoctorCard(
                                                      doctor: showList[index],
                                                      isSmall: false,
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => DoctorDetailScreen(doctor: showList[index]),
                                                          ),
                                                        ).then((_) => setState(() {}));
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (index != showList.length - 1)
                                              const SizedBox(height: 12.0),
                                          ],
                                        );
                                      }),
                                    );
                                  } else {
                                    // Grid 3 kolom horizontal, jika lebih dari 3 maka ke bawah
                                    return Align(
                                      alignment: Alignment.topCenter,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 1300),
                                        child: GridView.builder(
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            childAspectRatio: 1.15,
                                            crossAxisSpacing: 32,
                                            mainAxisSpacing: 32,
                                          ),
                                          itemCount: showList.length,
                                          physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            final doctor = showList[index];
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
                                                    ).then((_) => setState(() {}));
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
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Floating Bottom Navigation Bar
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
                            currentIndex: 1,
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
                              if (index == 0) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
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
}

import 'package:flutter/material.dart';
import 'package:projek_ambw/services/auth_service.dart';
import 'package:projek_ambw/utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projek_ambw/screens/home_screen.dart';
import 'package:projek_ambw/screens/doctor_list_screen.dart';
import 'package:projek_ambw/models/auth_user.dart';
import 'package:projek_ambw/screens/login_screen.dart';

// Tambahan agar tidak error jika ScrollDirection tidak dikenali
const ScrollDirection_reverse = 'ScrollDirection.reverse';
const ScrollDirection_forward = 'ScrollDirection.forward';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showBottomNavBar = true;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Background gradient sama seperti Home
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
          // Curved white overlay
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = constraints.maxHeight;
                return SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenHeight,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width > 900 ? 0 : (width > 600 ? 12 : 16)),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: width > 1100 ? 1100 : double.infinity),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: width > 1100 ? 60 : (width > 900 ? 100 : (width > 600 ? 80 : 40))),
                              // Avatar & Name
                              Center(
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: width > 900 ? 56 : (width > 600 ? 48 : 44),
                                      backgroundColor: AppColors.primaryColor.withOpacity(0.15),
                                      // backgroundImage: _pickedImage != null ? FileImage(_pickedImage!) : (user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null),
                                      child: user?.photoUrl == null
                                          ? Text(
                                              (user?.name?.isNotEmpty ?? false) ? user!.name![0].toUpperCase() : 'U',
                                              style: GoogleFonts.poppins(
                                                color: AppColors.primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: width > 900 ? 40 : (width > 600 ? 36 : 32),
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      user?.name ?? '-',
                                      style: GoogleFonts.poppins(
                                        fontSize: width > 900 ? 28 : (width > 600 ? 22 : 20),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                              // Card: Info Ringkas
                              Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 2,
                                color: Colors.white,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: width > 600 ? 36 : 22, vertical: width > 600 ? 28 : 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.account_circle, color: AppColors.primaryColor, size: width > 600 ? 28 : 22),
                                          const SizedBox(width: 10),
                                          Text('Account Overview',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w700,
                                                fontSize: width > 600 ? 20 : 16,
                                                color: AppColors.primaryColor,
                                              )),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      _profileInfoRow(Icons.email_outlined, 'Email', user?.email ?? '-', width),
                                      const SizedBox(height: 10),
                                      _profileInfoRow(Icons.phone, 'No. HP', user?.noHp != null ? user!.noHp.toString() : '-', width),
                                      const SizedBox(height: 10),
                                      _profileInfoRow(Icons.wc, 'Gender', user?.gender ?? '-', width),
                                      const SizedBox(height: 10),
                                      _profileInfoRow(Icons.cake, 'Tanggal Lahir',
                                        user?.tanggalLahir != null
                                          ? '${user!.tanggalLahir!.day.toString().padLeft(2, '0')}-${user.tanggalLahir!.month.toString().padLeft(2, '0')}-${user.tanggalLahir!.year}'
                                          : '-', width),
                                      const SizedBox(height: 18),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primaryColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                padding: EdgeInsets.symmetric(vertical: width > 600 ? 16 : 12),
                                              ),
                                              icon: const Icon(Icons.edit, size: 20),
                                              label: Text('Edit', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: width > 600 ? 16 : 14)),
                                              onPressed: () {
                                                _showEditProfileDialog(context, user);
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red[600],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                padding: EdgeInsets.symmetric(vertical: width > 600 ? 16 : 12),
                                              ),
                                              icon: const Icon(Icons.delete_outline, size: 20),
                                              label: Text('Delete Account', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: width > 600 ? 16 : 14)),
                                              onPressed: () {
                                                _showDeleteAccountDialog(context);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Floating, responsive, hide-on-scroll bottom navbar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset: _showBottomNavBar ? Offset.zero : const Offset(0, 1),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showBottomNavBar ? 1 : 0,
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
                            currentIndex: 2,
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
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                                  (route) => false,
                                );
                              } else if (index == 1) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const DoctorListScreen()),
                                  (route) => false,
                                );
                              }
                              // index == 2 is current (Profile)
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

  void _showEditProfileDialog(BuildContext context, AppUser? user) async {
    final _formKey = GlobalKey<FormState>();
    String? email = user?.email;
    String? name = user?.name;
    String? gender = user?.gender;
    DateTime? tanggalLahir = user?.tanggalLahir;
    int? noHp = user?.noHp;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('Edit Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (context, setState) {
              final inputDecoration = (String label, IconData icon) => InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon, color: AppColors.primaryColor),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.15)),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              );
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Informasi Akun', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.primaryColor)),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: email,
                        decoration: inputDecoration('Email', Icons.email_outlined),
                        validator: (val) => val == null || val.isEmpty ? 'Email wajib diisi' : null,
                        onChanged: (val) => email = val,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        initialValue: name,
                        decoration: inputDecoration('Nama Lengkap', Icons.person_outline),
                        validator: (val) => val == null || val.isEmpty ? 'Nama wajib diisi' : null,
                        onChanged: (val) => name = val,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        initialValue: noHp != null ? noHp.toString() : '',
                        keyboardType: TextInputType.phone,
                        decoration: inputDecoration('No. HP', Icons.phone),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'No. HP wajib diisi';
                          if (int.tryParse(val) == null) return 'No. HP harus berupa angka';
                          return null;
                        },
                        onChanged: (val) => noHp = int.tryParse(val),
                      ),
                      const SizedBox(height: 26),
                      Text('Data Pribadi', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.primaryColor)),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: gender,
                        decoration: inputDecoration('Gender', Icons.wc),
                        items: const [
                          DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                          DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                        ],
                        onChanged: (val) => setState(() => gender = val),
                        validator: (val) => val == null || val.isEmpty ? 'Pilih gender' : null,
                        borderRadius: BorderRadius.circular(12),
                        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
                        icon: const Icon(Icons.arrow_drop_down),
                      ),
                      const SizedBox(height: 18),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: tanggalLahir ?? DateTime(2000, 1, 1),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: AppColors.primaryColor,
                                    onPrimary: Colors.white,
                                    onSurface: AppColors.textPrimary,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) setState(() => tanggalLahir = picked);
                        },
                        child: InputDecorator(
                          decoration: inputDecoration('Tanggal Lahir', Icons.cake),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                tanggalLahir != null
                                  ? '${tanggalLahir!.day.toString().padLeft(2, '0')}-${tanggalLahir!.month.toString().padLeft(2, '0')}-${tanggalLahir!.year}'
                                  : 'Pilih tanggal',
                                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
                              ),
                              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate() && tanggalLahir != null) {
                        await AuthService.updateUserProfile(
                          email: email,
                          name: name,
                          noHp: noHp,
                          gender: gender,
                          tanggalLahir: tanggalLahir,
                        );
                        Navigator.pop(context);
                        setState(() {}); // Refresh tampilan
                      }
                    },
                    child: Text('Simpan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Hapus Akun', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus akun ini? Tindakan ini tidak dapat dibatalkan.', style: GoogleFonts.poppins()),
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
                  child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
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
                    try {
                      await AuthService.deleteAccount(context);
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    } catch (_) {
                      // Sudah ada SnackBar di AuthService
                    }
                  },
                  child: Text('Hapus', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileInfoRow(IconData icon, String label, String value, double width) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryColor, size: width > 600 ? 22 : 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: width > 600 ? 14 : 12, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(value, style: GoogleFonts.poppins(fontSize: width > 600 ? 16 : 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
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

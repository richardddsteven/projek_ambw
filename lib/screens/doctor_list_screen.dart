import 'package:flutter/material.dart';
import 'package:projek_ambw/models/doctor.dart';
import 'package:projek_ambw/services/supabase_service.dart';
import 'package:projek_ambw/utils/app_theme.dart';
import 'package:projek_ambw/widgets/doctor_card.dart';
import 'package:projek_ambw/screens/doctor_detail_screen.dart';

class DoctorListScreen extends StatefulWidget {
  final String? specialty;
  
  const DoctorListScreen({Key? key, this.specialty}) : super(key: key);

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  late Future<List<Doctor>> _doctorsFuture;
  
  @override
  void initState() {
    super.initState();
    _doctorsFuture = _loadDoctors();
  }
  
  Future<List<Doctor>> _loadDoctors() async {
    try {
      final doctorsData = widget.specialty != null 
          ? await SupabaseService.getDoctorsBySpecialty(widget.specialty!)
          : await SupabaseService.getDoctors();
          
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
        Doctor(
          id: '4',
          name: 'Sarah Johnson',
          specialty: 'Pulmonologist',
          photoUrl: 'https://randomuser.me/api/portraits/women/45.jpg',
          experience: 9,
          about: 'Pulmonologist specializing in respiratory disorders and sleep medicine.',
          rating: 4.7,
        ),
      ].where((doctor) => widget.specialty == null || doctor.specialty == widget.specialty).toList();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(widget.specialty != null ? '${widget.specialty} Doctors' : 'All Doctors'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const Text(
              'Available Doctors',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Doctor>>(
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
                  
                  final doctors = snapshot.data!;
                  
                  return ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      return DoctorCard(
                        doctor: doctors[index],
                        isSmall: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorDetailScreen(
                                doctor: doctors[index],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

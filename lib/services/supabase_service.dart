import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Doctor methods
  static Future<List<Map<String, dynamic>>> getDoctors() async {
    final response = await _client.from('doctors').select();
    return response;
  }
  
  static Future<List<Map<String, dynamic>>> getDoctorsBySpecialty(String specialty) async {
    final response = await _client.from('doctors').select().eq('specialty', specialty);
    return response;
  }
  
  static Future<Map<String, dynamic>> getDoctorById(String id) async {
    final response = await _client.from('doctors').select().eq('id', id).single();
    return response;
  }
  
  // Appointment methods
  static Future<List<Map<String, dynamic>>> getUserAppointments(String userId) async {
    final response = await _client
        .from('appointments')
        .select('*, doctors(*)')
        .eq('user_id', userId)
        .order('appointment_date', ascending: true);
    return response;
  }
    static Future<String> createAppointment({
    required String userId,
    required String doctorId,
    required DateTime appointmentDate,
    required String type,
    String? notes,
  }) async {
    try {
      // Make sure userId and doctorId are valid UUIDs
      if (userId.isEmpty || doctorId.isEmpty) {
        throw Exception('User ID and Doctor ID must be valid UUIDs');
      }
      
      final response = await _client.from('appointments').insert({
        'user_id': userId,
        'doctor_id': doctorId,
        'appointment_date': appointmentDate.toIso8601String(),
        'type': type,
        'notes': notes,
        'status': 'scheduled',
      }).select('id').single();
      
      return response['id'] as String;
    } catch (e) {
      print('Error creating appointment: $e');
      rethrow; // Re-throw to allow handling in the UI
    }
  }
  
  static Future<void> cancelAppointment(String appointmentId) async {
    await _client
        .from('appointments')
        .update({'status': 'cancelled'})
        .eq('id', appointmentId);
  }
  
  // User methods
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user != null) {
      final response = await _client.from('users').select().eq('id', user.id).single();
      return response;
    }
    return null;
  }
  
  static Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _client.from('users').update(data).eq('id', userId);
  }
}

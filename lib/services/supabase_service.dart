import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart'; // Add this for TimeOfDay

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
  
  static Future<List<Map<String, dynamic>>> searchDoctors(String query) async {
    final response = await _client
        .from('doctors')
        .select()
        .or('name.ilike.%$query%,specialty.ilike.%$query%');
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

  // Check if a doctor is already booked at a specific time
  static Future<bool> isDoctorBooked({
    required String doctorId, 
    required DateTime appointmentDate
  }) async {
    try {
      // Create time range with 1 hour buffer (appointment duration)
      final startTime = appointmentDate.subtract(const Duration(minutes: 59));
      final endTime = appointmentDate.add(const Duration(minutes: 59));
      
      // Query for existing appointments for this doctor in the time window
      final response = await _client
          .from('appointments')
          .select('id')
          .eq('doctor_id', doctorId)
          .gte('appointment_date', startTime.toIso8601String())
          .lte('appointment_date', endTime.toIso8601String())
          .neq('status', 'cancelled')
          .limit(1);
      
      // If we get any results, the doctor is already booked
      return response.isNotEmpty;
    } catch (e) {
      print('Error checking doctor availability: $e');
      return false; // Default to allowing booking if check fails
    }
  }

  // Get unavailable time slots for a doctor on a specific date
  static Future<List<TimeOfDay>> getUnavailableTimeSlots({
    required String doctorId,
    required DateTime date,
    required List<TimeOfDay> allTimeSlots
  }) async {
    try {
      // Strip the time component to get just the date
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      // Get all appointments for this doctor on this day
      final response = await _client
          .from('appointments')
          .select('appointment_date')
          .eq('doctor_id', doctorId)
          .gte('appointment_date', startOfDay.toIso8601String())
          .lt('appointment_date', endOfDay.toIso8601String())
          .neq('status', 'cancelled');
      
      // Convert the appointment times to TimeOfDay objects
      List<TimeOfDay> bookedSlots = [];
      for (var appointment in response) {
        final appointmentTime = DateTime.parse(appointment['appointment_date']);
        bookedSlots.add(TimeOfDay(hour: appointmentTime.hour, minute: appointmentTime.minute));
      }
      
      return bookedSlots;
    } catch (e) {
      print('Error getting unavailable time slots: $e');
      return []; // Return empty list if check fails
    }
  }
}

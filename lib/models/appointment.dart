import 'package:projek_ambw/models/doctor.dart';

class Appointment {
  final String id;
  final String userId;
  final Doctor doctor;
  final DateTime appointmentDate;
  final String type;
  final String status;
  final String? notes;
  
  Appointment({
    required this.id,
    required this.userId,
    required this.doctor,
    required this.appointmentDate,
    required this.type,
    required this.status,
    this.notes,
  });
  
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      userId: json['user_id'],
      doctor: Doctor.fromJson(json['doctors']),
      appointmentDate: DateTime.parse(json['appointment_date']),
      type: json['type'],
      status: json['status'],
      notes: json['notes'],
    );
  }
}

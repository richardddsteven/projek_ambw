import 'package:flutter/material.dart';
import 'package:projek_ambw/models/appointment.dart';
import 'package:projek_ambw/utils/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    this.onTap,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isUpcoming = appointment.appointmentDate.isAfter(DateTime.now());
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isUpcoming ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: CachedNetworkImage(
                      imageUrl: appointment.doctor.photoUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.person),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. ${appointment.doctor.name}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isUpcoming ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${appointment.type} Consultation',
                          style: TextStyle(
                            fontSize: 14,
                            color: isUpcoming ? Colors.white.withOpacity(0.9) : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUpcoming ? AppColors.primaryColor.withOpacity(0.9) : Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: isUpcoming ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('E, d MMM yyyy').format(appointment.appointmentDate),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isUpcoming ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: isUpcoming ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('hh:mm a').format(appointment.appointmentDate),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isUpcoming ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  if (isUpcoming && appointment.status != 'cancelled' && onCancel != null)
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: onCancel,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

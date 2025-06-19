import 'package:flutter/material.dart';
import 'package:projek_ambw/utils/app_theme.dart';

class SpecialtyCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final Color backgroundColor;
  final VoidCallback onTap;

  const SpecialtyCard({
    Key? key,
    required this.title,
    required this.iconPath,
    required this.backgroundColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  iconPath,
                  width: 28,
                  height: 28,
                  color: backgroundColor == AppColors.neurologistColor
                      ? Colors.red[300]
                      : backgroundColor == AppColors.cardiologistColor
                          ? Colors.blue[300]
                          : backgroundColor == AppColors.orthopedistColor
                              ? Colors.orange[300]
                              : Colors.purple[300],
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      title == 'Neurologist'
                          ? Icons.psychology
                          : title == 'Cardiologist'
                              ? Icons.favorite
                              : title == 'Orthopedist'
                                  ? Icons.wheelchair_pickup
                                  : Icons.healing,
                      size: 24,
                      color: backgroundColor == AppColors.neurologistColor
                          ? Colors.red[300]
                          : backgroundColor == AppColors.cardiologistColor
                              ? Colors.blue[300]
                              : backgroundColor == AppColors.orthopedistColor
                                  ? Colors.orange[300]
                                  : Colors.purple[300],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:projek_ambw/utils/app_theme.dart';

class SpecialtyCard extends StatelessWidget {
  final String title;
  final String iconPath; // tetap gunakan nama ini untuk kompatibilitas
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
    bool isNetwork = iconPath.startsWith('http');
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
              height: (32) * 1.6,
              width: (32) * 1.6,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isNetwork
                    ? Image.network(
                        iconPath,
                        width: 28,
                        height: 28,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 28),
                      )
                    : Builder(
                        builder: (context) {
                          if (iconPath.endsWith('.svg')) {
                            return SvgPicture.asset(
                              iconPath,
                              width: 28,
                              height: 28,
                              color: null,
                              placeholderBuilder: (context) => const SizedBox.shrink(),
                            );
                          } else {
                            return Image.asset(
                              iconPath,
                              width: 28,
                              height: 28,
                              color: null,
                              errorBuilder: (context, error, stackTrace) {
                                return SvgPicture.asset(
                                  'assets/icons/heart.svg',
                                  width: 28,
                                  height: 28,
                                );
                              },
                            );
                          }
                        },
                      ),
              ),
            ),
            const SizedBox(height: 8),
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

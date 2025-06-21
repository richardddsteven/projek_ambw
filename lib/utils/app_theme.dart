import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- AppColors (Tidak ada perubahan, sudah bagus) ---
class AppColors {
  static const primaryColor = Color(0xFF2563EB); // Biru elegan
  static const accentColor = Color(0xFF60A5FA); // Biru muda
  static const backgroundColor = Color(0xFFF5F8FA); // Putih modern
  static const cardColor = Colors.white;
  static const textPrimary = Color(0xFF1E293B); // Biru gelap untuk teks utama
  static const textSecondary = Color(0xFF64748B); // Abu kebiruan
  static const textTertiary = Color(0xFF94A3B8); // Abu terang
  static const errorColor = Color(0xFFE53935);
  static const successColor = Color(0xFF43A047);

  // Warna untuk spesialisasi
  static const neurologistColor = Color(0xFFFFC2C2); // Merah muda untuk ikon otak
  static const cardiologistColor = Color(0xFFC2E8FF); // Biru muda untuk ikon hati
  static const orthopedistColor = Color(0xFFFFE2C2); // Oranye muda untuk ikon tulang
  static const pulmonologistColor = Color(0xFFD1C2FF); // Ungu muda untuk ikon paru-paru

  // Warna untuk spesialisasi baru
  static const pediatricianColor = Color(0xFFC2FFD6); // Hijau muda untuk pediatrician
  static const ophthalmologistColor = Color(0xFFC2F0FF); // Biru kehijauan muda untuk ophthalmologist
  static const dermatologistColor = Color(0xFFFFE0F0); // Peach/pink muda untuk dermatologist
}

// --- AppTheme (Diperbarui dan Disempurnakan) ---
class AppTheme {
  static ThemeData get theme {
    // Mengambil dasar tema teks dari Google Fonts (Inter)
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      // --- Properti Utama & Skema Warna ---
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryColor,
        onPrimary: Colors.white, // Warna teks di atas warna primer
        secondary: AppColors.accentColor,
        onSecondary: Colors.white,
        error: AppColors.errorColor,
        onError: Colors.white,
        background: AppColors.backgroundColor,
        onBackground: AppColors.textPrimary,
        surface: AppColors.cardColor, // Warna untuk Card, Dialog, BottomSheet
        onSurface: AppColors.textPrimary,
      ),

      // --- Tema Teks dengan Hirarki yang Jelas ---
      textTheme: baseTextTheme.copyWith(
        // Untuk judul besar seperti di halaman utama
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        // Untuk judul halaman
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        // Untuk judul di dalam card atau bagian
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        // Teks utama aplikasi
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 16,
          color: AppColors.textSecondary,
        ),
        // Teks sekunder yang lebih kecil
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        // Untuk label pada input form
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ).apply(
        bodyColor: AppColors.textSecondary,
        displayColor: AppColors.textPrimary,
      ),

      // --- Tema untuk Komponen Spesifik ---
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundColor, // Sama dengan background scaffold
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primaryColor), // Ikon AppBar
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54), // Sedikit lebih tinggi
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Radius lebih besar
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 2, // Memberi sedikit bayangan saat aktif
          shadowColor: AppColors.primaryColor.withOpacity(0.2),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          minimumSize: const Size(double.infinity, 54),
          side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      cardTheme: CardTheme(
        // Hanya satu deklarasi shape, gunakan yang ada border
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.accentColor.withOpacity(0.08), width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        color: AppColors.cardColor,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        // Border saat tidak aktif (enabled)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.accentColor.withOpacity(0.15), width: 1.5), // Border halus
        ),
        // Border saat aktif (focused)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        // Menghilangkan border standar
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardColor,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textTertiary,
        showSelectedLabels: true,
        showUnselectedLabels: false, // Hanya tampilkan label item yang aktif
        type: BottomNavigationBarType.fixed,
        elevation: 0, // Hapus shadow bawaan
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 12),
      ),
    );
  }
}
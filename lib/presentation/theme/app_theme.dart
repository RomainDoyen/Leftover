import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTheme {
  static ThemeData get light {
    final base = ThemeData(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary:              AppColors.primary,
        onPrimary:            AppColors.onPrimary,
        primaryContainer:     AppColors.primaryContainer,
        onPrimaryContainer:   Color(0xFF470E00),
        secondary:            AppColors.secondary,
        onSecondary:          AppColors.onSecondary,
        secondaryContainer:   AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary:             AppColors.tertiary,
        onTertiary:           Color(0xFFFFEDFD),
        error:                AppColors.error,
        onError:              Color(0xFFFFEFEE),
        surface:              AppColors.surface,
        onSurface:            AppColors.onSurface,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge:   GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 40),
        displayMedium:  GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 32),
        headlineLarge:  GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 28),
        headlineMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 22),
        headlineSmall:  GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 18),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(0xFFFFE8DF),
      ),
    );
  }
}

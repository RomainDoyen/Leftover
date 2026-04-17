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
        onPrimaryContainer:   AppColors.onPrimaryContainer,
        secondary:            AppColors.secondary,
        onSecondary:          AppColors.onSecondary,
        secondaryContainer:   AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary:             AppColors.tertiary,
        onTertiary:           AppColors.onTertiary,
        tertiaryContainer:    AppColors.tertiaryContainer,
        onTertiaryContainer:  AppColors.onTertiaryContainer,
        error:                AppColors.error,
        onError:              AppColors.onError,
        surface:              AppColors.surface,
        onSurface:            AppColors.onSurface,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge:   GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 40, color: AppColors.onSurface),
        displayMedium:  GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 32, color: AppColors.onSurface),
        headlineLarge:  GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 28, color: AppColors.onSurface),
        headlineMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 22, color: AppColors.onSurface),
        headlineSmall:  GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.onSurface),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceContainerLowest,
        foregroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        indicatorColor: AppColors.navigationIndicator,
      ),
    );
  }
}

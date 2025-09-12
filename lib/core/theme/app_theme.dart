import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pavo_flutter/core/theme/app_colors.dart';

class AppTheme {
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    textTheme: GoogleFonts.spaceGroteskTextTheme(),
    
    // Color scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      surface: AppColors.lightBg,
      surfaceContainerHighest: AppColors.lightBgLight,
      surfaceContainerHigh: AppColors.lightBgSubtle,
      surfaceContainerLow: AppColors.lightBgDark,
      onSurface: AppColors.lightText,
      onSurfaceVariant: AppColors.lightTextMuted,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightBorderMuted,
      error: AppColors.danger,
    ),
    
    // Scaffold background
    scaffoldBackgroundColor: AppColors.lightBg,
    
    // AppBar theme
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.lightText,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    
    // Card theme
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.lightBgLight.withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        side: BorderSide(
          color: AppColors.lightBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
    ),
    
    // Navigation bar theme
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 80,
      backgroundColor: AppColors.lightBgLight.withValues(alpha: 0.95),
      indicatorColor: AppColors.lightPrimary,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Colors.white, size: 24);
        }
        return const IconThemeData(color: AppColors.lightTextMuted, size: 24);
      }),
    ),
    
    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
    ),
    
    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightBgLight.withValues(alpha: 0.5),
      selectedColor: AppColors.lightPrimary.withValues(alpha: 0.2),
      labelStyle: const TextStyle(color: AppColors.lightText),
      checkmarkColor: AppColors.lightPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
        side: BorderSide(color: AppColors.lightBorder.withValues(alpha: 0.3)),
      ),
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightBgLight.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
        borderSide: BorderSide(color: AppColors.lightBorder.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
        borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme),
    
    // Color scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      surface: AppColors.darkBg,
      surfaceContainerHighest: AppColors.darkBgLight,
      surfaceContainerHigh: AppColors.darkBgSubtle,
      surfaceContainerLow: AppColors.darkBgDark,
      onSurface: AppColors.darkText,
      onSurfaceVariant: AppColors.darkTextMuted,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkBorderMuted,
      error: AppColors.danger,
    ),
    
    // Scaffold background
    scaffoldBackgroundColor: AppColors.darkBg,
    
    // AppBar theme
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.darkText,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    
    // Card theme
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.darkBgLight.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        side: BorderSide(
          color: AppColors.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
    ),
    
    // Navigation bar theme
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      height: 80,
      backgroundColor: AppColors.darkBgLight.withValues(alpha: 0.95),
      indicatorColor: AppColors.darkPrimary.withValues(alpha: 0.2),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.darkPrimary, size: 24);
        }
        return const IconThemeData(color: AppColors.darkTextMuted, size: 24);
      }),
    ),
    
    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
    ),
    
    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkBgLight.withValues(alpha: 0.3),
      selectedColor: AppColors.darkPrimary.withValues(alpha: 0.2),
      labelStyle: const TextStyle(color: AppColors.darkText),
      checkmarkColor: AppColors.darkPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
        side: BorderSide(color: AppColors.darkBorder.withValues(alpha: 0.3)),
      ),
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkBgLight.withValues(alpha: 0.3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
        borderSide: BorderSide(color: AppColors.darkBorder.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
      ),
    ),
  );
}
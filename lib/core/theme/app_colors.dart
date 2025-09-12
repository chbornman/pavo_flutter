import 'package:flutter/material.dart';

class AppColors {
  // Light mode colors - warm tan/cream palette
  static const lightBgDark = Color(0xFFE8E2D5);     // oklch(0.9 0.025 100) - warm tan
  static const lightBg = Color(0xFFF2EDE5);         // oklch(0.95 0.025 100) - cream
  static const lightBgLight = Color(0xFFFAF8F3);    // oklch(0.98 0.025 100) - light cream
  static const lightBgSubtle = Color(0xFFEBE5D9);   // oklch(0.92 0.025 100) - subtle tan
  
  static const lightText = Color(0xFF1A1815);       // oklch(0.15 0.05 100) - warm black
  static const lightTextMuted = Color(0xFF4D4840);  // oklch(0.35 0.05 100) - warm gray
  
  static const lightHighlight = Color(0xFF73685C);   // oklch(0.5 0.05 100) - warm medium
  static const lightBorder = Color(0xFFCCC2B3);     // oklch(0.8 0.05 100) - warm border
  static const lightBorderMuted = Color(0xFFD9D1C4); // oklch(0.85 0.05 100) - warm muted border
  
  static const lightPrimary = Color(0xFF73685C);     // warm tan accent color
  static const lightSecondary = Color(0xFF9B59B6);   // oklch(0.76 0.1 280) - purple
  
  // Dark mode colors - warm dark palette
  static const darkBgDark = Color(0xFF0A0908);      // oklch(0.1 0.025 100) - warm black
  static const darkBg = Color(0xFF14120F);          // oklch(0.15 0.025 100) - warm dark
  static const darkBgLight = Color(0xFF1F1C17);     // oklch(0.2 0.025 100) - warm dark light
  static const darkBgSubtle = Color(0xFF1A1714);    // oklch(0.18 0.025 100) - warm dark subtle
  
  static const darkText = Color(0xFFF5F2ED);        // oklch(0.96 0.05 100) - warm white
  static const darkTextMuted = Color(0xFFB3A696);   // oklch(0.76 0.05 100) - warm muted
  
  static const darkHighlight = Color(0xFF73685C);    // oklch(0.5 0.05 100) - warm medium
  static const darkBorder = Color(0xFF403A30);      // oklch(0.3 0.05 100) - warm border
  static const darkBorderMuted = Color(0xFF332E26);  // oklch(0.25 0.05 100) - warm muted border
  
  static const darkPrimary = Color(0xFFE8D5C4);      // warm cream for dark mode
  static const darkSecondary = Color(0xFF9B59B6);    // oklch(0.76 0.1 280) - purple
  
  // Semantic colors (same for both themes)
  static const danger = Color(0xFFE74C3C);          // oklch(0.7 0.05 30) - red
  static const warning = Color(0xFFF39C12);         // oklch(0.7 0.05 100) - yellow
  static const success = Color(0xFF27AE60);         // oklch(0.7 0.05 160) - green
  static const info = Color(0xFF3498DB);            // oklch(0.7 0.05 260) - blue
}
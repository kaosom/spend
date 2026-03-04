import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for Avid Spend - Light, clean, minimalist theme
class AvidTokens {
  // Font Family - Modern, futuristic font
  static const String fontFamily = 'Space Grotesk';

  // Colors - Light theme with clean surfaces
  static const Color backgroundPrimary = Color(
    0xFFF3F4F6,
  ); // Light gray background
  static const Color backgroundSecondary = Color(
    0xFFFFFFFF,
  ); // White surface (Cards)
  static const Color backgroundTertiary = Color(
    0xFFF9FAFB,
  ); // Slightly off-white
  static const Color backgroundGradientStart = Color(0xFFF3F4F6);
  static const Color backgroundGradientEnd = Color(0xFFFFFFFF);

  // Accent colors matching the specific UI
  static const Color accentPrimary = Color(
    0xFF1F1F1F,
  ); // Dark grey/black for main actions
  static const Color accentSecondary = Color(
    0xFF8B5CF6,
  ); // Purple (mostly unused but kept for compatibility)
  static const Color accentSuccess = Color(0xFF76D1A2); // Pastel Green (Income)
  static const Color accentWarning = Color(0xFFF59E0B); // Amber
  static const Color accentError = Color(
    0xFFF48C9E,
  ); // Pastel Red/Pink (Expenses)

  // Specific grey accents
  static const Color accentGrey = Color(0xFFE5E7EB); // Progress bar grey

  // Text colors
  static const Color textPrimary = Color(0xFF111827); // Near-black
  static const Color textSecondary = Color(0xFF6B7280); // Gray text
  static const Color textTertiary = Color(0xFF9CA3AF); // Lighter gray text
  static const Color textDisabled = Color(0xFFD1D5DB); // Disabled text

  // Border colors
  static const Color borderPrimary = Color(0xFFE5E7EB); // Subtle borders
  static const Color borderSecondary = Color(0xFFF3F4F6); // Lighter borders
  static const Color borderActive = Color(0xFF1F1F1F); // Active/accent borders

  // Shadows
  static const Color shadowColor = Color(0x1F000000); // 12% black

  // Spacing scale (4px base)
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;
  static const double space12 = 48;
  static const double space16 = 64;

  // Border radius
  static const double radiusSmall = 8;
  static const double radiusMedium = 16;
  static const double radiusLarge = 24;
  static const double radiusExtraLarge = 32;
  static const double radiusRound = 999;

  // Typography - Modern Google Font (Space Grotesk)
  static TextStyle get heading1 => GoogleFonts.spaceGrotesk(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: textPrimary,
    letterSpacing: -1,
  );

  static TextStyle get heading2 => GoogleFonts.spaceGrotesk(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: textPrimary,
    letterSpacing: -0.75,
  );

  static TextStyle get heading3 => GoogleFonts.spaceGrotesk(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get heading4 => GoogleFonts.spaceGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: textPrimary,
    letterSpacing: -0.25,
  );

  static TextStyle get bodyLarge => GoogleFonts.spaceGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: textPrimary,
    letterSpacing: 0,
  );

  static TextStyle get bodyMedium => GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: textSecondary,
    letterSpacing: 0,
  );

  static TextStyle get bodySmall => GoogleFonts.spaceGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: textTertiary,
    letterSpacing: 0.1,
  );

  static TextStyle get labelLarge => GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static TextStyle get labelMedium => GoogleFonts.spaceGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: textSecondary,
    letterSpacing: 0.5,
  );

  static TextStyle get labelSmall => GoogleFonts.spaceGrotesk(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: textTertiary,
    letterSpacing: 0.5,
  );

  // Animation durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 200);
  static const Duration durationSlow = Duration(milliseconds: 300);

  // Box shadows
  static const List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Color(0x0A000000), // Very light shadow
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0x0F000000), // Light shadow
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowLarge = [
    BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, 8)),
  ];

  // Colors for glassmorphism
  static BoxDecoration get glassCard => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AvidTokens.radiusLarge),
    border: Border.all(color: AvidTokens.borderPrimary, width: 1),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 10,
        spreadRadius: 0,
        offset: Offset(0, 4),
      ),
    ],
  );

  static List<BoxShadow> get shadowGlow => shadowMedium;
  static List<BoxShadow> get shadowGlowSubtle => shadowSmall;
  static List<BoxShadow> get shadowCard => shadowMedium;

  // Gradients for backwards compatibility (light mode versions)
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [accentPrimary, accentPrimary],
  );

  static const LinearGradient gradientSuccess = LinearGradient(
    colors: [accentSuccess, accentSuccess],
  );

  static const LinearGradient gradientCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundSecondary, backgroundTertiary],
  );

  static const Color glowPrimary = Color(0x1F000000);
}

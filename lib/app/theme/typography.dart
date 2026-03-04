import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

/// Typography system for Avid Spend - Modular and reusable
/// Uses Space Grotesk for a modern, futuristic look
class AvidTypography {
  AvidTypography._();

  /// Base font family
  static const String fontFamily = 'Space Grotesk';

  /// Get text style with optional color override
  static TextStyle _baseStyle({
    required double fontSize,
    required FontWeight fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  /// Heading 1 - Large titles
  static TextStyle heading1({Color? color}) => _baseStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -1,
        color: color ?? AvidTokens.textPrimary,
      );

  /// Heading 2 - Section titles
  static TextStyle heading2({Color? color}) => _baseStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.75,
        color: color ?? AvidTokens.textPrimary,
      );

  /// Heading 3 - Subsection titles
  static TextStyle heading3({Color? color}) => _baseStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.5,
        color: color ?? AvidTokens.textPrimary,
      );

  /// Heading 4 - Small titles
  static TextStyle heading4({Color? color}) => _baseStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: -0.25,
        color: color ?? AvidTokens.textPrimary,
      );

  /// Body Large - Main content
  static TextStyle bodyLarge({Color? color}) => _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
        color: color ?? AvidTokens.textPrimary,
      );

  /// Body Medium - Secondary content
  static TextStyle bodyMedium({Color? color}) => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
        color: color ?? AvidTokens.textSecondary,
      );

  /// Body Small - Tertiary content
  static TextStyle bodySmall({Color? color}) => _baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.1,
        color: color ?? AvidTokens.textTertiary,
      );

  /// Label Large - Button text, important labels
  static TextStyle labelLarge({Color? color}) => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.5,
        color: color ?? AvidTokens.textPrimary,
      );

  /// Label Medium - Medium labels
  static TextStyle labelMedium({Color? color}) => _baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.5,
        color: color ?? AvidTokens.textSecondary,
      );

  /// Label Small - Small labels
  static TextStyle labelSmall({Color? color}) => _baseStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.5,
        color: color ?? AvidTokens.textTertiary,
      );

  /// Display - Large display text with gradient support
  static TextStyle display({Color? color}) => _baseStyle(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -2,
        color: color ?? AvidTokens.textPrimary,
      );
}

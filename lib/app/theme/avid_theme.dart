import 'package:flutter/material.dart';
import 'tokens.dart';
import 'typography.dart';

/// Avid Spend Theme - Dark, minimalist, futuristic
class AvidTheme {
  static ThemeData get theme {
    return ThemeData(
      // Use Material 3
      useMaterial3: true,

      // Color scheme
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AvidTokens.accentPrimary,
        onPrimary: AvidTokens.textPrimary,
        primaryContainer: AvidTokens.backgroundTertiary,
        onPrimaryContainer: AvidTokens.textPrimary,
        secondary: AvidTokens.accentSecondary,
        onSecondary: AvidTokens.textPrimary,
        secondaryContainer: AvidTokens.backgroundSecondary,
        onSecondaryContainer: AvidTokens.textSecondary,
        tertiary: AvidTokens.accentSuccess,
        onTertiary: AvidTokens.textPrimary,
        tertiaryContainer: AvidTokens.backgroundSecondary,
        onTertiaryContainer: AvidTokens.textSecondary,
        error: AvidTokens.accentError,
        onError: AvidTokens.textPrimary,
        errorContainer: Color(0xFF451A1A),
        onErrorContainer: AvidTokens.textPrimary,
        surface: AvidTokens.backgroundSecondary,
        onSurface: AvidTokens.textPrimary,
        surfaceContainerHighest: AvidTokens.backgroundTertiary,
        onSurfaceVariant: AvidTokens.textSecondary,
        outline: AvidTokens.borderPrimary,
        outlineVariant: AvidTokens.borderSecondary,
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: AvidTokens.textPrimary,
        onInverseSurface: AvidTokens.backgroundPrimary,
        inversePrimary: AvidTokens.accentPrimary,
        surfaceTint: AvidTokens.accentPrimary,
      ),

      // Scaffold background
      scaffoldBackgroundColor: AvidTokens.backgroundPrimary,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AvidTokens.backgroundPrimary,
        foregroundColor: AvidTokens.textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AvidTokens.heading3,
        toolbarTextStyle: AvidTokens.bodyMedium,
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AvidTokens.backgroundSecondary,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AvidTokens.radiusMedium),
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AvidTokens.accentPrimary,
          foregroundColor: AvidTokens.textPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AvidTokens.space4,
            vertical: AvidTokens.space3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AvidTokens.radiusMedium),
          ),
          textStyle: AvidTokens.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AvidTokens.accentPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AvidTokens.space4,
            vertical: AvidTokens.space3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AvidTokens.radiusMedium),
          ),
          textStyle: AvidTokens.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AvidTokens.textPrimary,
          side: const BorderSide(color: AvidTokens.borderPrimary),
          padding: const EdgeInsets.symmetric(
            horizontal: AvidTokens.space4,
            vertical: AvidTokens.space3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AvidTokens.radiusMedium),
          ),
          textStyle: AvidTokens.labelLarge,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AvidTokens.backgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AvidTokens.radiusMedium),
          borderSide: const BorderSide(color: AvidTokens.borderPrimary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AvidTokens.radiusMedium),
          borderSide: const BorderSide(color: AvidTokens.borderPrimary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AvidTokens.radiusMedium),
          borderSide: const BorderSide(color: AvidTokens.borderActive),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AvidTokens.radiusMedium),
          borderSide: const BorderSide(color: AvidTokens.accentError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AvidTokens.radiusMedium),
          borderSide: const BorderSide(color: AvidTokens.accentError),
        ),
        labelStyle: AvidTokens.bodyMedium.copyWith(
          color: AvidTokens.textSecondary,
        ),
        hintStyle: AvidTokens.bodyMedium.copyWith(
          color: AvidTokens.textTertiary,
        ),
        errorStyle: AvidTokens.bodySmall.copyWith(
          color: AvidTokens.accentError,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AvidTokens.space4,
          vertical: AvidTokens.space3,
        ),
      ),

      // Text theme - Using modular typography
      textTheme: TextTheme(
        displayLarge: AvidTypography.heading1(),
        displayMedium: AvidTypography.heading2(),
        displaySmall: AvidTypography.heading3(),
        headlineLarge: AvidTypography.heading2(),
        headlineMedium: AvidTypography.heading3(),
        headlineSmall: AvidTypography.heading4(),
        titleLarge: AvidTypography.bodyLarge(),
        titleMedium: AvidTypography.bodyMedium(),
        titleSmall: AvidTypography.bodySmall(),
        bodyLarge: AvidTypography.bodyLarge(),
        bodyMedium: AvidTypography.bodyMedium(),
        bodySmall: AvidTypography.bodySmall(),
        labelLarge: AvidTypography.labelLarge(),
        labelMedium: AvidTypography.labelMedium(),
        labelSmall: AvidTypography.labelSmall(),
      ),

      // Tab bar theme
      tabBarTheme: const TabBarThemeData(
        indicatorColor: AvidTokens.accentPrimary,
        labelColor: AvidTokens.accentPrimary,
        unselectedLabelColor: AvidTokens.textSecondary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AvidTokens.backgroundSecondary,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AvidTokens.radiusLarge),
          ),
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AvidTokens.backgroundSecondary,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AvidTokens.radiusLarge),
          ),
        ),
      ),

      // SnackBar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AvidTokens.backgroundTertiary,
        contentTextStyle: AvidTokens.bodyMedium,
        actionTextColor: AvidTokens.accentPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AvidTokens.radiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AvidTokens.borderPrimary,
        thickness: 1,
        space: 0,
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: AvidTokens.textPrimary, size: 24),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AvidTokens.backgroundTertiary,
        selectedColor: AvidTokens.accentPrimary,
        checkmarkColor: AvidTokens.textPrimary,
        deleteIconColor: AvidTokens.textSecondary,
        labelStyle: AvidTokens.labelMedium,
        secondaryLabelStyle: AvidTokens.labelMedium,
        brightness: Brightness.dark,
        padding: const EdgeInsets.symmetric(
          horizontal: AvidTokens.space3,
          vertical: AvidTokens.space2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AvidTokens.radiusSmall),
        ),
      ),
    );
  }
}

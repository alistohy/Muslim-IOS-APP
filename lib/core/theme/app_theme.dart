import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// AppColors
// ---------------------------------------------------------------------------

class AppColors {
  AppColors._();

  // Dark palette
  static const Color darkBg         = Color(0xFF0A0E1A);
  static const Color darkCard       = Color(0xFF131929);
  static const Color darkCardBorder = Color(0xFF1E2D47);

  // Brand
  static const Color primary       = Color(0xFF00E5FF); // cyan neon
  static const Color primaryDark   = Color(0xFF0097A7);
  static const Color secondary     = Color(0xFFCC44FF); // purple neon
  static const Color secondaryDark = Color(0xFF9C27B0);

  // Semantics
  static const Color success = Color(0xFF00FF88);
  static const Color error   = Color(0xFFFF4466);
  static const Color warning = Color(0xFFFFAA00);

  // Text
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8899BB);

  // Light palette
  static const Color lightBg   = Color(0xFFF0F2F8);
  static const Color lightCard = Color(0xFFFFFFFF);
}

// ---------------------------------------------------------------------------
// AppTheme
// ---------------------------------------------------------------------------

class AppTheme {
  AppTheme._();

  // ── helpers ──────────────────────────────────────────────────────────────

  static TextTheme _buildTextTheme(TextTheme base, Color bodyColor, Color headingColor) {
    TextStyle _exo(TextStyle s, Color c) {
      try {
        return GoogleFonts.exo2(textStyle: s.copyWith(color: c));
      } catch (_) {
        return s.copyWith(color: c);
      }
    }

    return base.copyWith(
      displayLarge:  _exo(base.displayLarge!,  headingColor),
      displayMedium: _exo(base.displayMedium!, headingColor),
      displaySmall:  _exo(base.displaySmall!,  headingColor),
      headlineLarge: _exo(base.headlineLarge!, headingColor),
      headlineMedium:_exo(base.headlineMedium!,headingColor),
      headlineSmall: _exo(base.headlineSmall!, headingColor),
      titleLarge:    _exo(base.titleLarge!,    headingColor),
      titleMedium:   _exo(base.titleMedium!,   bodyColor),
      titleSmall:    _exo(base.titleSmall!,    bodyColor),
      bodyLarge:     _exo(base.bodyLarge!,     bodyColor),
      bodyMedium:    _exo(base.bodyMedium!,    bodyColor),
      bodySmall:     _exo(base.bodySmall!,     AppColors.textSecondary),
      labelLarge:    _exo(base.labelLarge!,    bodyColor),
      labelMedium:   _exo(base.labelMedium!,   bodyColor),
      labelSmall:    _exo(base.labelSmall!,    AppColors.textSecondary),
    );
  }

  // ── Dark Theme ────────────────────────────────────────────────────────────

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary:        AppColors.primary,
      onPrimary:      AppColors.darkBg,
      secondary:      AppColors.secondary,
      onSecondary:    AppColors.darkBg,
      surface:        AppColors.darkCard,
      onSurface:      AppColors.textPrimary,
      error:          AppColors.error,
      onError:        AppColors.textPrimary,
      brightness:     Brightness.dark,
    );

    final base = ThemeData.dark();

    return ThemeData(
      useMaterial3:     true,
      brightness:       Brightness.dark,
      colorScheme:      colorScheme,
      scaffoldBackgroundColor: AppColors.darkBg,
      textTheme: _buildTextTheme(
        base.textTheme,
        AppColors.textPrimary,
        AppColors.textPrimary,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor:  AppColors.darkBg,
        foregroundColor:  AppColors.textPrimary,
        elevation:        0,
        centerTitle:      true,
        iconTheme:        IconThemeData(color: AppColors.primary),
        titleTextStyle:   TextStyle(
          color:      AppColors.textPrimary,
          fontSize:   18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color:        AppColors.darkCard,
        elevation:    0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkCardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color:     AppColors.darkCardBorder,
        thickness: 1,
        space:     1,
      ),

      // Icon
      iconTheme: const IconThemeData(color: AppColors.primary, size: 24),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled:        true,
        fillColor:     AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.darkCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.darkCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle:  const TextStyle(color: AppColors.textSecondary),
        prefixIconColor: AppColors.primary,
        suffixIconColor: AppColors.textSecondary,
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:  AppColors.primary,
          foregroundColor:  AppColors.darkBg,
          elevation:        0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.5),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // Bottom nav
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:      AppColors.darkCard,
        selectedItemColor:    AppColors.primary,
        unselectedItemColor:  AppColors.textSecondary,
        elevation:            0,
        type: BottomNavigationBarType.fixed,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor:  AppColors.darkCard,
        selectedColor:    AppColors.primary.withOpacity(0.25),
        labelStyle:       const TextStyle(color: AppColors.textPrimary),
        side: const BorderSide(color: AppColors.darkCardBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor:  WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.textSecondary),
        trackColor:  WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.darkCardBorder),
      ),

      // ListTile
      listTileTheme: const ListTileThemeData(
        iconColor:       AppColors.primary,
        textColor:       AppColors.textPrimary,
        subtitleTextStyle: TextStyle(color: AppColors.textSecondary),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor:  AppColors.darkCard,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.darkCardBorder),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Light Theme ───────────────────────────────────────────────────────────

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary:        AppColors.primaryDark,
      onPrimary:      AppColors.textPrimary,
      secondary:      AppColors.secondaryDark,
      onSecondary:    AppColors.textPrimary,
      surface:        AppColors.lightCard,
      onSurface:      Color(0xFF0D1B2A),
      error:          AppColors.error,
      onError:        AppColors.textPrimary,
      brightness:     Brightness.light,
    );

    const bodyColor    = Color(0xFF0D1B2A);
    const subtitleColor= Color(0xFF4A5568);

    final base = ThemeData.light();

    return ThemeData(
      useMaterial3:     true,
      brightness:       Brightness.light,
      colorScheme:      colorScheme,
      scaffoldBackgroundColor: AppColors.lightBg,
      textTheme: _buildTextTheme(base.textTheme, bodyColor, bodyColor),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightCard,
        foregroundColor: bodyColor,
        elevation:       0,
        centerTitle:     true,
        iconTheme:       IconThemeData(color: AppColors.primaryDark),
        titleTextStyle:  TextStyle(
          color:      bodyColor,
          fontSize:   18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      cardTheme: CardThemeData(
        color:     AppColors.lightCard,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),

      dividerTheme: const DividerThemeData(
        color:     Color(0xFFE2E8F0),
        thickness: 1,
        space:     1,
      ),

      iconTheme: const IconThemeData(color: AppColors.primaryDark, size: 24),

      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: AppColors.lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: Color(0xFFCBD5E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: Color(0xFFCBD5E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.primaryDark, width: 1.5),
        ),
        labelStyle:      const TextStyle(color: subtitleColor),
        hintStyle:       const TextStyle(color: subtitleColor),
        prefixIconColor: AppColors.primaryDark,
        suffixIconColor: subtitleColor,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.textPrimary,
          elevation:       0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.5),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          side: const BorderSide(color: AppColors.primaryDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:     AppColors.lightCard,
        selectedItemColor:   AppColors.primaryDark,
        unselectedItemColor: subtitleColor,
        elevation:           4,
        type: BottomNavigationBarType.fixed,
      ),

      chipTheme: ChipThemeData(
        backgroundColor:  AppColors.lightBg,
        selectedColor:    AppColors.primaryDark.withOpacity(0.15),
        labelStyle:       const TextStyle(color: bodyColor),
        side: const BorderSide(color: Color(0xFFCBD5E0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.primaryDark : Colors.grey),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? AppColors.primaryDark.withOpacity(0.3)
                : const Color(0xFFCBD5E0)),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor:         AppColors.primaryDark,
        textColor:         bodyColor,
        subtitleTextStyle: TextStyle(color: subtitleColor),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor:  AppColors.lightCard,
        contentTextStyle: const TextStyle(color: bodyColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFCBD5E0)),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

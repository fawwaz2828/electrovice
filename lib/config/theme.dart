import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // ── Color Tokens ────────────────────────────────────────────────
  static const Color primary     = Color(0xFF0061FF);
  static const Color primaryDark = Color(0xFF0041CC);
  static const Color bg          = Color(0xFFFFFFFF);   // pure white
  static const Color surface     = Color(0xFFFFFFFF);   // pure white
  static const Color ink         = Color(0xFF0A0A0A);   // deep black
  static const Color inkLight    = Color(0xFF4A4A4A);   // secondary text
  static const Color muted       = Color(0xFF8A8A8A);   // muted/placeholder
  static const Color border      = Color(0xFFE2E8F0);   // soft gray border
  static const Color borderDark  = Color(0xFFCBD5E1);   // darker gray border
  static const Color inputFill   = Color(0xFFFFFFFF);   // white — rely on borders
  static const Color success     = Color(0xFF10B981);
  static const Color warning     = Color(0xFFF59E0B);
  static const Color error       = Color(0xFFEF4444);

  // Legacy aliases
  static const Color primaryColor     = primary;
  static const Color backgroundColor  = bg;
  static const Color textPrimary      = ink;
  static const Color textSecondary    = inkLight;

  // ── Font helper ─────────────────────────────────────────────────
  static TextStyle _sw({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = ink,
    double? height,
    double letterSpacing = 0,
  }) =>
      TextStyle(
        fontFamily: 'Switzer',
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      primaryColor: primary,
      scaffoldBackgroundColor: bg,

      // ── ColorScheme ──────────────────────────────────────────
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: Color(0xFF3654FF),
        onSecondary: Colors.white,
        surface: surface,
        onSurface: ink,
        error: error,
        onError: Colors.white,
        outline: border,
      ),

      // ── Typography ───────────────────────────────────────────
      textTheme: base.textTheme
          .apply(fontFamily: 'Switzer', bodyColor: ink, displayColor: ink)
          .copyWith(
            displayLarge:  _sw(size: 32, weight: FontWeight.w900),
            displayMedium: _sw(size: 28, weight: FontWeight.w800),
            titleLarge:    _sw(size: 20, weight: FontWeight.w800),
            titleMedium:   _sw(size: 17, weight: FontWeight.w700),
            titleSmall:    _sw(size: 14, weight: FontWeight.w700),
            bodyLarge:     _sw(size: 15),
            bodyMedium:    _sw(size: 14, color: inkLight),
            bodySmall:     _sw(size: 12, color: muted),
            labelLarge:    _sw(size: 14, weight: FontWeight.w700),
            labelSmall:    _sw(size: 10, weight: FontWeight.w800, color: muted, letterSpacing: 0.8),
          ),

      // ── AppBar ───────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: _sw(size: 18, weight: FontWeight.w800),
        iconTheme: const IconThemeData(color: ink, size: 22),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // ── Card ─────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),

      // ── Input ────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: _sw(size: 14, color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
      ),

      // ── ElevatedButton / FilledButton ────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          textStyle: _sw(size: 14, weight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          textStyle: _sw(size: 14, weight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      // ── OutlinedButton ───────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: border, width: 1),
          minimumSize: const Size.fromHeight(52),
          textStyle: _sw(size: 14, weight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      // ── TextButton ───────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: _sw(size: 13, weight: FontWeight.w700),
        ),
      ),

      // ── Chip ─────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: Color(0xFFEEF2FF),
        selectedColor: ink,
        labelStyle: _sw(size: 12, weight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: border, width: 1),
      ),

      // ── Divider ──────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      // ── BottomNavigationBar ──────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: ink,
        unselectedItemColor: muted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // ── TabBar ───────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: ink,
        unselectedLabelColor: muted,
        labelStyle: _sw(size: 13, weight: FontWeight.w800),
        unselectedLabelStyle: _sw(size: 13, weight: FontWeight.w600),
        indicatorColor: ink,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: border,
      ),

      // ── ListTile ─────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: inkLight,
        titleTextStyle: _sw(size: 15, weight: FontWeight.w600),
      ),
    );
  }
}

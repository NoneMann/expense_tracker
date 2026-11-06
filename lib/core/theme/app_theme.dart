import 'package:flutter/material.dart';

class AppTheme {
  static const emerald = Color(0xFF187B55);
  static const mint = Color(0xFFE9F6F0);
  static const ink = Color(0xFF17221D);
  static const muted = Color(0xFF84918A);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: dark ? const Color(0xFF35B982) : emerald,
      brightness: brightness,
      surface: dark ? const Color(0xFF1B241F) : const Color(0xFFF0FCF4),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark
          ? const Color(0xFF111714)
          : const Color(0xFFF0FCF4),
      fontFamily: 'PlusJakartaSans',
      appBarTheme: AppBarTheme(
        backgroundColor: dark
            ? const Color(0xFF111714)
            : const Color(0xFFF0FCF4),
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: dark ? const Color(0xFF1B241F) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: dark ? const Color(0xFF303B34) : const Color(0xFFE8ECE9),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF1B241F) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: .45),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? const Color(0xFF1B241F) : Colors.white,
        indicatorColor: dark ? const Color(0xFF254A38) : mint,
        height: 70,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: emerald,
        foregroundColor: Colors.white,
      ),
    );
  }
}

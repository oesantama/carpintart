import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta de colores Premium Industrial & Fine Art
  static const Color backgroundDark = Color(0xFF0B132B); // Slate muy oscuro
  static const Color surfaceDark = Color(0xFF1C2541);    // Azul noche industrial
  static const Color cardDark = Color(0xFF2A385B);       // Tarjetas elevadas
  static const Color primaryGold = Color(0xFFE69500);    // Dorado Madera / Arte
  static const Color primaryAmber = Color(0xFFFFA100);   // Ámbar cálido
  static const Color accentTeal = Color(0xFF06B6D4);     // Cyan Herramientas / RH
  static const Color textLight = Color(0xFFF8FAFC);     // Texto claro
  static const Color textMuted = Color(0xFF94A3B8);     // Texto secundario
  static const Color successGreen = Color(0xFF10B981);  // Estado completado / pagado
  static const Color warningOrange = Color(0xFFF59E0B); // Alertas / Pendiente
  static const Color errorRed = Color(0xFFE11D48);      // Cancelado / Stock crítico

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        secondary: accentTeal,
        surface: surfaceDark,
        background: backgroundDark,
        error: errorRed,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: textLight,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          color: textLight,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.outfit(
          color: textLight,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.outfit(
          color: textLight,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: textMuted,
          fontSize: 14,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: primaryGold),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF3B4A6F), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF475569)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF475569)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGold, width: 2),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGold,
        foregroundColor: Colors.black,
        elevation: 6,
      ),
    );
  }
}

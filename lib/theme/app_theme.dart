import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Application theme following the Sumadhura Visitor Management design specifications:
/// - Primary: #B48D54 (Sumadhura Signature Gold / Brass)
/// - Primary teal: #0F9D8A
/// - Background: #F5F7FA
/// - Surface: #FFFFFF
/// - Text Dark: #1E293B
/// - Secondary text: #64748B
/// - Border: #E2E8F0
/// - Success: #16A34A
/// - Pending: #D97706
/// - Error: #DC2626
/// - Material 3 with 8px grid spacing and rounded corners
class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFFB3802B);
  static const Color primaryGold = Color(0xFFB3802B);
  static const Color primaryNavy = Color(0xFF1A1714);
  static const Color primaryTeal = Color(0xFF0E8A5E);
  static const Color textDark = Color(0xFF1A1714);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color background = Color(0xFFFBF9F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color border = Color(0xFFEDE7DD);
  static const Color success = Color(0xFF0E8A5E);
  static const Color pending = Color(0xFFB45309);
  static const Color error = Color(0xFFDC2626);

  // Exact Sumadhura Brand Luxury Tokens from Figma
  static const Color onyxDark = Color(0xFF1A1714);
  static const Color onyxCard = Color(0xFF1E1B17);
  static const Color onyxInner = Color(0xFF14120F);
  static const Color goldLight = Color(0xFFC59A3F);
  static const Color goldDark = Color(0xFF8B601C);
  static const Color goldChampagne = Color(0xFFFAF7F2);
  static const Color goldBorder = Color(0xFFEFEBE3);
  static const Color royalBlue = Color(0xFF004884);

  // Status Colors & Backgrounds from Figma
  static const Color insideGreen = Color(0xFF0E8A5E);
  static const Color insideGreenLight = Color(0xFFE6F7F0);
  static const Color expectedAmber = Color(0xFFB45309);
  static const Color expectedAmberLight = Color(0xFFFEF3C7);
  static const Color exitedSlate = Color(0xFF475569);
  static const Color exitedSlateLight = Color(0xFFF1F5F9);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFC59A3F), Color(0xFFB3802B), Color(0xFF8B601C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF14B8A6), Color(0xFF0F9D8A), Color(0xFF0D7B6C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.05),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0xFFB48D54).withValues(alpha: 0.03),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get goldGlow => [
    BoxShadow(
      color: const Color(0xFFB48D54).withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: primaryTeal,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: textDark,
      error: error,
      onError: Colors.white,
      outline: border,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF14120F),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: const TextStyle(color: secondaryText, fontSize: 13.5),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        indicatorColor: primaryColor.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryColor);
          }
          return const IconThemeData(color: secondaryText);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            );
          }
          return const TextStyle(
            color: secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0F172A),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titleTextStyle: const TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: const TextStyle(
          color: secondaryText,
          fontSize: 14,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF13B6EC);
  static const Color backgroundLight = Color(0xFFF6F8F8);
  static const Color backgroundDark = Color(0xFF101D22);
  static const Color surfaceDark = Color(0xFF1C2427);
  static const Color surfaceLight = Colors.white;

  static ThemeData getTheme({
    required bool isDark,
    required bool highContrast,
    required bool readableFont,
  }) {
    // 1. Define Base Colors
    // High Contrast Mode: Yellow (#FACC15) on Black, or White on Black, etc.
    // The requirement says: Yellow (#FACC15) on Black (#000000) for High Contrast.

    // Standard Colors
    final Color standardPrimary = const Color(0xFF13B6EC);
    final Color standardBackgroundLight = const Color(0xFFF6F8F8);
    final Color standardBackgroundDark = const Color(0xFF101D22);
    final Color standardSurfaceLight = Colors.white;
    final Color standardSurfaceDark = const Color(0xFF1C2427);

    // High Contrast Colors
    final Color hcPrimary = const Color(0xFFFACC15); // Yellow
    final Color hcBackground = Colors.black;
    final Color hcSurface = Colors.black;
    final Color hcOnSurface = const Color(0xFFFACC15); // Yellow text on black

    // Determine effective colors
    Color primaryColor;
    Color backgroundColor;
    Color surfaceColor;
    Color onSurfaceColor;
    Brightness brightness;

    if (highContrast) {
      // High Contrast is typically dark mode with yellow text/elements
      brightness = Brightness.dark;
      primaryColor = hcPrimary;
      backgroundColor = hcBackground;
      surfaceColor = hcSurface;
      onSurfaceColor = hcOnSurface;
    } else {
      brightness = isDark ? Brightness.dark : Brightness.light;
      primaryColor = standardPrimary;
      backgroundColor = isDark
          ? standardBackgroundDark
          : standardBackgroundLight;
      surfaceColor = isDark ? standardSurfaceDark : standardSurfaceLight;
      onSurfaceColor = isDark ? Colors.white : Colors.black;
    }

    // 2. Define Typography
    // Dyslexia-Friendly: simulated by a clean sans-serif like Arial or Helvetica (default flutter sans is fine),
    // versus GoogleFonts.plusJakartaSans.
    TextTheme baseTextTheme = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    TextTheme appTextTheme;
    if (readableFont) {
      // Use default system font (usually clean sans-serif)
      appTextTheme = baseTextTheme.apply(
        fontFamily: null, // Default
        displayColor: onSurfaceColor,
        bodyColor: onSurfaceColor,
      );
    } else {
      appTextTheme = GoogleFonts.plusJakartaSansTextTheme(
        baseTextTheme,
      ).apply(displayColor: onSurfaceColor, bodyColor: onSurfaceColor);
    }

    // 3. Define Interactions (Buttons etc.)
    // High Contrast: Thick borders, no shadows.

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: highContrast ? Colors.black : Colors.white,
        secondary: primaryColor,
        onSecondary: highContrast ? Colors.black : Colors.white,
        error: Colors.redAccent,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: appTextTheme.titleLarge?.copyWith(
          color: onSurfaceColor,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: onSurfaceColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: highContrast ? Colors.black : Colors.white,
          elevation: highContrast ? 0 : 2,
          side: highContrast
              ? BorderSide(
                  color: onSurfaceColor,
                  width: 3,
                ) // Thick border for HC
              : BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: highContrast
              ? const EdgeInsets.symmetric(vertical: 16, horizontal: 24)
              : const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      iconTheme: IconThemeData(color: onSurfaceColor),
      // Add other theme properties as needed
    );
  }
}

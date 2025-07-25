import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/utils/app_colors.dart';

/// Modern theme configuration following Material Design 3 principles
class AppTheme {
  AppTheme._();

  /// Light theme configuration (for future use)
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  /// Dark theme configuration (primary theme)
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  /// Default theme (dark mode for Bitcoin/Lightning aesthetic)
  static ThemeData get defaultTheme => darkTheme;

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    
    return ThemeData(
      useMaterial3: true, // Enable Material 3
      brightness: brightness,
      fontFamily: GoogleFonts.lato().fontFamily,
      
      // Modern ColorScheme using AppColors
      colorScheme: isDark ? _darkColorScheme : _lightColorScheme,
      
      // App Bar Theme with Material 3 styling
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.lato(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      
      // Modern Input Decoration
      inputDecorationTheme: _inputDecorationTheme,
      
      // Text Selection Theme
      textSelectionTheme: _textSelectionTheme,
      
      // Enhanced Text Theme
      textTheme: _textTheme,
      
      // Modern Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.black2,
      ),
      
      // Enhanced List Tile Theme
      listTileTheme: _listTileTheme,
      
      // Modern Dialog Theme
      dialogTheme: _dialogTheme,
      
      // Enhanced Button Themes
      elevatedButtonTheme: _elevatedButtonTheme,
      textButtonTheme: _textButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
      
      // Scaffold Theme
      scaffoldBackgroundColor: AppColors.black,
      
      // Cupertino Override for iOS styling
      cupertinoOverrideTheme: const NoDefaultCupertinoThemeData(
        primaryColor: AppColors.blue,
        brightness: Brightness.dark,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.blue,
        linearTrackColor: AppColors.grey,
        circularTrackColor: AppColors.grey,
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.blue;
          }
          return AppColors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.blue.withOpacity(0.5);
          }
          return AppColors.grey.withOpacity(0.3);
        }),
      ),
    );
  }

  static ColorScheme get _darkColorScheme => const ColorScheme.dark(
    primary: AppColors.blue,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.darkBlue,
    onPrimaryContainer: AppColors.white,
    secondary: AppColors.green,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.lightGreen,
    onSecondaryContainer: AppColors.black,
    tertiary: AppColors.bitcoin,
    onTertiary: AppColors.black,
    error: AppColors.error,
    onError: AppColors.white,
    background: AppColors.black,
    onBackground: AppColors.white,
    surface: AppColors.black2,
    onSurface: AppColors.white,
    surfaceVariant: AppColors.grey,
    onSurfaceVariant: AppColors.white,
    outline: AppColors.grey,
  );

  static ColorScheme get _lightColorScheme => const ColorScheme.light(
    primary: AppColors.blue,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.darkBlue,
    onPrimaryContainer: AppColors.white,
    secondary: AppColors.green,
    onSecondary: AppColors.white,
    error: AppColors.error,
    onError: AppColors.white,
    background: AppColors.white,
    onBackground: AppColors.black,
    surface: AppColors.white,
    onSurface: AppColors.black,
  );

  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.black2.withOpacity(0.5),
      labelStyle: const TextStyle(color: AppColors.white),
      hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.7)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(16),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.blue, width: 2.0),
        borderRadius: BorderRadius.circular(16),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.error, width: 1.0),
        borderRadius: BorderRadius.circular(16),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.error, width: 2.0),
        borderRadius: BorderRadius.circular(16),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.grey.withOpacity(0.5), width: 1.0),
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  static TextSelectionThemeData get _textSelectionTheme {
    return const TextSelectionThemeData(
      cursorColor: AppColors.blue,
      selectionColor: AppColors.blue,
      selectionHandleColor: AppColors.blue,
    );
  }

  static TextTheme get _textTheme {
    return GoogleFonts.latoTextTheme().copyWith(
      displayLarge: GoogleFonts.lato(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      ),
      displayMedium: GoogleFonts.lato(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      displaySmall: GoogleFonts.lato(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
      headlineLarge: GoogleFonts.lato(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      headlineMedium: GoogleFonts.lato(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
      headlineSmall: GoogleFonts.lato(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
      titleLarge: GoogleFonts.lato(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      titleMedium: GoogleFonts.lato(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
      titleSmall: GoogleFonts.lato(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
      bodyLarge: GoogleFonts.lato(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.white,
      ),
      bodyMedium: GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.white,
      ),
      bodySmall: GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.grey,
      ),
      labelLarge: GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
      labelMedium: GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
      labelSmall: GoogleFonts.lato(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.grey,
      ),
    );
  }

  static ListTileThemeData get _listTileTheme {
    return const ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: AppColors.blue,
      iconColor: AppColors.white,
      textColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  static DialogThemeData get _dialogTheme {
    return DialogThemeData(
      backgroundColor: AppColors.black2,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: GoogleFonts.lato(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      contentTextStyle: GoogleFonts.lato(
        fontSize: 16,
        color: AppColors.white,
      ),
    );
  }

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blue,
        foregroundColor: AppColors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.blue,
        side: const BorderSide(color: AppColors.blue, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static BottomNavigationBarThemeData get _bottomNavigationBarTheme {
    return BottomNavigationBarThemeData(
      backgroundColor: AppColors.black,
      selectedItemColor: AppColors.blue,
      unselectedItemColor: AppColors.grey,
      selectedIconTheme: const IconThemeData(size: 28),
      unselectedIconTheme: const IconThemeData(size: 24),
      selectedLabelStyle: GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.lato(
        fontSize: 10,
        fontWeight: FontWeight.normal,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }
}

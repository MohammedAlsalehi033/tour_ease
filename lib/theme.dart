import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  // Refined color palette - More balanced and professional
  static const Color _primaryColor = Color(0xFF06B6D4); // Cyan 500 - Vibrant but not harsh
  static const Color _primaryLight = Color(0xFF67E8F9); // Cyan 300
  static const Color _primaryDark = Color(0xFF0891B2); // Cyan 600
  static const Color _accentColor = Color(0xFF3B82F6); // Blue 500 - Better than purple
  
  static const Color _errorColor = Color(0xFFEF4444); // Red 500
  static const Color _successColor = Color(0xFF10B981); // Emerald 500
  static const Color _warningColor = Color(0xFFF59E0B); // Amber 500
  static const Color _infoColor = Color(0xFF3B82F6); // Blue 500

  // Refined border radius
  static const double _borderRadiusSm = 8.0;
  static const double _borderRadiusMd = 12.0;
  static const double _borderRadiusLg = 16.0;

  // Modern typography
  static final TextTheme _baseTextTheme = TextTheme(
    // Display styles
    displayLarge: GoogleFonts.poppins(
      fontSize: 40,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    
    // Headline styles
    headlineLarge: GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
      height: 1.2,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
      height: 1.2,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    
    // Title styles
    titleLarge: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    
    // Body styles
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.6,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    
    // Label styles
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.4,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.4,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      height: 1.4,
    ),
  );

  // Modern button style
  static ButtonStyle _baseButtonStyle(ColorScheme colorScheme) {
    return ButtonStyle(
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadiusSm),
        ),
      ),
      elevation: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) return 0;
        if (states.contains(MaterialState.hovered)) return 2;
        return 1;
      }),
    );
  }

  // Light theme
  static final ThemeData lightTheme = _buildLightTheme();

  // Dark theme
  static final ThemeData darkTheme = _buildDarkTheme();

  // Factory method for light theme
  static ThemeData _buildLightTheme() {
    final ColorScheme colorScheme = ColorScheme.light(
      primary: _primaryColor,
      primaryContainer: const Color(0xFFE0F7FA), // Cyan 50
      secondary: _accentColor,
      secondaryContainer: const Color(0xFFF3E5F5), // Purple 50
      tertiary: const Color(0xFF06B6D4),
      error: _errorColor,
      errorContainer: const Color(0xFFFFEBEE), // Red 50
      surface: Colors.white,
      surfaceVariant: const Color(0xFFF8FAFC), // Slate 50
      background: const Color(0xFFF8FAFC), // Slate 50
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
      onSurface: const Color(0xFF0F172A), // Slate 900
      onSurfaceVariant: const Color(0xFF64748B), // Slate 500
      onBackground: const Color(0xFF0F172A),
      outline: const Color(0xFFE2E8F0), // Slate 200
      shadow: Colors.black.withOpacity(0.1),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colorScheme.background,
      
      // Modern app bar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: _baseTextTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        shape: Border(
          bottom: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
      ),

      // Typography
      textTheme: _baseTextTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),

      // Modern card
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: colorScheme.shadow,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMd),
          side: BorderSide(color: colorScheme.outline, width: 1),
        ),
        color: colorScheme.surface,
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _baseButtonStyle(colorScheme).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return colorScheme.onSurface.withOpacity(0.12);
            }
            return colorScheme.primary;
          }),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return colorScheme.onSurface.withOpacity(0.38);
            }
            return colorScheme.onPrimary;
          }),
          iconColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return colorScheme.onSurface.withOpacity(0.38);
            }
            return colorScheme.onPrimary;
          }),
          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
          shadowColor: MaterialStateProperty.all(colorScheme.primary.withOpacity(0.3)),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: _baseButtonStyle(colorScheme).copyWith(
          foregroundColor: MaterialStateProperty.all(colorScheme.primary),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) {
              return colorScheme.primaryContainer;
            }
            return Colors.transparent;
          }),
          elevation: MaterialStateProperty.all(0),
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _baseButtonStyle(colorScheme).copyWith(
          foregroundColor: MaterialStateProperty.all(colorScheme.primary),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) {
              return colorScheme.primaryContainer;
            }
            return Colors.transparent;
          }),
          side: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return BorderSide(color: colorScheme.outline);
            }
            return BorderSide(color: colorScheme.primary, width: 1.5);
          }),
          elevation: MaterialStateProperty.all(0),
        ),
      ),

      // Icons
      iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
      primaryIconTheme: IconThemeData(color: colorScheme.onPrimary, size: 24),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusSm),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusSm),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusSm),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusSm),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusSm),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 1,
        space: 16,
      ),

      // Bottom sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 8,
        modalElevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(_borderRadiusLg),
            topRight: Radius.circular(_borderRadiusLg),
          ),
        ),
        modalBackgroundColor: colorScheme.surface,
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: BorderSide(color: colorScheme.outline, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
        trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.primaryContainer,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withOpacity(0.12),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMd),
        ),
      ),

      // Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: MaterialStateProperty.all(
          _baseTextTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.onSurface,
        contentTextStyle: TextStyle(color: colorScheme.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadiusSm),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Factory method for dark theme
  static ThemeData _buildDarkTheme() {
    final ColorScheme colorScheme = ColorScheme.dark(
      primary: _primaryDark, // Cyan 600 - Darker for better contrast
      primaryContainer: const Color(0xFF164E63), // Cyan 900
      secondary: _accentColor,
      secondaryContainer: const Color(0xFF1E3A8A), // Blue 900
      tertiary: const Color(0xFF06B6D4),
      error: _errorColor,
      errorContainer: const Color(0xFF7F1D1D), // Red 900
      surface: const Color(0xFF0F172A), // Slate 900 - Darker surface
      surfaceVariant: const Color(0xFF1E293B), // Slate 800
      background: const Color(0xFF020617), // Slate 950 - Almost black
      onPrimary: Colors.white, // White text on dark primary
      onSecondary: Colors.white,
      onError: Colors.white,
      onSurface: const Color(0xFFF8FAFC), // Slate 50
      onSurfaceVariant: const Color(0xFF94A3B8), // Slate 400
      onBackground: const Color(0xFFF8FAFC),
      outline: const Color(0xFF334155), // Slate 700
      shadow: Colors.black.withOpacity(0.5),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colorScheme.background,

      // Dark app bar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: _baseTextTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        shape: Border(
          bottom: BorderSide(
            color: colorScheme.outline,
            width: 1,
          ),
        ),
      ),

      // Typography
      textTheme: _baseTextTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),

      // Dark card
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: colorScheme.shadow,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMd),
          side: BorderSide(color: colorScheme.outline, width: 1),
        ),
        color: colorScheme.surface,
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _baseButtonStyle(colorScheme).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return colorScheme.onSurface.withOpacity(0.12);
            }
            return colorScheme.primary;
          }),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return colorScheme.onSurface.withOpacity(0.38);
            }
            return colorScheme.onPrimary;
          }),
          iconColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return colorScheme.onSurface.withOpacity(0.38);
            }
            return colorScheme.onPrimary;
          }),
          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
          shadowColor: MaterialStateProperty.all(colorScheme.primary.withOpacity(0.5)),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: _baseButtonStyle(colorScheme).copyWith(
          foregroundColor: MaterialStateProperty.all(colorScheme.primary),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) {
              return colorScheme.primaryContainer;
            }
            return Colors.transparent;
          }),
          elevation: MaterialStateProperty.all(0),
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _baseButtonStyle(colorScheme).copyWith(
          foregroundColor: MaterialStateProperty.all(colorScheme.primary),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) {
              return colorScheme.primaryContainer.withOpacity(0.5);
            }
            return Colors.transparent;
          }),
          side: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return BorderSide(color: colorScheme.outline);
            }
            return BorderSide(color: colorScheme.primary, width: 1.5);
          }),
          elevation: MaterialStateProperty.all(0),
        ),
      ),

      // Icons
      iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
      primaryIconTheme: IconThemeData(color: colorScheme.onPrimary, size: 24),

      // Dark input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusSm),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusSm),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusSm),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusSm),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadiusSm),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 1,
        space: 16,
      ),

      // Bottom sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 8,
        modalElevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(_borderRadiusLg),
            topRight: Radius.circular(_borderRadiusLg),
          ),
        ),
        modalBackgroundColor: colorScheme.surface,
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(colorScheme.onPrimary),
        side: BorderSide(color: colorScheme.outline, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.onSurfaceVariant;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
        trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.primaryContainer,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withOpacity(0.12),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadiusMd),
        ),
      ),

      // Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: MaterialStateProperty.all(
          _baseTextTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.onSurface,
        contentTextStyle: TextStyle(color: colorScheme.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadiusSm),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
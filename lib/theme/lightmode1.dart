// lib/theme/app_themes.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ========== Palette 1: Light Green & Gold (For Light Theme) ==========
// Using the definition you provided earlier
class _LightGreenGoldPalette {
  _LightGreenGoldPalette._();
  // Primary: Fresh Green
  static const Color primary = Color(0xFF4CAF50); // Green 500
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFC8E6C9); // Green 100
  static const Color onPrimaryContainer = Color(0xFF0D1F12); // Dark Green

  // Secondary: Vibrant Yellow/Gold
  static const Color secondary = Color(0xFFFFC107); // Amber 500
  static const Color onSecondary = Colors.black;
  static const Color secondaryContainer = Color(0xFFFFECB3); // Amber 100
  static const Color onSecondaryContainer = Color(0xFF261A00); // Dark Brown

  // Tertiary (Optional Accent)
  static const Color tertiary = Color(0xFF006874); // Tealish
  static const Color onTertiary = Colors.white;
  static const Color tertiaryContainer = Color(0xFF97F0FF); // Light Cyan
  static const Color onTertiaryContainer = Color(0xFF001F24); // Dark Cyan

  static const Color error = Color(0xFFB00020); // Standard Material Red
  static const Color onError = Colors.white;
  static const Color errorContainer = Color(0xFFFFDAD6); // Light Red Container
  static const Color onErrorContainer = Color(0xFF410002); // Dark Red

  // Backgrounds & Surfaces: Green-Tinted & Light
  static const Color background =
      Color(0xFFF7FDF9); // Very light green-tinted white
  static const Color onBackground =
      Color(0xFF1B2E1C); // Dark Greenish Grey text
  static const Color surface = Colors.white; // White cards/dialogs etc.
  static const Color onSurface = Color(0xFF1B2E1C); // Dark Greenish Grey text

  static const Color surfaceVariant =
      Color(0xFFDCEDDC); // Light Green accent bg
  static const Color onSurfaceVariant = Color(0xFF414941); // Medium dark green

  static const Color outline = Color(0xFF717971); // Greyish Green Outline
  static const Color outlineVariant = Color(0xFFC1C9BF); // Lighter Outline
  static const Color shadow = Colors.black;
  static const Color scrim = Colors.black;

  static const Color inverseSurface = Color(0xFF2F312F); // Dark inverse surface
  static const Color onInverseSurface = Color(0xFFF0F1EC); // Light text on dark
  static const Color inversePrimary =
      Color(0xFF9CD69E); // Light Green inverse primary

  static const Color surfaceTint = primary; // Primary color tint

  // M3 Surface Tones (Approximated for Light Theme - used by ColorScheme)
  static const Color surfaceDim = Color(0xFFD8DDD8);
  static const Color surfaceBright = Color(0xFFF7FDF9); // Same as background
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F7F2);
  static const Color surfaceContainer = Color(0xFFEDF2EC);
  static const Color surfaceContainerHigh = Color(0xFFE7ECE6);
  static const Color surfaceContainerHighest = Color(0xFFE1E6E1);

  // Text & Icon Colors (Explicit for clarity)
  static const Color textPrimary = Color(0xFF1B2E1C); // Dark Greenish Grey
  static const Color textSecondary = Color(0xFF4C6B4D); // Medium Greenish Grey
  static const Color textDisabled = Color(0xFF9E9E9E); // Standard Grey
  static const Color iconColor = Color(0xFF4C6B4D); // Medium Greenish Grey
  static const Color iconOnPrimary = Colors.white; // Icons on primary buttons
}

class _DarkPalette3 {
  _DarkPalette3._();
  // Primary: Rich Gold
  static const Color primary = Color(0xFFFFCA28); // Amber A400 (Good Gold)
  static const Color primaryVariant =
      Color(0xFFFFB300); // Amber 700 (Deeper Gold)
  // Secondary: Subtle accent (optional - can be same as primary or different)
  static const Color secondary =
      Color(0xFF66BB6A); // Soft Green Accent (Optional contrast)
  static const Color secondaryVariant = Color(0xFF4CAF50);

  // Backgrounds & Surfaces: TikTok Style Dark
  static const Color background =
      Color(0xFF121212); // Very Dark Grey (Off-black)
  static const Color surface =
      Color(0xFF1E1E1E); // Slightly Lighter Dark Surface
  static const Color surfaceVariant =
      Color(0xFF2C2C2E); // Even Lighter Surface for accents

  static const Color error = Color(0xFFEF9A9A); // Light Red for Dark Theme

  // "On" Colors
  static const Color onPrimary = Colors.black; // Black usually best on Gold
  static const Color onSecondary = Colors.black; // Black on the soft green
  static const Color onBackground = Color(0xFFEAEAEA); // Light Grey/Off-white
  static const Color onSurface =
      Color(0xFFF5F5F5); // Slightly brighter Off-white
  static const Color onError = Colors.black;

  // Text Colors
  static const Color textPrimary = Color(0xFFF5F5F5); // Bright Off-white
  static const Color textSecondary = Color(0xFFB0B0B0); // Medium Light Grey
  static const Color textDisabled = Color(0xFF757575); // Darker Grey

  static const Color iconColor =
      Color(0xFFB0B0B0); // Medium Light Grey for icons
}

// --- Base Text Styles (Using Poppins) ---
// Define the styles once, apply color per theme.
class _AppTextStyles {
  static final TextStyle _base = GoogleFonts.poppins(letterSpacing: 0.15);
  // M3 Style Definitions (Size/Weight/Spacing)
  static TextStyle displayLarge =
      _base.copyWith(fontSize: 57, fontWeight: FontWeight.w400, height: 1.12);
  static TextStyle displayMedium =
      _base.copyWith(fontSize: 45, fontWeight: FontWeight.w400, height: 1.15);
  static TextStyle displaySmall =
      _base.copyWith(fontSize: 36, fontWeight: FontWeight.w400, height: 1.22);
  static TextStyle headlineLarge =
      _base.copyWith(fontSize: 32, fontWeight: FontWeight.w500, height: 1.25);
  static TextStyle headlineMedium =
      _base.copyWith(fontSize: 28, fontWeight: FontWeight.w500, height: 1.28);
  static TextStyle headlineSmall =
      _base.copyWith(fontSize: 24, fontWeight: FontWeight.w500, height: 1.33);
  static TextStyle titleLarge =
      _base.copyWith(fontSize: 22, fontWeight: FontWeight.w500, height: 1.27);
  static TextStyle titleMedium = _base.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.5,
      letterSpacing: 0.15);
  static TextStyle titleSmall = _base.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.43,
      letterSpacing: 0.1);
  static TextStyle bodyLarge = _base.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.5);
  static TextStyle bodyMedium = _base.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.43,
      letterSpacing: 0.25);
  static TextStyle bodySmall = _base.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.33,
      letterSpacing: 0.4);
  static TextStyle labelLarge = _base.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.43,
      letterSpacing: 0.1);
  static TextStyle labelMedium = _base.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.33,
      letterSpacing: 0.5);
  static TextStyle labelSmall = _base.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      height: 1.45,
      letterSpacing: 0.5);
}

// ============================================================
//         Centralized Theme Definitions
// ============================================================
class AppThemes {
  AppThemes._();

  // Common Button Shape & Padding
  static final OutlinedBorder _buttonShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
  static const EdgeInsets _buttonPadding =
      EdgeInsets.symmetric(horizontal: 24, vertical: 14);

  // Common Page Transitions
  static const PageTransitionsTheme _pageTransitionsTheme =
      PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
    },
  );

  // ================== LIGHT THEME (Green/Gold) ==================
  static final ThemeData lightTheme = _buildThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      brightness: Brightness.light,
      primary: _LightGreenGoldPalette.primary,
      onPrimary: _LightGreenGoldPalette.onPrimary,
      primaryContainer: _LightGreenGoldPalette.primaryContainer,
      onPrimaryContainer: _LightGreenGoldPalette.onPrimaryContainer,
      secondary: _LightGreenGoldPalette.secondary,
      onSecondary: _LightGreenGoldPalette.onSecondary,
      secondaryContainer: _LightGreenGoldPalette.secondaryContainer,
      onSecondaryContainer: _LightGreenGoldPalette.onSecondaryContainer,
      tertiary: _LightGreenGoldPalette.tertiary,
      onTertiary: _LightGreenGoldPalette.onTertiary,
      tertiaryContainer: _LightGreenGoldPalette.tertiaryContainer,
      onTertiaryContainer: _LightGreenGoldPalette.onTertiaryContainer,
      error: _LightGreenGoldPalette.error,
      onError: _LightGreenGoldPalette.onError,
      errorContainer: _LightGreenGoldPalette.errorContainer,
      onErrorContainer: _LightGreenGoldPalette.onErrorContainer,
      background: _LightGreenGoldPalette.background,
      onBackground: _LightGreenGoldPalette.onBackground,
      surface: _LightGreenGoldPalette.surface,
      onSurface: _LightGreenGoldPalette.onSurface,
      surfaceVariant: _LightGreenGoldPalette.surfaceVariant,
      onSurfaceVariant: _LightGreenGoldPalette.onSurfaceVariant,
      outline: _LightGreenGoldPalette.outline,
      outlineVariant: _LightGreenGoldPalette.outlineVariant,
      shadow: _LightGreenGoldPalette.shadow,
      scrim: _LightGreenGoldPalette.scrim,
      inverseSurface: _LightGreenGoldPalette.inverseSurface,
      onInverseSurface: _LightGreenGoldPalette.onInverseSurface,
      inversePrimary: _LightGreenGoldPalette.inversePrimary,
      surfaceTint: _LightGreenGoldPalette.surfaceTint,
      // M3 Surface Tones
      surfaceBright: _LightGreenGoldPalette.surfaceBright,
      surfaceDim: _LightGreenGoldPalette.surfaceDim,
      surfaceContainerLowest: _LightGreenGoldPalette.surfaceContainerLowest,
      surfaceContainerLow: _LightGreenGoldPalette.surfaceContainerLow,
      surfaceContainer: _LightGreenGoldPalette.surfaceContainer,
      surfaceContainerHigh: _LightGreenGoldPalette.surfaceContainerHigh,
      surfaceContainerHighest: _LightGreenGoldPalette.surfaceContainerHighest,
    ),
    textThemeColors: const _ThemeTextColors(
      primary: _LightGreenGoldPalette.textPrimary,
      secondary: _LightGreenGoldPalette.textSecondary,
      disabled: _LightGreenGoldPalette.textDisabled,
    ),
    iconColors: const _ThemeIconColors(
      primary: _LightGreenGoldPalette.iconColor,
      onPrimary: _LightGreenGoldPalette.iconOnPrimary,
    ),
  );

  // ================== DARK THEME (Forest Night) ==================
  static final ThemeData darkTheme = _buildThemeData(
    // Renamed to darkTheme for clarity
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: Color.fromARGB(255, 11, 29, 18),
      onPrimary: _DarkForestPalette.onPrimary,
      primaryContainer: _DarkForestPalette.primaryContainer,
      onPrimaryContainer: _DarkForestPalette.onPrimaryContainer,
      secondary: _DarkForestPalette.secondary,
      onSecondary: _DarkForestPalette.onSecondary,
      secondaryContainer: _DarkForestPalette.secondaryContainer,
      onSecondaryContainer: _DarkForestPalette.onSecondaryContainer,
      tertiary: _DarkForestPalette.tertiary,
      onTertiary: _DarkForestPalette.onTertiary,
      tertiaryContainer: _DarkForestPalette.tertiaryContainer,
      onTertiaryContainer: _DarkForestPalette.onTertiaryContainer,
      error: _DarkForestPalette.error,
      onError: _DarkForestPalette.onError,
      errorContainer: _DarkForestPalette.errorContainer,
      onErrorContainer: _DarkForestPalette.onErrorContainer,
      background: _DarkForestPalette.background,
      onBackground: _DarkForestPalette.onBackground,
      surface: _DarkForestPalette.surface,
      onSurface: _DarkForestPalette.onSurface,
      surfaceVariant: _DarkForestPalette.surfaceVariant,
      onSurfaceVariant: _DarkForestPalette.onSurfaceVariant,
      outline: _DarkForestPalette.outline,
      outlineVariant: _DarkForestPalette.outlineVariant,
      shadow: _DarkForestPalette.shadow,
      scrim: _DarkForestPalette.scrim,
      inverseSurface: _DarkForestPalette.inverseSurface,
      onInverseSurface: _DarkForestPalette.onInverseSurface,
      inversePrimary: _DarkForestPalette.inversePrimary,
      surfaceTint: _DarkForestPalette.surfaceTint,
      // M3 Surface Tones
      surfaceBright: _DarkForestPalette.surfaceBright,
      surfaceDim: _DarkForestPalette.surfaceDim,
      surfaceContainerLowest: _DarkForestPalette.surfaceContainerLowest,
      surfaceContainerLow: _DarkForestPalette.surfaceContainerLow,
      surfaceContainer: _DarkForestPalette.surfaceContainer,
      surfaceContainerHigh: _DarkForestPalette.surfaceContainerHigh,
      surfaceContainerHighest: _DarkForestPalette.surfaceContainerHighest,
    ),
    textThemeColors: const _ThemeTextColors(
      primary: _DarkForestPalette.textPrimary,
      secondary: _DarkForestPalette.textSecondary,
      disabled: _DarkForestPalette.textDisabled,
    ),
    iconColors: const _ThemeIconColors(
      primary: _DarkForestPalette.iconColor,
      onPrimary: _DarkForestPalette.iconOnPrimary,
    ),
  );

  // --- ThemeData Builder Helper (Handles both Light and Dark) ---
  static ThemeData _buildThemeData({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required _ThemeTextColors textThemeColors,
    required _ThemeIconColors iconColors,
  }) {
    final bool isDark = brightness == Brightness.dark;

    // Define base text styles without color
    final textThemeBase = TextTheme(
      displayLarge: _AppTextStyles.displayLarge,
      displayMedium: _AppTextStyles.displayMedium,
      displaySmall: _AppTextStyles.displaySmall,
      headlineLarge: _AppTextStyles.headlineLarge,
      headlineMedium: _AppTextStyles.headlineMedium,
      headlineSmall: _AppTextStyles.headlineSmall,
      titleLarge: _AppTextStyles.titleLarge,
      titleMedium: _AppTextStyles.titleMedium,
      titleSmall: _AppTextStyles.titleSmall,
      bodyLarge: _AppTextStyles.bodyLarge,
      bodyMedium: _AppTextStyles.bodyMedium,
      bodySmall: _AppTextStyles.bodySmall,
      labelLarge: _AppTextStyles.labelLarge,
      labelMedium: _AppTextStyles.labelMedium,
      labelSmall: _AppTextStyles.labelSmall,
    );

    // Apply specific theme colors to the base text styles
    final textTheme = textThemeBase
        .copyWith(
          displayLarge: textThemeBase.displayLarge
              ?.copyWith(color: textThemeColors.primary),
          displayMedium: textThemeBase.displayMedium
              ?.copyWith(color: textThemeColors.primary),
          displaySmall: textThemeBase.displaySmall
              ?.copyWith(color: textThemeColors.primary),
          headlineLarge: textThemeBase.headlineLarge
              ?.copyWith(color: textThemeColors.primary),
          headlineMedium: textThemeBase.headlineMedium
              ?.copyWith(color: textThemeColors.primary),
          headlineSmall: textThemeBase.headlineSmall
              ?.copyWith(color: textThemeColors.primary),
          titleLarge: textThemeBase.titleLarge
              ?.copyWith(color: textThemeColors.primary),
          titleMedium: textThemeBase.titleMedium
              ?.copyWith(color: textThemeColors.primary),
          titleSmall: textThemeBase.titleSmall
              ?.copyWith(color: textThemeColors.secondary),
          bodyLarge:
              textThemeBase.bodyLarge?.copyWith(color: textThemeColors.primary),
          bodyMedium: textThemeBase.bodyMedium
              ?.copyWith(color: textThemeColors.secondary),
          bodySmall: textThemeBase.bodySmall
              ?.copyWith(color: textThemeColors.disabled),
          labelLarge: textThemeBase.labelLarge
              ?.copyWith(color: textThemeColors.primary),
          labelMedium: textThemeBase.labelMedium
              ?.copyWith(color: textThemeColors.primary),
          labelSmall: textThemeBase.labelSmall
              ?.copyWith(color: textThemeColors.primary),
        )
        .apply(
          // Apply overall display/body colors
          displayColor: textThemeColors.primary,
          bodyColor: textThemeColors.primary,
        );

    // Use appropriate base theme
    final baseTheme = isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    // --- Build the ThemeData ---
    return baseTheme.copyWith(
      brightness: brightness,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: colorScheme.background,
      canvasColor: isDark ? colorScheme.surface : colorScheme.background,
      cardColor: isDark ? colorScheme.surfaceContainer : colorScheme.surface,
      dividerColor: colorScheme.outlineVariant,
      hintColor: textThemeColors.disabled,
      colorScheme: colorScheme,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: iconColors.primary, size: 24),
      primaryIconTheme: IconThemeData(color: colorScheme.onPrimary),
      appBarTheme: AppBarTheme(
        elevation: isDark ? 0 : 1,
        scrolledUnderElevation: isDark ? 0 : 2,
        // Use surface for dark, primary for light AppBar background
        backgroundColor: isDark ? colorScheme.surface : colorScheme.primary,
        foregroundColor: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
        iconTheme: IconThemeData(
            color:
                isDark ? colorScheme.onSurfaceVariant : colorScheme.onPrimary),
        titleTextStyle: _AppTextStyles.titleLarge.copyWith(
            color: isDark ? colorScheme.onSurface : colorScheme.onPrimary),
        centerTitle: true,
        surfaceTintColor: isDark
            ? Colors.transparent
            : colorScheme.surfaceTint, // No tint for dark AppBar
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: _AppTextStyles
              .labelLarge, // Use base style, color comes from foregroundColor
          padding: _buttonPadding,
          shape: _buttonShape,
          elevation: 1,
          shadowColor: Colors.transparent,
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed))
              return colorScheme.onPrimary.withOpacity(0.12);
            if (states.contains(MaterialState.hovered))
              return colorScheme.onPrimary.withOpacity(0.08);
            return null;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: _AppTextStyles.labelLarge, // Use base style
          // Dark uses outline color, Light uses primary color for border
          side: BorderSide(
              color: isDark ? colorScheme.outline : colorScheme.primary,
              width: 1.5),
          padding: _buttonPadding,
          shape: _buttonShape,
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed))
              return colorScheme.primary.withOpacity(0.12);
            if (states.contains(MaterialState.hovered))
              return colorScheme.primary.withOpacity(0.08);
            return null;
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: _AppTextStyles.labelLarge, // Use base style
          padding: _buttonPadding,
          shape: _buttonShape,
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed))
              return colorScheme.primary.withOpacity(0.12);
            if (states.contains(MaterialState.hovered))
              return colorScheme.primary.withOpacity(0.08);
            return null;
          }),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3,
        highlightElevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // Use different fill colors for better contrast in each mode
        fillColor: isDark
            ? colorScheme.surfaceContainer
            : colorScheme.surfaceContainerHighest.withOpacity(0.5),
        hintStyle:
            _AppTextStyles.bodyLarge?.copyWith(color: textThemeColors.disabled),
        // Apply label color explicitly
        labelStyle: _AppTextStyles.bodyLarge
            ?.copyWith(color: colorScheme.onSurfaceVariant),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          // Light mode might not need a visible border when unfocused
          borderSide:
              isDark ? BorderSide(color: colorScheme.outline) : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: colorScheme.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: colorScheme.error, width: 2.0),
        ),
        border: OutlineInputBorder(
          // Default state
          borderRadius: BorderRadius.circular(10.0),
          borderSide:
              isDark ? BorderSide(color: colorScheme.outline) : BorderSide.none,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        disabledColor: colorScheme.onSurface.withOpacity(0.12),
        selectedColor: colorScheme.secondaryContainer,
        secondarySelectedColor: colorScheme.primaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        // Apply correct label color
        labelStyle: _AppTextStyles.labelLarge
            ?.copyWith(color: colorScheme.onSurfaceVariant),
        secondaryLabelStyle: _AppTextStyles.labelLarge
            ?.copyWith(color: colorScheme.onSecondaryContainer),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: colorScheme.outlineVariant), // Subtle border
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 18),
        elevation: 0,
        pressElevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        // Dark uses container bg, Light uses primary bg
        backgroundColor:
            isDark ? colorScheme.surfaceContainer : colorScheme.primary,
        selectedItemColor:
            isDark ? colorScheme.onSurface : colorScheme.onPrimary,
        unselectedItemColor: isDark
            ? colorScheme.onSurfaceVariant
            : colorScheme.onPrimary.withOpacity(0.7),
        // Apply correct label styles
        selectedLabelStyle: _AppTextStyles.labelMedium?.copyWith(
            color: isDark ? colorScheme.onSurface : colorScheme.onPrimary),
        unselectedLabelStyle: _AppTextStyles.labelMedium?.copyWith(
            color: isDark
                ? colorScheme.onSurfaceVariant
                : colorScheme.onPrimary.withOpacity(0.7)),
        elevation: 2,
        type: BottomNavigationBarType.fixed,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      ),
      visualDensity: VisualDensity.standard,
      useMaterial3: true,
      pageTransitionsTheme: _pageTransitionsTheme,
    );
  }
}

// Helper classes for organizing colors passed to the builder
class _ThemeTextColors {
  final Color primary;
  final Color secondary;
  final Color disabled;
  const _ThemeTextColors(
      {required this.primary, required this.secondary, required this.disabled});
}

class _ThemeIconColors {
  final Color primary;
  final Color onPrimary; // Icon on primary color surfaces (buttons, FABs)
  const _ThemeIconColors({required this.primary, required this.onPrimary});
}

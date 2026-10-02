import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static final light = _build(Brightness.light);
  static final dark = _build(Brightness.dark);

  static const radius = 18.0;

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final sufra = isDark ? SufraColors.dark : SufraColors.light;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.ember,
      onPrimary: Colors.white,
      primaryContainer: sufra.softAccent,
      onPrimaryContainer: sufra.link,
      secondary: AppColors.saffron,
      onSecondary: AppColors.ink,
      tertiary: AppColors.mint,
      onTertiary: AppColors.onMint,
      error: isDark ? const Color(0xFFFF8A80) : const Color(0xFFB3261E),
      onError: isDark ? AppColors.night : Colors.white,
      surface: isDark ? AppColors.darkSurface : Colors.white,
      onSurface: isDark ? AppColors.darkText : AppColors.ink,
      onSurfaceVariant: sufra.muted,
      surfaceContainerHighest: isDark ? AppColors.darkSurfaceHigh : AppColors.cream,
      outline: sufra.border,
      outlineVariant: sufra.border,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    // Alexandria for headings, IBM Plex Sans Arabic for body — both cover Arabic + Latin.
    final body = GoogleFonts.ibmPlexSansArabicTextTheme(base.textTheme);
    TextStyle? heading(TextStyle? s) =>
        GoogleFonts.alexandria(textStyle: s, fontWeight: FontWeight.w700);
    final textTheme = body
        .copyWith(
          displayLarge: heading(body.displayLarge),
          displayMedium: heading(body.displayMedium),
          displaySmall: heading(body.displaySmall),
          headlineLarge: heading(body.headlineLarge),
          headlineMedium: heading(body.headlineMedium),
          headlineSmall: heading(body.headlineSmall),
          titleLarge: heading(body.titleLarge),
          titleMedium: body.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          labelLarge: body.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        )
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    OutlineInputBorder inputBorder(Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );

    return base.copyWith(
      scaffoldBackgroundColor: isDark ? AppColors.night : AppColors.cream,
      textTheme: textTheme,
      extensions: [sufra],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.headlineSmall?.copyWith(fontSize: 24),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ember,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          textStyle: textTheme.titleMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: sufra.link,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: sufra.inputFill,
        hintStyle: textTheme.bodyLarge?.copyWith(color: sufra.muted),
        prefixIconColor: sufra.muted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: inputBorder(sufra.border),
        enabledBorder: inputBorder(sufra.border),
        focusedBorder: inputBorder(AppColors.ember, 1.5),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: AppColors.ember,
          selectedForegroundColor: Colors.white,
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: sufra.border),
          textStyle: textTheme.labelLarge,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: DividerThemeData(color: sufra.border, space: 1),
    );
  }
}

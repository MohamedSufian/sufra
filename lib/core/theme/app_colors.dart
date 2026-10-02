import 'package:material_ui/material_ui.dart';

/// Brand palette — matches the Sufra design canvas.
abstract final class AppColors {
  static const coral = Color(0xFFFF5A36); // brand, icons, large shapes
  static const ember = Color(0xFFD7401B); // buttons and fills under white text
  static const saffron = Color(0xFFFFB627); // ratings, offers
  static const mint = Color(0xFF2EC4B6); // order status, "open"
  static const onMint = Color(0xFF06302C);
  static const night = Color(0xFF0F0F14); // dark background
  static const cream = Color(0xFFFAF7F5); // light background
  static const ink = Color(0xFF1C1714);

  static const lightMuted = Color(0xFF6B625C);
  static const lightBorder = Color(0xFFEFE8E3);
  static const lightSoft = Color(0xFFFFE7DE);
  static const lightLink = Color(0xFFB83616);

  static const darkSurface = Color(0xFF1A1A22);
  static const darkSurfaceHigh = Color(0xFF22222C);
  static const darkBorder = Color(0xFF2A2A35);
  static const darkText = Color(0xFFF5F2EE);
  static const darkMuted = Color(0xFFA39DAA);
  static const darkSoft = Color(0xFF2A1A16);
  static const darkLink = Color(0xFFFF8A6B);
}

/// Semantic colors Material's ColorScheme has no slot for.
@immutable
class SufraColors extends ThemeExtension<SufraColors> {
  const SufraColors({
    required this.muted,
    required this.border,
    required this.softAccent,
    required this.link,
    required this.navBackground,
    required this.navBorder,
    required this.navInactive,
    required this.inputFill,
    required this.contrastButton,
    required this.onContrastButton,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  final Color muted;
  final Color border;
  final Color softAccent;
  final Color link;
  final Color navBackground;
  final Color navBorder;
  final Color navInactive;
  final Color inputFill;
  final Color contrastButton;
  final Color onContrastButton;
  final Color shimmerBase;
  final Color shimmerHighlight;

  static const light = SufraColors(
    muted: AppColors.lightMuted,
    border: AppColors.lightBorder,
    softAccent: AppColors.lightSoft,
    link: AppColors.lightLink,
    navBackground: AppColors.ink,
    navBorder: AppColors.ink,
    navInactive: Color(0xFFCFC7C1),
    inputFill: Colors.white,
    contrastButton: AppColors.ink,
    onContrastButton: Colors.white,
    shimmerBase: Color(0xFFEFE8E3),
    shimmerHighlight: Color(0xFFFAF7F5),
  );

  static const dark = SufraColors(
    muted: AppColors.darkMuted,
    border: AppColors.darkBorder,
    softAccent: AppColors.darkSoft,
    link: AppColors.darkLink,
    navBackground: AppColors.darkSurfaceHigh,
    navBorder: Color(0xFF31313D),
    navInactive: AppColors.darkMuted,
    inputFill: AppColors.darkSurface,
    contrastButton: AppColors.darkText,
    onContrastButton: AppColors.night,
    shimmerBase: AppColors.darkSurfaceHigh,
    shimmerHighlight: Color(0xFF2E2E3A),
  );

  @override
  SufraColors copyWith() => this;

  @override
  SufraColors lerp(ThemeExtension<SufraColors>? other, double t) {
    if (other is! SufraColors) return this;
    return t < 0.5 ? this : other;
  }
}

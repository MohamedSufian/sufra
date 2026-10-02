import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../core/settings/settings_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/context_x.dart';
import '../../core/widgets/sufra_logo.dart';

/// Picks up where the native splash (same ember + white tile) leaves off.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      final seen = ref.read(settingsProvider).onboardingSeen;
      context.go(seen ? AppRoutes.home : AppRoutes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.ember,
        body: Stack(
          alignment: Alignment.center,
          children: [
            for (final (i, size) in [640.0, 460.0, 300.0].indexed)
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == 2 ? Colors.white.withValues(alpha: 0.07) : null,
                  border: i == 2 ? null : Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
              ).animate().fadeIn(delay: (150 * i).ms, duration: 600.ms).scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    delay: (150 * i).ms,
                    duration: 900.ms,
                    curve: Curves.easeOutCubic,
                  ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3C0C00).withValues(alpha: 0.35),
                        blurRadius: 50,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const SufraLogo(size: 88, color: AppColors.coral, cutColor: Colors.white),
                ).animate().scale(
                      begin: const Offset(0.62, 0.62),
                      end: const Offset(1, 1),
                      duration: 900.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 32),
                Text(
                  'سُفرة',
                  style: GoogleFonts.alexandria(
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ).animate().fadeIn(delay: 350.ms, duration: 500.ms).slideY(begin: 0.3, end: 0),
                const SizedBox(height: 8),
                Text(
                  'SUFRA',
                  style: GoogleFonts.alexandria(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 6.5,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(delay: 550.ms, duration: 500.ms),
              ],
            ),
            PositionedDirectional(
              start: 0,
              end: 0,
              bottom: 64,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < 3; i++)
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .fade(begin: 0.3, end: 1, delay: (180 * i).ms, duration: 500.ms),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    context.l10n.splashTagline,
                    style: context.text.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ).animate().fadeIn(delay: 800.ms, duration: 500.ms),
            ),
          ],
        ),
      ),
    );
  }
}

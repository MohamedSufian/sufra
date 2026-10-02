import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/settings/settings_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/context_x.dart';
import '../../core/widgets/plate_art.dart';
import '../../core/widgets/sufra_logo.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  var _page = 0;

  static const _pageCount = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(settingsProvider.notifier).completeOnboarding();
    if (mounted) context.go(AppRoutes.home);
  }

  void _next() {
    if (_page == _pageCount - 1) {
      _finish();
    } else {
      _controller.nextPage(duration: 400.ms, curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pages = [
      (l10n.onboardingTitle1, l10n.onboardingBody1, const _PlateIllustration()),
      (l10n.onboardingTitle2, l10n.onboardingBody2, const _PinIllustration()),
      (l10n.onboardingTitle3, l10n.onboardingBody3, const _RiderIllustration()),
    ];
    final isLast = _page == _pageCount - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _LanguageToggle(),
                  AnimatedOpacity(
                    opacity: isLast ? 0 : 1,
                    duration: 200.ms,
                    child: TextButton(onPressed: isLast ? null : _finish, child: Text(l10n.skip)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pageCount,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final (title, body, art) = pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        art,
                        const SizedBox(height: 48),
                        Text(title, style: context.text.headlineSmall, textAlign: TextAlign.center)
                            .animate(key: ValueKey('t$i'))
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 14),
                        Text(
                          body,
                          textAlign: TextAlign.center,
                          style: context.text.bodyLarge?.copyWith(color: context.sufra.muted, height: 1.6),
                        ).animate(key: ValueKey('b$i')).fadeIn(delay: 120.ms, duration: 400.ms),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  for (var i = 0; i < _pageCount; i++)
                    AnimatedContainer(
                      duration: 300.ms,
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsetsDirectional.only(end: 6),
                      width: i == _page ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page ? AppColors.ember : context.sufra.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _next,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 28)),
                    child: AnimatedSwitcher(
                      duration: 200.ms,
                      child: Text(isLast ? l10n.getStarted : l10n.next, key: ValueKey(isLast)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageToggle extends ConsumerWidget {
  const _LanguageToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = context.locale.languageCode == 'ar';
    return Semantics(
      button: true,
      label: isArabic ? 'Switch to English' : 'التبديل إلى العربية',
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => ref.read(settingsProvider.notifier).setLocale(Locale(isArabic ? 'en' : 'ar')),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: context.sufra.border),
            borderRadius: BorderRadius.circular(999),
            color: context.colors.surface,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.translate_rounded, size: 18, color: context.sufra.muted),
              const SizedBox(width: 8),
              Text(isArabic ? 'English' : 'العربية', style: context.text.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(color: context.sufra.softAccent, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: child,
    ).animate().scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1), duration: 500.ms, curve: Curves.easeOutBack);
  }
}

class _PlateIllustration extends StatelessWidget {
  const _PlateIllustration();

  @override
  Widget build(BuildContext context) {
    return _Backdrop(
      child: PlateArt(palette: PlatePalette.of(0), size: 200)
          .animate(onPlay: (c) => c.repeat())
          .rotate(duration: 30.seconds),
    );
  }
}

class _PinIllustration extends StatelessWidget {
  const _PinIllustration();

  @override
  Widget build(BuildContext context) {
    return _Backdrop(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SufraLogo(size: 130, color: AppColors.coral, cutColor: null)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -14, duration: 900.ms, curve: Curves.easeInOut),
          Container(
            width: 70,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiderIllustration extends StatelessWidget {
  const _RiderIllustration();

  @override
  Widget build(BuildContext context) {
    return _Backdrop(
      child: Container(
        width: 150,
        height: 150,
        decoration: const BoxDecoration(color: AppColors.ember, shape: BoxShape.circle),
        child: const Icon(Icons.delivery_dining_rounded, size: 88, color: Colors.white),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveX(begin: -8, end: 8, duration: 1200.ms, curve: Curves.easeInOut),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../core/backend/backend.dart';
import '../../core/router/app_router.dart';
import '../../core/settings/settings_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/context_x.dart';
import '../../core/widgets/sufra_logo.dart';
import '../address/addresses_controller.dart';
import '../auth/auth.dart';
import '../home/presentation/home_screen.dart';
import '../orders/orders_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final user = ref.watch(currentUserProvider);
    final demo = ref.watch(supabaseProvider) == null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProfile)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, HomeScreen.bottomInset),
        children: [
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(color: context.sufra.softAccent, borderRadius: BorderRadius.circular(18)),
                      child: Icon(Icons.person_rounded, size: 30, color: context.isDark ? AppColors.darkLink : AppColors.ember),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user == null ? l10n.guestTitle : l10n.signedIn, style: context.text.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? (demo ? l10n.demoMode : l10n.guestBody),
                            style: context.text.bodyMedium?.copyWith(color: context.sufra.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: user == null
                      ? FilledButton(
                          onPressed: demo ? null : () => context.push(AppRoutes.signIn),
                          child: Text(l10n.signIn),
                        )
                      : OutlinedButton.icon(
                          onPressed: () async {
                            await ref.read(authServiceProvider)?.signOut();
                            // This device shouldn't keep the account's addresses and orders.
                            ref.read(addressesProvider.notifier).clearLocal();
                            ref.read(ordersProvider.notifier).clearLocal();
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            foregroundColor: context.colors.error,
                            side: BorderSide(color: context.sufra.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          icon: const Icon(Icons.logout_rounded),
                          label: Text(l10n.signOut),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.settings, style: context.text.titleLarge?.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label(icon: Icons.translate_rounded, text: l10n.language),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(value: 'system', label: Text(l10n.languageSystem)),
                      const ButtonSegment(value: 'ar', label: Text('العربية')),
                      const ButtonSegment(value: 'en', label: Text('English')),
                    ],
                    selected: {settings.locale?.languageCode ?? 'system'},
                    onSelectionChanged: (s) =>
                        controller.setLocale(s.first == 'system' ? null : Locale(s.first)),
                  ),
                ),
                const SizedBox(height: 20),
                _Label(icon: Icons.contrast_rounded, text: l10n.theme),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(value: ThemeMode.system, label: Text(l10n.themeSystem)),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: const Icon(Icons.light_mode_rounded, size: 18),
                        label: Text(l10n.themeLight),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: const Icon(Icons.dark_mode_rounded, size: 18),
                        label: Text(l10n.themeDark),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (s) => controller.setThemeMode(s.first),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              const SufraLogo(size: 36, color: AppColors.coral),
              const SizedBox(height: 8),
              Text(l10n.madeInGaza, style: context.text.bodyMedium?.copyWith(color: context.sufra.muted)),
              Text('v1.0.0', style: context.text.bodySmall?.copyWith(color: context.sufra.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.sufra.border),
      ),
      child: child,
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.sufra.muted),
        const SizedBox(width: 8),
        Text(text, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

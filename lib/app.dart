import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/settings/settings_controller.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

class SufraApp extends ConsumerWidget {
  const SufraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      // material_ui's delegates, not flutter_localizations' (those target the legacy Material types).
      localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
      // Unsupported device languages fall back to Arabic.
      localeResolutionCallback: (device, supported) => supported.firstWhere(
        (l) => l.languageCode == device?.languageCode,
        orElse: () => const Locale('ar'),
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}

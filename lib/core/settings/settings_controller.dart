import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overridden in main() with the loaded instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

@immutable
class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.locale,
    required this.onboardingSeen,
  });

  final ThemeMode themeMode;

  /// null → follow the device language.
  final Locale? locale;
  final bool onboardingSeen;
}

class SettingsController extends Notifier<AppSettings> {
  static const _themeKey = 'settings.themeMode';
  static const _localeKey = 'settings.locale';
  static const _onboardingKey = 'settings.onboardingSeen';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final code = prefs.getString(_localeKey);
    return AppSettings(
      themeMode: ThemeMode.values.asNameMap()[prefs.getString(_themeKey)] ?? ThemeMode.system,
      locale: code == null ? null : Locale(code),
      onboardingSeen: prefs.getBool(_onboardingKey) ?? false,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = AppSettings(themeMode: mode, locale: state.locale, onboardingSeen: state.onboardingSeen);
    await _prefs.setString(_themeKey, mode.name);
  }

  Future<void> setLocale(Locale? locale) async {
    state = AppSettings(themeMode: state.themeMode, locale: locale, onboardingSeen: state.onboardingSeen);
    if (locale == null) {
      await _prefs.remove(_localeKey);
    } else {
      await _prefs.setString(_localeKey, locale.languageCode);
    }
  }

  Future<void> completeOnboarding() async {
    state = AppSettings(themeMode: state.themeMode, locale: state.locale, onboardingSeen: true);
    await _prefs.setBool(_onboardingKey, true);
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sufra/core/settings/settings_controller.dart';
import 'package:sufra/features/home/data/restaurants_repository.dart';
import 'package:sufra/features/home/domain/models.dart';
import 'package:sufra/features/home/presentation/home_providers.dart';

Future<ProviderContainer> makeContainer([Map<String, Object> prefs = const {}]) async {
  SharedPreferences.setMockInitialValues(prefs);
  final instance = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(instance)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('SettingsController', () {
    test('defaults to device theme, device language, onboarding not seen', () async {
      final c = await makeContainer();
      final s = c.read(settingsProvider);
      expect(s.themeMode, ThemeMode.system);
      expect(s.locale, isNull);
      expect(s.onboardingSeen, isFalse);
    });

    test('persists theme, language and onboarding', () async {
      final c = await makeContainer();
      final n = c.read(settingsProvider.notifier);
      await n.setThemeMode(ThemeMode.dark);
      await n.setLocale(const Locale('en'));
      await n.completeOnboarding();

      final prefs = c.read(sharedPreferencesProvider);
      final fresh = await makeContainer({
        for (final k in prefs.getKeys()) k: prefs.get(k)!,
      });
      final s = fresh.read(settingsProvider);
      expect(s.themeMode, ThemeMode.dark);
      expect(s.locale, const Locale('en'));
      expect(s.onboardingSeen, isTrue);
    });
  });

  group('restaurants', () {
    final repo = FakeRestaurantsRepository(delay: Duration.zero);

    test('filters by category and by search text in either language', () async {
      final all = await repo.fetchRestaurants();
      expect(filterRestaurants(all, FoodCategory.allId, ''), hasLength(all.length));
      expect(filterRestaurants(all, 'sweets', '').map((r) => r.id), ['rimal-knafeh']);
      expect(filterRestaurants(all, FoodCategory.allId, 'فلافل').map((r) => r.id), ['shati-falafel']);
      expect(filterRestaurants(all, FoodCategory.allId, 'PIZZA').map((r) => r.id), ['talhawa-pizza']);
      expect(filterRestaurants(all, 'sweets', 'pizza'), isEmpty);
    });

    test('favorites toggle and persist', () async {
      final c = await makeContainer();
      c.read(favoritesProvider.notifier).toggle('bahr-grill');
      expect(c.read(favoritesProvider), {'bahr-grill'});
      c.read(favoritesProvider.notifier).toggle('bahr-grill');
      expect(c.read(favoritesProvider), isEmpty);
    });
  });
}

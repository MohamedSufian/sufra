// Overflow regressions: any "overflowed by N pixels" during layout fails these tests.
// Small phone width and enlarged system text are where fixed heights break.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sufra/core/settings/settings_controller.dart';
import 'package:sufra/core/theme/app_theme.dart';
import 'package:sufra/features/cart/cart_controller.dart';
import 'package:sufra/features/home/data/restaurants_repository.dart';
import 'package:sufra/features/home/domain/models.dart';
import 'package:sufra/features/home/presentation/widgets/home_sections.dart';
import 'package:sufra/features/restaurant/widgets/product_tile.dart';
import 'package:sufra/l10n/app_localizations.dart';

Future<void> pumpAt(
  WidgetTester tester,
  Widget child, {
  required Size size,
  double textScale = 1,
  String locale = 'ar',
  void Function(ProviderContainer)? setUp,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
  addTearDown(container.dispose);
  setUp?.call(container);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: AppTheme.light,
      locale: Locale(locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
      home: MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: Scaffold(body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: child)),
      ),
    ),
  ));
  await tester.pump(const Duration(seconds: 2)); // let entrance animations settle
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false); // fonts come from assets/google_fonts

  late List<Product> menu;
  setUpAll(() async {
    menu = (await FakeRestaurantsRepository(delay: Duration.zero).fetchMenu('bahr-grill')).products;
  });

  for (final (label, size, scale) in [
    ('small phone', const Size(320, 640), 1.0),
    ('small phone, large text', const Size(320, 640), 1.3),
    ('regular phone, largest text', const Size(390, 844), 1.5),
  ]) {
    group(label, () {
      testWidgets('the weekly offer banner fits its text', (tester) async {
        await pumpAt(tester, const PromoBanner(), size: size, textScale: scale);
        expect(tester.takeException(), isNull);
        expect(find.byType(PromoBanner), findsOneWidget);
      });

      testWidgets('a dish with the − 1 + stepper showing fits', (tester) async {
        // Kebab: a two-line description and no options, so "+" turns into the stepper.
        final kebab = menu.firstWhere((p) => p.id == 'bahr-grill.kebab');
        await pumpAt(
          tester,
          ProductTile(product: kebab, canOrder: true),
          size: size,
          textScale: scale,
          setUp: (c) => c.read(cartProvider.notifier).add(kebab),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('1'), findsOneWidget); // the stepper is the state under test
      });
    });
  }
}

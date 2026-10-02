import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sufra/core/settings/settings_controller.dart';
import 'package:sufra/features/cart/cart_controller.dart';
import 'package:sufra/features/home/data/restaurants_repository.dart';
import 'package:sufra/features/home/domain/models.dart';

Future<ProviderContainer> makeContainer([Map<String, Object> prefs = const {}]) async {
  SharedPreferences.setMockInitialValues(prefs);
  final instance = await SharedPreferences.getInstance();
  final container = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(instance)]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  final repo = FakeRestaurantsRepository(delay: Duration.zero);
  late List<Product> grill;
  late List<Product> knafeh;

  setUpAll(() async {
    grill = (await repo.fetchMenu('bahr-grill')).products;
    knafeh = (await repo.fetchMenu('rimal-knafeh')).products;
  });

  test('adds, counts and totals dishes', () async {
    final c = await makeContainer();
    final cart = c.read(cartProvider.notifier);
    cart.add(grill[0]); // 45
    cart.add(grill[0]);
    cart.add(grill[1]); // 35
    final s = c.read(cartProvider);
    expect(s.restaurantId, 'bahr-grill');
    expect(s.itemCount, 3);
    expect(s.subtotal, 45 * 2 + 35);
    expect(s.quantityOf(grill[0].id), 2);
  });

  test('decrement removes the line at zero and empties the cart with the last one', () async {
    final c = await makeContainer();
    final cart = c.read(cartProvider.notifier);
    cart.add(grill[0]);
    cart.add(grill[0]);
    cart.decrementLine(CartLine.keyFor(grill[0].id));
    expect(c.read(cartProvider).quantityOf(grill[0].id), 1);
    cart.decrementLine(CartLine.keyFor(grill[0].id));
    expect(c.read(cartProvider).isEmpty, isTrue);
    expect(c.read(cartProvider).restaurantId, isNull);
  });

  test('a dish from another restaurant conflicts and starts a new cart', () async {
    final c = await makeContainer();
    final cart = c.read(cartProvider.notifier);
    cart.add(grill[0]);
    expect(cart.conflictsWith(grill[1]), isFalse);
    expect(cart.conflictsWith(knafeh[0]), isTrue);
    cart.add(knafeh[0]);
    final s = c.read(cartProvider);
    expect(s.restaurantId, 'rimal-knafeh');
    expect(s.lines.map((l) => l.product.id), [knafeh[0].id]);
  });

  test('cart survives an app restart', () async {
    final c = await makeContainer();
    c.read(cartProvider.notifier)
      ..add(grill[0])
      ..add(grill[2]);
    final prefs = c.read(sharedPreferencesProvider);
    final restarted = await makeContainer({for (final k in prefs.getKeys()) k: prefs.get(k)!});
    final s = restarted.read(cartProvider);
    expect(s.itemCount, 2);
    expect(s.lines.first.product.name.ar, grill[0].name.ar);
  });

  test('a corrupt saved cart is dropped instead of crashing', () async {
    final c = await makeContainer({'cart.v1': '{not json'});
    expect(c.read(cartProvider).isEmpty, isTrue);
  });

  group('options', () {
    late Product mix; // Mixed grill: size (required) + extras (up to 3)
    late OptionChoice family;
    late OptionChoice bread;
    late OptionChoice fries;

    setUp(() {
      mix = grill.firstWhere((p) => p.id == 'bahr-grill.mix');
      family = mix.optionGroups[0].choices.firstWhere((c) => c.id == 'size.family');
      bread = mix.optionGroups[1].choices.firstWhere((c) => c.id == 'extras.bread');
      fries = mix.optionGroups[1].choices.firstWhere((c) => c.id == 'extras.fries');
    });

    test('the menu exposes required and multi-choice groups', () {
      expect(mix.hasOptions, isTrue);
      expect(mix.optionGroups[0].isRequired, isTrue);
      expect(mix.optionGroups[0].isSingle, isTrue);
      expect(mix.optionGroups[1].maxSelections, 3);
    });

    test('price includes every chosen option, times the quantity', () async {
      final c = await makeContainer();
      c.read(cartProvider.notifier).add(mix, choices: [family, bread, fries], quantity: 2);
      final line = c.read(cartProvider).lines.single;
      expect(line.unitPrice, 45 + 40 + 2 + 6);
      expect(c.read(cartProvider).subtotal, (45 + 40 + 2 + 6) * 2);
    });

    test('same options in any order merge; other options or notes make new lines', () async {
      final c = await makeContainer();
      final cart = c.read(cartProvider.notifier);
      cart.add(mix, choices: [family, bread]);
      cart.add(mix, choices: [bread, family]);
      expect(c.read(cartProvider).lines, hasLength(1));
      expect(c.read(cartProvider).lines.single.quantity, 2);

      cart.add(mix, choices: [family]);
      cart.add(mix, choices: [family, bread], note: 'بدون بصل');
      expect(c.read(cartProvider).lines, hasLength(3));
      expect(c.read(cartProvider).quantityOf(mix.id), 4);
    });

    test('notes are trimmed so stray spaces do not split lines', () async {
      final c = await makeContainer();
      final cart = c.read(cartProvider.notifier);
      cart.add(mix, choices: [family], note: ' حار ');
      cart.add(mix, choices: [family], note: 'حار');
      expect(c.read(cartProvider).lines.single.quantity, 2);
      expect(c.read(cartProvider).lines.single.note, 'حار');
    });

    test('lines change one at a time by key', () async {
      final c = await makeContainer();
      final cart = c.read(cartProvider.notifier);
      cart.add(mix, choices: [family]);
      cart.add(mix);
      final familyKey = c.read(cartProvider).lines.first.key;
      cart.incrementLine(familyKey);
      cart.decrementLine(CartLine.keyFor(mix.id));
      final lines = c.read(cartProvider).lines;
      expect(lines, hasLength(1));
      expect(lines.single.quantity, 2);
      expect(lines.single.choices.single.id, 'size.family');
    });

    test('options and notes survive an app restart', () async {
      final c = await makeContainer();
      c.read(cartProvider.notifier).add(mix, choices: [family, fries], note: 'بدون بصل');
      final prefs = c.read(sharedPreferencesProvider);
      final restarted = await makeContainer({for (final k in prefs.getKeys()) k: prefs.get(k)!});
      final line = restarted.read(cartProvider).lines.single;
      expect(line.choices.map((c) => c.id), ['size.family', 'extras.fries']);
      expect(line.note, 'بدون بصل');
      expect(line.unitPrice, 45 + 40 + 6);
    });

    test('carts saved before options existed still load', () async {
      final old = '{"restaurantId":"bahr-grill","lines":[{"product":${jsonEncode(mix.toJson())},"quantity":2}]}';
      final c = await makeContainer({'cart.v1': old});
      final line = c.read(cartProvider).lines.single;
      expect(line.quantity, 2);
      expect(line.choices, isEmpty);
      expect(line.note, '');
    });
  });

  test('every restaurant has a menu whose dishes point back at it', () async {
    for (final r in await repo.fetchRestaurants()) {
      final menu = await repo.fetchMenu(r.id);
      expect(menu.isEmpty, isFalse, reason: r.id);
      final sectionIds = menu.sections.map((s) => s.id).toSet();
      for (final p in menu.products) {
        expect(p.restaurantId, r.id);
        expect(sectionIds, contains(p.sectionId));
      }
    }
  });
}

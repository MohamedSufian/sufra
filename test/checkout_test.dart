import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sufra/core/maps/gaza_areas.dart';
import 'package:sufra/core/settings/settings_controller.dart';
import 'package:sufra/core/utils/context_x.dart';
import 'package:sufra/features/address/address.dart';
import 'package:sufra/features/address/addresses_controller.dart';
import 'package:sufra/features/cart/cart_controller.dart';
import 'package:sufra/features/checkout/promo.dart';
import 'package:sufra/features/home/data/restaurants_repository.dart';
import 'package:sufra/features/home/domain/models.dart';
import 'package:sufra/features/orders/order.dart';
import 'package:sufra/features/orders/orders_controller.dart';

Future<ProviderContainer> makeContainer([Map<String, Object> prefs = const {}]) async {
  SharedPreferences.setMockInitialValues(prefs);
  final instance = await SharedPreferences.getInstance();
  final container = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(instance)]);
  addTearDown(container.dispose);
  return container;
}

Future<ProviderContainer> restart(ProviderContainer c) {
  final prefs = c.read(sharedPreferencesProvider);
  return makeContainer({for (final k in prefs.getKeys()) k: prefs.get(k)!});
}

SavedAddress address(String id, {AddressLabel label = AddressLabel.home}) => SavedAddress(
  id: id,
  label: label,
  latitude: 31.523,
  longitude: 34.444,
  area: const LocalizedText(ar: 'الرمال، غزة', en: 'Al-Rimal, Gaza'),
  landmark: 'قرب مسجد العمري',
  phone: '0591234567',
);

void main() {
  test('dates use the same 123 digits as the rest of the app', () {
    expect(latinDigits('٢ أكتوبر ١:٤٤ ص'), '2 أكتوبر 1:44 ص');
    expect(latinDigits('Oct 2, 1:44 AM'), 'Oct 2, 1:44 AM');
  });

  group('phone numbers', () {
    test('accepts Jawwal and Ooredoo mobiles, with or without the country code', () {
      for (final ok in ['0591234567', '0561234567', '059 123 4567', '059-123-4567', '+970591234567', '00972561234567']) {
        expect(PhoneNumbers.isValidMobile(ok), isTrue, reason: ok);
      }
    });

    test('rejects landlines, other prefixes and wrong lengths', () {
      for (final bad in ['', '082345678', '0521234567', '059123456', '05912345678', 'abc0591234567']) {
        expect(PhoneNumbers.isValidMobile(bad), isFalse, reason: bad);
      }
    });
  });

  group('Gaza areas', () {
    test('a pin snaps to the nearest neighborhood', () {
      expect(GazaAreas.nearest(31.5232, 34.4445)?.name.en, 'Al-Rimal, Gaza');
      expect(GazaAreas.nearest(31.3470, 34.3050)?.name.en, 'Khan Younis');
    });

    test('points outside the Strip are outside the delivery zone', () {
      expect(GazaAreas.nearest(31.7683, 35.2137), isNull); // Jerusalem
      expect(GazaAreas.nearest(30.0444, 31.2357), isNull); // Cairo
    });

    test('distance is sane', () {
      final km = GazaAreas.distanceKm(31.5230, 34.4440, 31.2870, 34.2510);
      expect(km, inInclusiveRange(30, 33)); // Gaza City to Rafah
    });
  });

  group('promo codes', () {
    test('ignores case and spaces', () {
      expect(Promo.find(' sufra20 ')?.code, 'SUFRA20');
      expect(Promo.find('NOPE'), isNull);
    });

    test('20% off the food, rounded down and capped at ₪30', () {
      final p = Promo.find('SUFRA20')!;
      expect(p.discountOn(47), 9);
      expect(p.discountOn(100), 20);
      expect(p.discountOn(500), 30);
    });
  });

  group('addresses', () {
    test('saving selects the address; editing replaces it in place', () async {
      final c = await makeContainer();
      final book = c.read(addressesProvider.notifier);
      book.save(address('a'));
      book.save(address('b', label: AddressLabel.work));
      expect(c.read(addressesProvider).selected?.id, 'b');

      book.save(SavedAddress.fromJson({...address('a').toJson(), 'landmark': 'مقابل الصيدلية'}));
      final s = c.read(addressesProvider);
      expect(s.addresses.map((a) => a.id), ['a', 'b']);
      expect(s.selected?.landmark, 'مقابل الصيدلية');
    });

    test('deleting the selected address falls back to the first one', () async {
      final c = await makeContainer();
      final book = c.read(addressesProvider.notifier)
        ..save(address('a'))
        ..save(address('b'));
      book.delete('b');
      expect(c.read(addressesProvider).selected?.id, 'a');
    });

    test('survive an app restart', () async {
      final c = await makeContainer();
      c.read(addressesProvider.notifier).save(address('a', label: AddressLabel.work));
      final s = (await restart(c)).read(addressesProvider);
      expect(s.selected?.label, AddressLabel.work);
      expect(s.selected?.area.ar, 'الرمال، غزة');
    });
  });

  group('placing an order', () {
    late Restaurant grill;
    late List<Product> menu;

    setUpAll(() async {
      OrdersController.placeDelay = Duration.zero;
      final repo = FakeRestaurantsRepository(delay: Duration.zero);
      grill = (await repo.fetchRestaurants()).firstWhere((r) => r.id == 'bahr-grill');
      menu = (await repo.fetchMenu('bahr-grill')).products;
    });

    test('turns the cart into an order with totals, then empties the cart', () async {
      final c = await makeContainer();
      c.read(cartProvider.notifier)
        ..add(menu[1]) // 35
        ..add(menu[1]);
      final order = await c.read(ordersProvider.notifier).place(
        restaurant: grill,
        address: address('a'),
        payment: PaymentMethod.cash,
        promo: Promo.find('SUFRA20'),
      );
      expect(order.id, 1001);
      expect(order.subtotal, 70);
      expect(order.discount, 14);
      expect(order.deliveryFee, grill.deliveryFee);
      expect(order.total, 70 + grill.deliveryFee - 14);
      expect(order.status, OrderStatus.placed);
      expect(c.read(cartProvider).isEmpty, isTrue);
    });

    test('numbers orders in sequence, newest first, and keeps them after a restart', () async {
      final c = await makeContainer();
      for (var i = 0; i < 2; i++) {
        c.read(cartProvider.notifier).add(menu[0]);
        await c.read(ordersProvider.notifier).place(restaurant: grill, address: address('a'), payment: PaymentMethod.cash);
      }
      final orders = (await restart(c)).read(ordersProvider);
      expect(orders.map((o) => o.id), [1002, 1001]);
      expect(orders.first.lines.single.product.id, menu[0].id);
      expect(orders.first.address.landmark, 'قرب مسجد العمري');
    });

    test('refuses an empty cart', () async {
      final c = await makeContainer();
      expect(
        () => c.read(ordersProvider.notifier).place(restaurant: grill, address: address('a'), payment: PaymentMethod.cash),
        throwsStateError,
      );
    });
  });
}

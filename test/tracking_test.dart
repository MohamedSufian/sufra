import 'package:flutter_test/flutter_test.dart';
import 'package:sufra/core/maps/route_line.dart';
import 'package:sufra/features/address/address.dart';
import 'package:sufra/features/home/domain/models.dart';
import 'package:sufra/features/orders/order.dart';

PlacedOrder order({required DateTime placedAt, int etaMax = 30}) => PlacedOrder(
  id: 1001,
  restaurantId: 'bahr-grill',
  restaurantName: const LocalizedText(ar: 'مشاوي البحر', en: 'Al-Bahr Grill'),
  lines: const [],
  address: const SavedAddress(
    id: 'a',
    label: AddressLabel.home,
    latitude: 31.52,
    longitude: 34.46,
    area: LocalizedText(ar: 'الدرج', en: 'Ad-Daraj'),
    landmark: 'x',
    phone: '0591234567',
  ),
  payment: PaymentMethod.cash,
  subtotal: 50,
  deliveryFee: 5,
  discount: 0,
  placedAt: placedAt,
  etaMinMinutes: etaMax - 10,
  etaMaxMinutes: etaMax,
);

void main() {
  final t0 = DateTime(2026, 10, 2, 12);

  /// The moment [simulatedMinutes] of order time have passed.
  DateTime after(double simulatedMinutes) =>
      t0.add(Duration(milliseconds: (simulatedMinutes / OrderSimulation.timeScale * 60000).round()));

  group('order progress (30 min delivery)', () {
    final o = order(placedAt: t0);

    test('starts as placed with the full time left', () {
      final p = o.progressAt(t0);
      expect(p.status, OrderStatus.placed);
      expect(p.minutesLeft, 30);
      expect(p.riderProgress, 0);
    });

    test('the restaurant accepts, then cooks until the rider leaves', () {
      expect(o.progressAt(after(2)).status, OrderStatus.preparing);
      expect(o.progressAt(after(13)).status, OrderStatus.preparing); // leaves at 45% = 13.5
      expect(o.progressAt(after(14)).status, OrderStatus.onTheWay);
    });

    test('the rider moves steadily and arrives at the delivery time', () {
      final halfway = o.progressAt(after(13.5 + 16.5 / 2));
      expect(halfway.status, OrderStatus.onTheWay);
      expect(halfway.riderProgress, closeTo(0.5, 0.01));
      expect(halfway.minutesLeft, 9);

      final done = o.progressAt(after(30));
      expect(done.status, OrderStatus.delivered);
      expect(done.riderProgress, 1);
      expect(done.minutesLeft, 0);
    });

    test('a clock before the order (device time change) reads as just placed', () {
      expect(o.progressAt(t0.subtract(const Duration(minutes: 5))).status, OrderStatus.placed);
    });
  });

  test('the whole journey takes etaMax / timeScale real minutes', () {
    final o = order(placedAt: t0, etaMax: 36);
    final realMinutes = 36 / OrderSimulation.timeScale;
    expect(o.progressAt(t0.add(Duration(seconds: (realMinutes * 60).round() - 1))).status, OrderStatus.onTheWay);
    expect(o.progressAt(t0.add(Duration(seconds: (realMinutes * 60).round()))).status, OrderStatus.delivered);
  });

  test('restaurant coordinates survive JSON, and older orders without them still load', () {
    final o = order(placedAt: t0);
    final withCoords = PlacedOrder.fromJson({...o.toJson(), 'restaurantLat': 31.524, 'restaurantLng': 34.442});
    expect(withCoords.restaurantLatitude, 31.524);
    final legacy = PlacedOrder.fromJson(o.toJson()..remove('restaurantLat')..remove('restaurantLng'));
    expect(legacy.restaurantLatitude, isNull);
  });

  group('route', () {
    const from = (latitude: 31.524, longitude: 34.442);
    const to = (latitude: 31.518, longitude: 34.464);
    final route = curvedRoute(from, to);

    test('runs from the restaurant to the door and bends away from the straight line', () {
      expect(route.first, from);
      expect(route.last, to);
      final mid = route[route.length ~/ 2];
      final straightMid = ((from.latitude + to.latitude) / 2, (from.longitude + to.longitude) / 2);
      expect((mid.latitude - straightMid.$1).abs() + (mid.longitude - straightMid.$2).abs(), greaterThan(0.001));
    });

    test('splitting puts the rider on the route and shares that point between both halves', () {
      for (final p in [0.0, 0.33, 0.5, 1.0]) {
        final s = splitRoute(route, p);
        expect(s.done.last, s.at);
        expect(s.ahead.first, s.at);
        expect(s.done.length + s.ahead.length, route.length + 2);
      }
      expect(splitRoute(route, 0).at, from);
      expect(splitRoute(route, 1).at, to);
    });
  });
}

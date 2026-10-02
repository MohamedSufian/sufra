import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/backend/backend.dart';
import '../../core/settings/settings_controller.dart';
import '../address/address.dart';
import '../auth/auth.dart';
import '../cart/cart_controller.dart';
import '../checkout/promo.dart';
import '../home/domain/models.dart';
import 'order.dart';

/// Ordering needs an account once the backend is connected.
class SignInRequired implements Exception {
  const SignInRequired();
}

/// Newest first. With Supabase, orders live in the account and are created by the place_order()
/// database function; in demo mode they stay on the device.
class OrdersController extends Notifier<List<PlacedOrder>> {
  static const _key = 'orders.v1';
  static const _firstId = 1001;

  /// Demo mode only: stands in for the network round trip.
  static Duration placeDelay = const Duration(milliseconds: 1200);

  @override
  List<PlacedOrder> build() {
    final signedIn = ref.watch(currentUserProvider) != null;
    final db = ref.watch(supabaseProvider);
    if (signedIn && db != null) Future.microtask(() => _pull(db));
    return _readCache();
  }

  List<PlacedOrder> _readCache() {
    final raw = ref.read(sharedPreferencesProvider).getString(_key);
    if (raw == null) return const [];
    try {
      return [for (final o in (jsonDecode(raw) as List).cast<Map>()) PlacedOrder.fromJson(o.cast<String, Object?>())];
    } on Object {
      return const [];
    }
  }

  Future<void> _pull(SupabaseClient db) async {
    try {
      final rows = await db.from('orders').select().order('placed_at', ascending: false).limit(50);
      if (!ref.mounted) return;
      _set([for (final r in rows) OrderRows.order(r)]);
    } on Object {
      // Offline: the cached list stays until the next sync.
    }
  }

  /// Turns the cart into an order and empties the cart.
  /// Throws [SignInRequired] when the backend is connected and nobody is signed in.
  Future<PlacedOrder> place({
    required Restaurant restaurant,
    required SavedAddress address,
    required PaymentMethod payment,
    Promo? promo,
  }) async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty || cart.restaurantId != restaurant.id) {
      throw StateError('The cart does not hold dishes from ${restaurant.id}');
    }
    final db = ref.read(supabaseProvider);
    final order = db == null
        ? await _placeOnDevice(cart, restaurant, address, payment, promo)
        : await _placeOnServer(db, cart, restaurant, address, promo);
    _set([order, ...state]);
    ref.read(cartProvider.notifier).clear();
    return order;
  }

  Future<PlacedOrder> _placeOnServer(
    SupabaseClient db,
    CartState cart,
    Restaurant restaurant,
    SavedAddress address,
    Promo? promo,
  ) async {
    if (ref.read(currentUserProvider) == null) throw const SignInRequired();
    // The address may have been saved before signing in; the order references it.
    await db.from('addresses').upsert(address.toRow());
    final row = await db.rpc<Map<String, dynamic>>('place_order', params: {
      'p_restaurant_id': restaurant.id,
      'p_address_id': address.id,
      'p_lines': OrderRows.linesParam(cart),
      'p_promo_code': promo?.code,
    });
    return OrderRows.order(row);
  }

  Future<PlacedOrder> _placeOnDevice(
    CartState cart,
    Restaurant restaurant,
    SavedAddress address,
    PaymentMethod payment,
    Promo? promo,
  ) async {
    await Future<void>.delayed(placeDelay);
    return PlacedOrder(
      id: state.isEmpty ? _firstId : state.map((o) => o.id).reduce((a, b) => a > b ? a : b) + 1,
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      lines: cart.lines,
      address: address,
      payment: payment,
      subtotal: cart.subtotal,
      deliveryFee: restaurant.deliveryFee,
      discount: promo?.discountOn(cart.subtotal) ?? 0,
      promoCode: promo?.code,
      placedAt: DateTime.now(),
      etaMinMinutes: restaurant.deliveryMinMinutes,
      etaMaxMinutes: restaurant.deliveryMaxMinutes,
      restaurantLatitude: restaurant.latitude,
      restaurantLongitude: restaurant.longitude,
    );
  }

  /// On sign-out: this device shouldn't keep someone's orders.
  void clearLocal() => _set(const []);

  void _set(List<PlacedOrder> next) {
    state = next;
    ref.read(sharedPreferencesProvider).setString(_key, jsonEncode([for (final o in next) o.toJson()]));
  }
}

/// Order rows and RPC params ↔ app models, kept pure for tests.
abstract final class OrderRows {
  /// What place_order() expects: ids only. Prices are looked up on the server.
  static List<Map<String, Object?>> linesParam(CartState cart) => [
    for (final l in cart.lines)
      {
        'product_id': l.product.id,
        'quantity': l.quantity,
        'choice_ids': [for (final c in l.choices) c.id],
        'note': l.note,
      },
  ];

  static PlacedOrder order(Map<String, dynamic> r) => PlacedOrder.fromJson({
    'id': r['id'],
    'restaurantId': r['restaurant_id'],
    'restaurantAr': r['restaurant_ar'],
    'restaurantEn': r['restaurant_en'],
    'lines': r['lines'],
    'address': r['address'],
    'payment': r['payment'],
    'subtotal': r['subtotal'],
    'deliveryFee': r['delivery_fee'],
    'discount': r['discount'],
    'promoCode': r['promo_code'],
    // Postgres sends UTC; the app shows local times.
    'placedAt': DateTime.parse(r['placed_at'] as String).toLocal().toIso8601String(),
    'etaMin': r['eta_min'],
    'etaMax': r['eta_max'],
    'status': r['status'],
    'restaurantLat': r['restaurant_lat'],
    'restaurantLng': r['restaurant_lng'],
  });
}

final ordersProvider = NotifierProvider<OrdersController, List<PlacedOrder>>(OrdersController.new);

final orderByIdProvider = Provider.family<PlacedOrder?, int>(
  (ref, id) => ref.watch(ordersProvider).where((o) => o.id == id).firstOrNull,
);

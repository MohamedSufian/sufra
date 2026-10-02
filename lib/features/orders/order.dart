import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../address/address.dart';
import '../cart/cart_controller.dart';
import '../home/domain/models.dart';

enum PaymentMethod { cash }

enum OrderStatus { placed, preparing, onTheWay, delivered }

/// Until a backend pushes real statuses, an order moves through its stages on a clock.
abstract final class OrderSimulation {
  /// Simulated minutes per real minute, so the whole journey can be watched in a few minutes.
  static const timeScale = 12;

  /// The restaurant accepts the order after this long.
  static const acceptMinutes = 2.0;

  /// Share of the delivery time spent cooking before the rider leaves.
  static const preparingShare = 0.45;
}

/// Where an order stands at a moment in time.
@immutable
class OrderProgress {
  const OrderProgress({required this.status, required this.riderProgress, required this.minutesLeft});

  final OrderStatus status;

  /// 0 at the restaurant, 1 at the door.
  final double riderProgress;
  final int minutesLeft;
}

@immutable
class PlacedOrder {
  const PlacedOrder({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.lines,
    required this.address,
    required this.payment,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.placedAt,
    required this.etaMinMinutes,
    required this.etaMaxMinutes,
    this.promoCode,
    this.status = OrderStatus.placed,
    this.restaurantLatitude,
    this.restaurantLongitude,
  });

  /// Short and readable on a phone call with the restaurant ("order 1003").
  final int id;
  final String restaurantId;
  final LocalizedText restaurantName;
  final List<CartLine> lines;
  final SavedAddress address;
  final PaymentMethod payment;
  final int subtotal;
  final int deliveryFee;
  final int discount;
  final String? promoCode;
  final DateTime placedAt;
  final int etaMinMinutes;
  final int etaMaxMinutes;
  final OrderStatus status;

  /// Where the rider starts. Null on orders saved before this was recorded.
  final double? restaurantLatitude;
  final double? restaurantLongitude;

  int get total => subtotal + deliveryFee - discount;

  OrderProgress progressAt(DateTime now) {
    final elapsed = math.max(0, now.difference(placedAt).inMilliseconds) / 60000 * OrderSimulation.timeScale;
    final arrival = etaMaxMinutes.toDouble();
    final departure = math.max(OrderSimulation.acceptMinutes, arrival * OrderSimulation.preparingShare);
    final status = elapsed >= arrival
        ? OrderStatus.delivered
        : elapsed >= departure
            ? OrderStatus.onTheWay
            : elapsed >= OrderSimulation.acceptMinutes
                ? OrderStatus.preparing
                : OrderStatus.placed;
    return OrderProgress(
      status: status,
      riderProgress: ((elapsed - departure) / (arrival - departure)).clamp(0.0, 1.0),
      minutesLeft: math.max(0, (arrival - elapsed).ceil()),
    );
  }

  int get itemCount => lines.fold(0, (sum, l) => sum + l.quantity);

  Map<String, Object?> toJson() => {
    'id': id,
    'restaurantId': restaurantId,
    'restaurantAr': restaurantName.ar,
    'restaurantEn': restaurantName.en,
    'lines': [for (final l in lines) l.toJson()],
    'address': address.toJson(),
    'payment': payment.name,
    'subtotal': subtotal,
    'deliveryFee': deliveryFee,
    'discount': discount,
    'promoCode': promoCode,
    'placedAt': placedAt.toIso8601String(),
    'etaMin': etaMinMinutes,
    'etaMax': etaMaxMinutes,
    'status': status.name,
    'restaurantLat': restaurantLatitude,
    'restaurantLng': restaurantLongitude,
  };

  factory PlacedOrder.fromJson(Map<String, Object?> json) => PlacedOrder(
    id: json['id']! as int,
    restaurantId: json['restaurantId']! as String,
    restaurantName: LocalizedText(ar: json['restaurantAr']! as String, en: json['restaurantEn']! as String),
    lines: [for (final l in (json['lines']! as List).cast<Map>()) CartLine.fromJson(l.cast<String, Object?>())],
    address: SavedAddress.fromJson((json['address']! as Map).cast<String, Object?>()),
    payment: PaymentMethod.values.asNameMap()[json['payment']] ?? PaymentMethod.cash,
    subtotal: json['subtotal']! as int,
    deliveryFee: json['deliveryFee']! as int,
    discount: json['discount']! as int,
    promoCode: json['promoCode'] as String?,
    placedAt: DateTime.parse(json['placedAt']! as String),
    etaMinMinutes: json['etaMin']! as int,
    etaMaxMinutes: json['etaMax']! as int,
    status: OrderStatus.values.asNameMap()[json['status']] ?? OrderStatus.placed,
    restaurantLatitude: (json['restaurantLat'] as num?)?.toDouble(),
    restaurantLongitude: (json['restaurantLng'] as num?)?.toDouble(),
  );
}

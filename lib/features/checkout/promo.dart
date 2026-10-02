import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// A percentage off the food, capped. Checked on the device for now; the server will own this.
@immutable
class Promo {
  const Promo({required this.code, required this.percent, required this.maxDiscount});

  final String code;
  final int percent;

  /// Shekels.
  final int maxDiscount;

  /// Applies to the food only, never the delivery fee; whole shekels, rounded down.
  int discountOn(int subtotal) => math.min(subtotal * percent ~/ 100, maxDiscount);

  static const _all = [Promo(code: 'SUFRA20', percent: 20, maxDiscount: 30)];

  /// Case and spaces don't matter.
  static Promo? find(String input) {
    final code = input.trim().toUpperCase();
    return _all.where((p) => p.code == code).firstOrNull;
  }
}

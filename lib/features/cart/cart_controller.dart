import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/settings/settings_controller.dart';
import '../home/domain/models.dart';

/// One dish as ordered: the same dish with other options or another note is a separate line.
@immutable
class CartLine {
  const CartLine({required this.product, required this.quantity, this.choices = const [], this.note = ''});

  final Product product;
  final int quantity;
  final List<OptionChoice> choices;
  final String note;

  /// Identifies a configuration: dish + chosen options (in any order) + note.
  static String keyFor(String productId, [List<OptionChoice> choices = const [], String note = '']) =>
      [productId, ([for (final c in choices) c.id]..sort()).join(','), note.trim()].join('|');

  String get key => keyFor(product.id, choices, note);
  int get unitPrice => product.price + choices.fold(0, (sum, c) => sum + c.priceDelta);
  int get total => unitPrice * quantity;

  CartLine withQuantity(int quantity) => CartLine(product: product, quantity: quantity, choices: choices, note: note);

  Map<String, Object?> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
    'choices': [for (final c in choices) c.toJson()],
    'note': note,
  };

  factory CartLine.fromJson(Map<String, Object?> json) => CartLine(
    product: Product.fromJson((json['product']! as Map).cast<String, Object?>()),
    quantity: json['quantity']! as int,
    // Carts saved before options existed have neither field.
    choices: [
      for (final c in (json['choices'] as List? ?? const []).cast<Map>()) OptionChoice.fromJson(c.cast<String, Object?>()),
    ],
    note: json['note'] as String? ?? '',
  );
}

/// A cart holds dishes from one restaurant only, like every delivery app.
@immutable
class CartState {
  const CartState({this.restaurantId, this.lines = const []});

  final String? restaurantId;
  final List<CartLine> lines;

  bool get isEmpty => lines.isEmpty;
  int get itemCount => lines.fold(0, (sum, l) => sum + l.quantity);
  int get subtotal => lines.fold(0, (sum, l) => sum + l.total);

  /// All configurations of the dish together.
  int quantityOf(String productId) =>
      lines.where((l) => l.product.id == productId).fold(0, (sum, l) => sum + l.quantity);
}

class CartController extends Notifier<CartState> {
  static const _key = 'cart.v1';

  @override
  CartState build() {
    final raw = ref.watch(sharedPreferencesProvider).getString(_key);
    if (raw == null) return const CartState();
    try {
      final json = jsonDecode(raw) as Map<String, Object?>;
      return CartState(
        restaurantId: json['restaurantId'] as String?,
        lines: [for (final l in (json['lines']! as List).cast<Map>()) CartLine.fromJson(l.cast<String, Object?>())],
      );
    } on Object {
      return const CartState(); // An unreadable saved cart is dropped rather than crashing the app.
    }
  }

  /// Whether adding [product] needs the user to give up their current cart first.
  bool conflictsWith(Product product) =>
      !state.isEmpty && state.restaurantId != product.restaurantId;

  /// Adds [quantity] of the configured dish, merging with an identical line.
  /// Call [conflictsWith] first; a conflicting product starts a new cart.
  void add(Product product, {List<OptionChoice> choices = const [], String note = '', int quantity = 1}) {
    final base = conflictsWith(product) ? const CartState() : state;
    final key = CartLine.keyFor(product.id, choices, note);
    final exists = base.lines.any((l) => l.key == key);
    _set(CartState(
      restaurantId: product.restaurantId,
      lines: exists
          ? [for (final l in base.lines) l.key == key ? l.withQuantity(l.quantity + quantity) : l]
          : [...base.lines, CartLine(product: product, quantity: quantity, choices: choices, note: note.trim())],
    ));
  }

  void incrementLine(String key) => _set(CartState(
    restaurantId: state.restaurantId,
    lines: [for (final l in state.lines) l.key == key ? l.withQuantity(l.quantity + 1) : l],
  ));

  /// Removes one; the line goes away at zero, the cart empties with its last line.
  void decrementLine(String key) {
    final lines = [
      for (final l in state.lines)
        if (l.key != key)
          l
        else if (l.quantity > 1)
          l.withQuantity(l.quantity - 1),
    ];
    _set(lines.isEmpty ? const CartState() : CartState(restaurantId: state.restaurantId, lines: lines));
  }

  void clear() => _set(const CartState());

  void _set(CartState next) {
    state = next;
    final prefs = ref.read(sharedPreferencesProvider);
    if (next.isEmpty) {
      prefs.remove(_key);
    } else {
      prefs.setString(_key, jsonEncode({
        'restaurantId': next.restaurantId,
        'lines': [for (final l in next.lines) l.toJson()],
      }));
    }
  }
}

final cartProvider = NotifierProvider<CartController, CartState>(CartController.new);

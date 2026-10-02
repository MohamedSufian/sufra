import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/router/app_router.dart';
import '../cart/add_to_cart.dart';
import '../cart/cart_controller.dart';
import 'order.dart';

/// Puts every line of a past order back in the cart (asking first if the cart holds another
/// restaurant's dishes) and opens the cart.
Future<void> reorder(BuildContext context, WidgetRef ref, PlacedOrder order) async {
  final first = order.lines.first;
  final added = await addToCart(context, ref, first.product, choices: first.choices, note: first.note, quantity: first.quantity);
  if (!added) return;
  final cart = ref.read(cartProvider.notifier);
  for (final l in order.lines.skip(1)) {
    cart.add(l.product, choices: l.choices, note: l.note, quantity: l.quantity);
  }
  if (context.mounted) context.go(AppRoutes.cart);
}

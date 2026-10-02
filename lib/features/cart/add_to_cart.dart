import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/utils/context_x.dart';
import '../home/domain/models.dart';
import '../restaurant/restaurant_providers.dart';
import 'cart_controller.dart';

/// Adds the configured dish, first asking before it replaces a cart from another restaurant.
/// Returns whether it was added.
Future<bool> addToCart(
  BuildContext context,
  WidgetRef ref,
  Product product, {
  List<OptionChoice> choices = const [],
  String note = '',
  int quantity = 1,
}) async {
  final cart = ref.read(cartProvider.notifier);
  if (cart.conflictsWith(product)) {
    final otherId = ref.read(cartProvider).restaurantId!;
    final other = ref.read(restaurantByIdProvider(otherId)).value;
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.replaceCartTitle),
        content: Text(l10n.replaceCartBody(other?.name.resolve(context.locale) ?? '')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(minimumSize: const Size(64, 44)),
            child: Text(l10n.replaceCartConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;
  }
  cart.add(product, choices: choices, note: note, quantity: quantity);
  return true;
}

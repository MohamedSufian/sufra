import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/context_x.dart';
import '../../core/widgets/plate_art.dart';
import '../../core/widgets/quantity_stepper.dart';
import '../../core/widgets/state_views.dart';
import '../home/presentation/home_screen.dart';
import '../restaurant/restaurant_providers.dart';
import 'cart_controller.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final cart = ref.watch(cartProvider);

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navCart)),
        body: Center(
          child: MessageView(
            icon: Icons.shopping_bag_outlined,
            title: l10n.cartEmptyTitle,
            body: l10n.cartEmptyBody,
            actionLabel: l10n.browseRestaurants,
            onAction: () => context.go(AppRoutes.home),
          ),
        ),
      );
    }

    final restaurant = ref.watch(restaurantByIdProvider(cart.restaurantId!)).value;
    final deliveryFee = restaurant?.deliveryFee ?? 0;
    final missing = (restaurant?.minOrder ?? 0) - cart.subtotal;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navCart),
        actions: [
          TextButton(onPressed: ref.read(cartProvider.notifier).clear, child: Text(l10n.clearCart)),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, HomeScreen.bottomInset),
        children: [
          if (restaurant != null)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.go(AppRoutes.restaurant(restaurant.id)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.storefront_rounded, size: 20, color: context.sufra.muted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.cartFrom(restaurant.name.resolve(context.locale)),
                        style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(l10n.itemsCount(cart.itemCount), style: context.text.bodyMedium?.copyWith(color: context.sufra.muted)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          for (final line in cart.lines)
            Padding(
              key: ValueKey(line.key),
              padding: const EdgeInsets.only(bottom: 10),
              child: _CartLineTile(line: line),
            ).animate().fadeIn(duration: 250.ms),
          const SizedBox(height: 8),
          if (missing > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: context.sufra.softAccent, borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: context.colors.onPrimaryContainer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.minOrderNotice(missing),
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.sufra.border),
            ),
            child: Column(
              children: [
                _SummaryRow(label: l10n.subtotal, value: l10n.price(cart.subtotal)),
                const SizedBox(height: 10),
                _SummaryRow(label: l10n.deliveryLabel, value: l10n.price(deliveryFee)),
                const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider()),
                _SummaryRow(label: l10n.total, value: l10n.price(cart.subtotal + deliveryFee), emphasized: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: missing > 0 ? null : () => context.push(AppRoutes.checkout),
            child: Text(l10n.checkout),
          ),
        ],
      ),
    );
  }
}

class _CartLineTile extends ConsumerWidget {
  const _CartLineTile({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = line.product;
    final palette = PlatePalette.of(p.artIndex);
    final name = p.name.resolve(context.locale);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.sufra.border),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: context.isDark ? palette.backdropDark : palette.backdropLight,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: PlateArt(palette: palette, size: 46),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                if (line.choices.isNotEmpty)
                  Text(
                    line.choices.map((c) => c.name.resolve(context.locale)).join(' · '),
                    style: context.text.bodySmall?.copyWith(color: context.sufra.muted),
                  ),
                if (line.note.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.edit_note_rounded, size: 16, color: context.sufra.muted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          line.note,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall?.copyWith(color: context.sufra.muted, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                Text(context.l10n.price(line.total), style: context.text.titleMedium?.copyWith(color: context.isDark ? AppColors.darkLink : AppColors.ember)),
              ],
            ),
          ),
          QuantityStepper(
            quantity: line.quantity,
            itemName: name,
            onIncrement: () => ref.read(cartProvider.notifier).incrementLine(line.key),
            onDecrement: () => ref.read(cartProvider.notifier).decrementLine(line.key),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.emphasized = false});

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = emphasized
        ? context.text.titleLarge?.copyWith(fontSize: 18)
        : context.text.bodyLarge?.copyWith(color: context.sufra.muted);
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: emphasized ? style : context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

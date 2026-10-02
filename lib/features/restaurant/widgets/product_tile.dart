import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/context_x.dart';
import '../../../core/widgets/plate_art.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../../cart/add_to_cart.dart';
import '../../cart/cart_controller.dart';
import '../../home/domain/models.dart';
import '../product_sheet.dart';

class ProductTile extends ConsumerWidget {
  const ProductTile({super.key, required this.product, required this.canOrder});

  final Product product;

  /// False while the restaurant is closed.
  final bool canOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = product;
    final l10n = context.l10n;
    final palette = PlatePalette.of(p.artIndex);
    final quantity = ref.watch(cartProvider.select((c) => c.quantityOf(p.id)));
    final name = p.name.resolve(context.locale);
    final description = p.description.resolve(context.locale);
    final orderable = canOrder && p.isAvailable;
    void openDetails() => showProductSheet(context, p, canOrder: canOrder);

    return Opacity(
      opacity: p.isAvailable ? 1 : 0.55,
      child: Material(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: openDetails,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: quantity > 0 ? AppColors.ember : context.sufra.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? palette.backdropDark
                        : palette.backdropLight,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: PlateArt(palette: palette, size: 66),
                ),
                const SizedBox(width: 12),
                // No fixed height: the "− 1 +" stepper and large system fonts both need room to grow.
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 92),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (p.isPopular) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.local_fire_department_rounded,
                                size: 16,
                                color: AppColors.coral,
                              ),
                            ],
                          ],
                        ),
                        if (description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodySmall?.copyWith(
                                color: context.sufra.muted,
                                height: 1.45,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // The price gives way (shrinks) so the stepper never pushes out on narrow phones.
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  l10n.price(p.price),
                                  style: context.text.titleMedium,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (p.isAvailable && p.hasOptions)
                              // Options must be picked first, so "+" opens the details; the badge counts every version.
                              Badge(
                                isLabelVisible: quantity > 0,
                                label: Text('$quantity'),
                                backgroundColor: AppColors.saffron,
                                textColor: AppColors.ink,
                                child: QuantityStepper(
                                  quantity: 0,
                                  itemName: name,
                                  onIncrement: orderable ? openDetails : null,
                                ),
                              )
                            else if (p.isAvailable)
                              QuantityStepper(
                                quantity: quantity,
                                itemName: name,
                                onIncrement: orderable
                                    ? () => addToCart(context, ref, p)
                                    : null,
                                onDecrement: () => ref
                                    .read(cartProvider.notifier)
                                    .decrementLine(CartLine.keyFor(p.id)),
                              )
                            else
                              Text(
                                l10n.soldOut,
                                style: context.text.labelLarge?.copyWith(
                                  color: context.sufra.muted,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

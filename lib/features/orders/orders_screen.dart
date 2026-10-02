import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/clock.dart';
import '../../core/utils/context_x.dart';
import '../../core/widgets/plate_art.dart';
import '../../core/widgets/state_views.dart';
import '../home/presentation/home_screen.dart';
import 'order.dart';
import 'orders_controller.dart';

String orderStatusText(BuildContext context, OrderStatus status) =>
    switch (status) {
      OrderStatus.placed => context.l10n.statusPlaced,
      OrderStatus.preparing => context.l10n.statusPreparing,
      OrderStatus.onTheWay => context.l10n.statusOnTheWay,
      OrderStatus.delivered => context.l10n.statusDelivered,
    };

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navOrders)),
      body: orders.isEmpty
          ? Center(
              child: MessageView(
                icon: Icons.receipt_long_outlined,
                title: l10n.ordersEmptyTitle,
                body: l10n.ordersEmptyBody,
                actionLabel: l10n.browseRestaurants,
                onAction: () => context.go(AppRoutes.home),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                16,
                4,
                16,
                HomeScreen.bottomInset,
              ),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _OrderCard(
                order: orders[i],
                now: ref.watch(clockProvider).now,
              ),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.now});

  final PlacedOrder order;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final o = order;
    final palette = PlatePalette.of(o.lines.first.product.artIndex);
    final status = o.progressAt(now).status;
    final delivered = status == OrderStatus.delivered;
    final when = latinDigits(
      DateFormat.MMMd(context.locale.languageCode).add_jm().format(o.placedAt),
    );

    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: () => context.go(AppRoutes.orderTracking(o.id)),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: context.sufra.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? palette.backdropDark
                          : palette.backdropLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: PlateArt(palette: palette, size: 38),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          o.restaurantName.resolve(context.locale),
                          style: context.text.titleMedium,
                        ),
                        Text(
                          '${l10n.orderNumber(o.id)} · $when',
                          style: context.text.bodySmall?.copyWith(
                            color: context.sufra.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: delivered
                          ? context.theme.scaffoldBackgroundColor
                          : AppColors.mint,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      orderStatusText(context, status),
                      style: context.text.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: delivered
                            ? context.sufra.muted
                            : AppColors.onMint,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                o.lines
                    .map(
                      (l) =>
                          '${l.quantity}× ${l.product.name.resolve(context.locale)}',
                    )
                    .join('، '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    l10n.itemsCount(o.itemCount),
                    style: context.text.bodySmall?.copyWith(
                      color: context.sufra.muted,
                    ),
                  ),
                  const Spacer(),
                  Text(l10n.price(o.total), style: context.text.titleMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

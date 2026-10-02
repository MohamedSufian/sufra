import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/maps/app_map.dart';
import '../../core/maps/map_markers.dart';
import '../../core/maps/route_line.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/clock.dart';
import '../../core/utils/context_x.dart';
import '../address/address_sheet.dart';
import '../restaurant/restaurant_providers.dart';
import 'order.dart';
import 'orders_controller.dart';
import 'reorder.dart';

class OrderTrackingScreen extends ConsumerWidget {
  const OrderTrackingScreen({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderByIdProvider(orderId));
    if (order == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.go(AppRoutes.orders),
      );
      return const Scaffold();
    }
    final progress = order.progressAt(ref.watch(clockProvider).now);
    final restaurant = ref
        .watch(restaurantByIdProvider(order.restaurantId))
        .value;

    final home = (
      latitude: order.address.latitude,
      longitude: order.address.longitude,
    );
    final start = (
      latitude:
          order.restaurantLatitude ??
          restaurant?.latitude ??
          home.latitude + 0.01,
      longitude:
          order.restaurantLongitude ??
          restaurant?.longitude ??
          home.longitude + 0.01,
    );
    final route = curvedRoute(start, home);
    final split = splitRoute(route, progress.riderProgress);
    final riding = progress.status == OrderStatus.onTheWay;
    final sheetTop = MediaQuery.sizeOf(context).height * 0.46;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AppMap(
              latitude: (start.latitude + home.latitude) / 2,
              longitude: (start.longitude + home.longitude) / 2,
              fitPoints: [start, home],
              fitPadding: EdgeInsets.fromLTRB(56, 120, 56, sheetTop + 24),
              lines: riding || progress.status == OrderStatus.delivered
                  ? [
                      AppMapLine(
                        points: split.done,
                        color: AppColors.coral.withValues(alpha: 0.35),
                        width: 6,
                      ),
                      if (riding)
                        AppMapLine(
                          points: split.ahead,
                          color: AppColors.ember,
                          width: 6,
                        ),
                    ]
                  : [
                      AppMapLine(
                        points: route,
                        color: context.sufra.muted,
                        width: 5,
                        dashed: true,
                      ),
                    ],
              markers: [
                AppMapMarker(point: start, child: const RestaurantMarker()),
                AppMapMarker(point: home, child: const HomeMarker()),
                if (riding)
                  AppMapMarker(
                    point: split.at,
                    size: 72,
                    child: const RiderMarker(),
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    tooltip: context.l10n.back,
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go(AppRoutes.orders),
                    style: IconButton.styleFrom(
                      fixedSize: const Size(44, 44),
                      backgroundColor: context.colors.surface,
                      foregroundColor: context.colors.onSurface,
                    ),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 10),
                  _Chip(text: context.l10n.orderNumber(order.id)),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.46,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            snap: true,
            builder: (context, scroll) => Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 30,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: context.sufra.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StatusHeader(order: order, progress: progress),
                  const SizedBox(height: 6),
                  // Honest about the simulation until real statuses come from the backend.
                  Row(
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        size: 14,
                        color: AppColors.saffron,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n.demoTimeNote(OrderSimulation.timeScale),
                        style: context.text.labelSmall?.copyWith(
                          color: context.sufra.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _Steps(status: progress.status),
                  const SizedBox(height: 20),
                  if (progress.status == OrderStatus.delivered)
                    FilledButton.icon(
                      onPressed: () => reorder(context, ref, order),
                      icon: const Icon(Icons.replay_rounded),
                      label: Text(context.l10n.reorder),
                    )
                  else
                    _PersonCard(order: order, riding: riding),
                  const SizedBox(height: 24),
                  _Details(order: order),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.order, required this.progress});

  final PlacedOrder order;
  final OrderProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final restaurant = order.restaurantName.resolve(context.locale);
    final (title, body) = switch (progress.status) {
      OrderStatus.placed => (l10n.statusPlaced, l10n.statusPlacedBody),
      OrderStatus.preparing => (
        l10n.statusPreparing,
        l10n.statusPreparingBody(restaurant),
      ),
      OrderStatus.onTheWay => (l10n.statusOnTheWay, l10n.statusOnTheWayBody),
      OrderStatus.delivered => (
        l10n.statusDeliveredTitle,
        l10n.statusDeliveredBody,
      ),
    };
    final delivered = progress.status == OrderStatus.delivered;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: 300.ms,
            child: Column(
              key: ValueKey(progress.status),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  body,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.sufra.muted,
                  ),
                ),
                Text(
                  title,
                  style: context.text.headlineSmall?.copyWith(fontSize: 24),
                ),
              ],
            ),
          ),
        ),
        if (delivered)
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.mint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.onMint,
              size: 32,
            ),
          ).animate().scale(curve: Curves.elasticOut, duration: 600.ms)
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.arrivesIn,
                style: context.text.labelMedium?.copyWith(
                  color: context.sufra.muted,
                ),
              ),
              Text(
                l10n.minutesCount(progress.minutesLeft),
                style: GoogleFonts.alexandria(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: context.isDark ? AppColors.darkLink : AppColors.ember,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final steps = [
      (OrderStatus.placed, l10n.stepPlaced),
      (OrderStatus.preparing, l10n.stepPreparing),
      (OrderStatus.onTheWay, l10n.stepOnTheWay),
      (OrderStatus.delivered, l10n.stepDelivered),
    ];
    final current = status.index;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, (step, label)) in steps.indexed) ...[
          if (i > 0)
            Expanded(
              child: AnimatedContainer(
                duration: 400.ms,
                height: 3,
                margin: const EdgeInsets.only(top: 14),
                color: step.index <= current
                    ? AppColors.mint
                    : context.sufra.border,
              ),
            ),
          SizedBox(
            width: 66,
            child: Column(
              children: [
                _StepDot(
                  done: step.index < current || status == OrderStatus.delivered,
                  active: step.index == current,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: context.text.labelSmall?.copyWith(
                    fontWeight: step.index == current
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: step.index <= current
                        ? context.colors.onSurface
                        : context.sufra.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.done, required this.active});

  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (done) {
      return Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: AppColors.mint,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 18,
          color: AppColors.onMint,
        ),
      );
    }
    final dot = Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: active ? AppColors.ember : context.sufra.border,
        shape: BoxShape.circle,
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.coral.withValues(alpha: 0.35),
                  spreadRadius: 6,
                ),
              ]
            : null,
      ),
    );
    return active
        ? dot
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
                duration: 800.ms,
              )
        : dot;
  }
}

/// Who has the order right now: the restaurant while cooking, the rider once it leaves.
class _PersonCard extends StatelessWidget {
  const _PersonCard({required this.order, required this.riding});

  final PlacedOrder order;
  final bool riding;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: riding ? AppColors.saffron : context.sufra.contrastButton,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              riding ? Icons.delivery_dining_rounded : Icons.storefront_rounded,
              color: riding ? AppColors.ink : context.sufra.onContrastButton,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  riding
                      ? l10n.rider
                      : order.restaurantName.resolve(context.locale),
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  riding ? l10n.riderOnTheWay : l10n.statusPreparing,
                  style: context.text.bodySmall?.copyWith(
                    color: context.sufra.muted,
                  ),
                ),
              ],
            ),
          ),
          // Call / message buttons come back once the backend assigns real riders (with masked numbers).
        ],
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.order});

  final PlacedOrder order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final o = order;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.orderDetails, style: context.text.titleMedium),
        const SizedBox(height: 10),
        for (final l in o.lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l.quantity}×',
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    [
                      l.product.name.resolve(context.locale),
                      for (final c in l.choices) c.name.resolve(context.locale),
                    ].join(' · '),
                    style: context.text.bodyMedium,
                  ),
                ),
                Text(l10n.price(l.total), style: context.text.bodyMedium),
              ],
            ),
          ),
        const Divider(height: 24),
        _Row(
          icon: addressLabelIcon(o.address.label),
          text:
              '${o.address.area.resolve(context.locale)} · ${o.address.landmark}',
        ),
        const SizedBox(height: 10),
        _Row(
          icon: Icons.payments_rounded,
          text: '${l10n.cashOnDelivery} · ${l10n.price(o.total)}',
          bold: true,
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.text, this.bold = false});

  final IconData icon;
  final String text;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.sufra.muted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: context.text.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.w700 : null,
            ),
          ),
        ),
      ],
    );
  }
}

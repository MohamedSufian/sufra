import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/context_x.dart';
import '../address/address_sheet.dart';
import 'orders_controller.dart';

class OrderPlacedScreen extends ConsumerWidget {
  const OrderPlacedScreen({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final order = ref.watch(orderByIdProvider(orderId));
    if (order == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go(AppRoutes.home));
      return const Scaffold();
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(color: AppColors.mint.withValues(alpha: 0.18), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: const BoxDecoration(color: AppColors.mint, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, size: 56, color: AppColors.onMint),
                ).animate().scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 600.ms, curve: Curves.elasticOut),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 28),
              Text(l10n.orderPlacedTitle, style: context.text.headlineSmall, textAlign: TextAlign.center)
                  .animate()
                  .fadeIn(delay: 250.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              Text(
                l10n.orderPlacedBody(order.restaurantName.resolve(context.locale)),
                style: context.text.bodyLarge?.copyWith(color: context.sufra.muted),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 350.ms),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.sufra.border),
                ),
                child: Column(
                  children: [
                    _InfoRow(icon: Icons.receipt_long_rounded, text: l10n.orderNumber(order.id)),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.schedule_rounded,
                      text: l10n.deliveryEta(order.etaMinMinutes, order.etaMaxMinutes),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: addressLabelIcon(order.address.label),
                      text: '${order.address.area.resolve(context.locale)} · ${order.address.landmark}',
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.payments_rounded,
                      text: '${l10n.cashOnDelivery} · ${l10n.price(order.total)}',
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1, end: 0),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: () => context.go(AppRoutes.orderTracking(order.id)), child: Text(l10n.trackOrder)),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: () => context.go(AppRoutes.home), child: Text(l10n.backToHome)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.isDark ? AppColors.darkLink : AppColors.ember),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w600))),
      ],
    );
  }
}

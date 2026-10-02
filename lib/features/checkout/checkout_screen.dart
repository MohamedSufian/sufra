import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/context_x.dart';
import '../../core/widgets/state_views.dart';
import '../../core/backend/backend.dart';
import '../address/address_sheet.dart';
import '../auth/auth.dart';
import '../address/addresses_controller.dart';
import '../cart/cart_controller.dart';
import '../home/domain/models.dart';
import '../orders/order.dart';
import '../orders/orders_controller.dart';
import '../restaurant/restaurant_providers.dart';
import 'promo.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _promoField = TextEditingController();
  Promo? _promo;
  String? _promoError;
  var _placing = false;

  bool get _needsSignIn => ref.read(supabaseProvider) != null && ref.read(currentUserProvider) == null;

  @override
  void dispose() {
    _promoField.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final promo = Promo.find(_promoField.text);
    setState(() {
      _promo = promo;
      _promoError = promo == null ? context.l10n.promoInvalid : null;
    });
    if (promo != null) FocusScope.of(context).unfocus();
  }

  Future<void> _place(Restaurant restaurant) async {
    final address = ref.read(addressesProvider).selected;
    if (address == null) return;
    // Lazy sign-in: browsing and building a cart need no account; placing the order does.
    if (_needsSignIn) {
      final signedIn = await context.push<bool>(AppRoutes.signIn);
      if (signedIn != true || !mounted) return;
    }
    setState(() => _placing = true);
    try {
      final order = await ref.read(ordersProvider.notifier).place(
        restaurant: restaurant,
        address: address,
        payment: PaymentMethod.cash,
        promo: _promo,
      );
      HapticFeedback.mediumImpact();
      if (mounted) context.go(AppRoutes.orderPlaced(order.id));
    } on Object {
      if (!mounted) return;
      setState(() => _placing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.placeOrderFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cart = ref.watch(cartProvider);

    if (cart.isEmpty) {
      // Reached after the order was placed, or through a stale link.
      return Scaffold(
        appBar: AppBar(title: Text(l10n.checkoutTitle)),
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
    final address = ref.watch(addressesProvider).selected;
    final deliveryFee = restaurant?.deliveryFee ?? 0;
    final discount = _promo?.discountOn(cart.subtotal) ?? 0;
    final total = cart.subtotal + deliveryFee - discount;
    final canPlace = restaurant != null && restaurant.isOpen && address != null && !_placing;
    final signInNeeded = ref.watch(supabaseProvider) != null && ref.watch(currentUserProvider) == null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkoutTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _SectionTitle(l10n.deliverTo),
          if (address == null)
            _DashedAction(
              icon: Icons.add_location_alt_rounded,
              label: l10n.addAddress,
              onTap: () => pickAddressOnMap(context),
            )
          else
            AddressTile(
              address: address,
              selected: true,
              onTap: () => showAddressSheet(context, ref),
              onEdit: () => showAddressSheet(context, ref),
            ),
          if (restaurant != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 18, color: context.sufra.muted),
                const SizedBox(width: 6),
                Text(
                  l10n.deliveryEta(restaurant.deliveryMinMinutes, restaurant.deliveryMaxMinutes),
                  style: context.text.bodyMedium?.copyWith(color: context.sufra.muted, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
          _SectionTitle(l10n.paymentMethod),
          _PaymentOption(
            icon: Icons.payments_rounded,
            title: l10n.cashOnDelivery,
            subtitle: l10n.cashOnDeliveryHint,
            selected: true,
          ),
          const SizedBox(height: 10),
          _PaymentOption(
            icon: Icons.account_balance_wallet_rounded,
            title: l10n.eWallet,
            badge: l10n.soon,
            selected: false,
            enabled: false,
          ),
          _SectionTitle(l10n.promoTitle),
          if (_promo case final promo?)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.mint.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.mint),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_offer_rounded, color: AppColors.mint),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${promo.code} · −${l10n.price(discount)}',
                      style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _promo = null;
                      _promoField.clear();
                    }),
                    child: Text(l10n.remove),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 250.ms).scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1))
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoField,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _applyPromo(),
                    onChanged: (_) {
                      if (_promoError != null) setState(() => _promoError = null);
                    },
                    decoration: InputDecoration(
                      hintText: l10n.promoHint,
                      prefixIcon: const Icon(Icons.local_offer_outlined),
                      errorText: _promoError,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: _applyPromo,
                    style: FilledButton.styleFrom(
                      backgroundColor: context.sufra.contrastButton,
                      foregroundColor: context.sufra.onContrastButton,
                    ),
                    child: Text(l10n.apply),
                  ),
                ),
              ],
            ),
          _SectionTitle(l10n.orderSummary),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.sufra.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (restaurant != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      l10n.cartFrom(restaurant.name.resolve(context.locale)),
                      style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                for (final line in cart.lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${line.quantity}×', style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            [
                              line.product.name.resolve(context.locale),
                              for (final c in line.choices) c.name.resolve(context.locale),
                            ].join(' · '),
                            style: context.text.bodyMedium,
                          ),
                        ),
                        Text(l10n.price(line.total), style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
                _SummaryRow(label: l10n.subtotal, value: l10n.price(cart.subtotal)),
                const SizedBox(height: 8),
                _SummaryRow(label: l10n.deliveryLabel, value: l10n.price(deliveryFee)),
                if (discount > 0) ...[
                  const SizedBox(height: 8),
                  _SummaryRow(label: l10n.discount, value: '−${l10n.price(discount)}', color: AppColors.mint),
                ],
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
                _SummaryRow(label: l10n.total, value: l10n.price(total), emphasized: true),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton(
          onPressed: canPlace ? () => _place(restaurant) : null,
          child: _placing
              ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : Text(
                  restaurant != null && !restaurant.isOpen
                      ? l10n.restaurantClosed
                      : address == null
                          ? l10n.chooseAddressFirst
                          : signInNeeded
                              ? l10n.signInAndOrder
                              : l10n.placeOrder(total),
                ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(text, style: context.text.titleLarge?.copyWith(fontSize: 17)),
    );
  }
}

class _DashedAction extends StatelessWidget {
  const _DashedAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.isDark ? AppColors.darkLink : AppColors.ember;
    return Material(
      color: context.sufra.softAccent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: accent),
              const SizedBox(width: 10),
              Text(label, style: context.text.titleMedium?.copyWith(color: accent)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.selected,
    this.subtitle,
    this.badge,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badge;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final accent = context.isDark ? AppColors.coral : AppColors.ember;
    return Semantics(
      checked: selected,
      inMutuallyExclusiveGroup: true,
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? accent : context.sufra.border, width: selected ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: context.sufra.softAccent, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    if (subtitle != null)
                      Text(subtitle!, style: context.text.bodySmall?.copyWith(color: context.sufra.muted)),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(badge!, style: context.text.labelMedium?.copyWith(color: context.sufra.muted)),
                )
              else
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: selected ? accent : context.sufra.muted, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: selected
                      ? Container(width: 12, height: 12, decoration: BoxDecoration(color: accent, shape: BoxShape.circle))
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.emphasized = false, this.color});

  final String label;
  final String value;
  final bool emphasized;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = emphasized
        ? context.text.titleLarge?.copyWith(fontSize: 18)
        : context.text.bodyLarge?.copyWith(color: color ?? context.sufra.muted);
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(
          value,
          style: emphasized ? style : context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}

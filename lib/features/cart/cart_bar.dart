import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/context_x.dart';
import 'cart_controller.dart';

/// Floating "View cart" bar, shown while the cart holds dishes from [restaurantId].
class CartBar extends ConsumerWidget {
  const CartBar({super.key, required this.restaurantId});

  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final visible = !cart.isEmpty && cart.restaurantId == restaurantId;

    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 1.6),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Material(
          color: AppColors.ember,
          borderRadius: BorderRadius.circular(22),
          elevation: 8,
          shadowColor: AppColors.ember.withValues(alpha: 0.5),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: visible ? () => context.go(AppRoutes.cart) : null,
            child: SizedBox(
              height: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      constraints: const BoxConstraints(minWidth: 32),
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: Text(
                        '${cart.itemCount}',
                        style: context.text.titleSmall?.copyWith(color: AppColors.ember, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.viewCart,
                        style: context.text.titleMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                    Text(
                      context.l10n.price(cart.subtotal),
                      style: GoogleFonts.alexandria(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

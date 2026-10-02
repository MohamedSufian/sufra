import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/context_x.dart';
import '../cart/cart_controller.dart';

/// Hosts the five tabs under a floating pill-shaped navigation bar.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell, this.showNavigation = true});

  final StatefulNavigationShell navigationShell;

  /// False on full-screen pages pushed inside a tab, such as a restaurant.
  final bool showNavigation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final cartCount = ref.watch(cartProvider.select((c) => c.itemCount));
    // Five icons plus the active label don't fit on small phones (≈320 wide); there the label goes.
    final showLabel = MediaQuery.sizeOf(context).width >= 360;
    final items = [
      (Icons.home_outlined, Icons.home_rounded, l10n.navHome),
      (Icons.favorite_border_rounded, Icons.favorite_rounded, l10n.navFavorites),
      (Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, l10n.navCart),
      (Icons.receipt_long_outlined, Icons.receipt_long_rounded, l10n.navOrders),
      (Icons.person_outline_rounded, Icons.person_rounded, l10n.navProfile),
    ];

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: !showNavigation ? null : SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: context.sufra.navBackground,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: context.sufra.navBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: context.isDark ? 0.5 : 0.25),
                blurRadius: 36,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final (i, (icon, activeIcon, label)) in items.indexed)
                _NavItem(
                  icon: icon,
                  activeIcon: activeIcon,
                  label: label,
                  selected: navigationShell.currentIndex == i,
                  badge: i == 2 ? cartCount : 0,
                  showLabel: showLabel,
                  onTap: () => navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex),
                ),
            ],
          ),
        ),
      ).animate().slideY(begin: 1.2, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
    this.showLabel = true,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badge;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: 280.ms,
            curve: Curves.easeOutCubic,
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: selected ? 16 : 13),
            decoration: BoxDecoration(
              color: selected ? AppColors.ember : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Badge(
                  isLabelVisible: badge > 0,
                  label: Text('$badge'),
                  backgroundColor: AppColors.saffron,
                  textColor: AppColors.ink,
                  child: Icon(selected ? activeIcon : icon, size: 22, color: selected ? Colors.white : context.sufra.navInactive),
                ),
                AnimatedSize(
                  duration: 280.ms,
                  curve: Curves.easeOutCubic,
                  child: selected && showLabel
                      ? Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8),
                          child: Text(
                            label,
                            style: context.text.labelLarge?.copyWith(color: Colors.white),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

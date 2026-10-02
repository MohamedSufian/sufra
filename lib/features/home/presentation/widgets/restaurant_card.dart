import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/context_x.dart';
import '../../../../core/widgets/plate_art.dart';
import '../../domain/models.dart';
import '../home_providers.dart';

class RestaurantCard extends ConsumerWidget {
  const RestaurantCard({super.key, required this.restaurant, this.onTap, this.distanceKm});

  final Restaurant restaurant;

  /// From the delivery address; hidden when null.
  final double? distanceKm;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = restaurant;
    final l10n = context.l10n;
    final palette = PlatePalette.of(r.artIndex);
    final isFavorite = ref.watch(favoritesProvider.select((f) => f.contains(r.id)));

    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: context.sufra.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: ColoredBox(color: context.isDark ? palette.backdropDark : palette.backdropLight),
                    ),
                    Hero(tag: 'plate-${r.id}', child: PlateArt(palette: palette, size: 118)),
                    if (!r.isOpen)
                      Positioned.fill(
                        child: ColoredBox(color: context.theme.scaffoldBackgroundColor.withValues(alpha: 0.55)),
                      ),
                    PositionedDirectional(
                      top: 12,
                      start: 12,
                      child: StatusBadge(isOpen: r.isOpen),
                    ),
                    PositionedDirectional(
                      top: 8,
                      end: 8,
                      child: IconButton(
                        tooltip: isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
                        onPressed: () => ref.read(favoritesProvider.notifier).toggle(r.id),
                        style: IconButton.styleFrom(
                          backgroundColor: context.colors.surface,
                          fixedSize: const Size(44, 44),
                        ),
                        icon: AnimatedSwitcher(
                          duration: 250.ms,
                          transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
                          child: Icon(
                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            key: ValueKey(isFavorite),
                            color: isFavorite ? AppColors.ember : context.colors.onSurface,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.name.resolve(context.locale),
                            style: context.text.titleLarge?.copyWith(fontSize: 17),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.star_rounded, color: AppColors.saffron, size: 20),
                        const SizedBox(width: 2),
                        Text(r.rating.toStringAsFixed(1), style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        Text(' (${r.ratingCount})', style: context.text.bodySmall?.copyWith(color: context.sufra.muted)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${r.cuisine.resolve(context.locale)} · ${r.area.resolve(context.locale)}',
                      style: context.text.bodyMedium?.copyWith(color: context.sufra.muted),
                    ),
                    const SizedBox(height: 10),
                    // Wraps on narrow phones instead of overflowing.
                    Wrap(
                      spacing: 16,
                      runSpacing: 4,
                      children: [
                        _Meta(icon: Icons.schedule_rounded, label: l10n.minutesRange(r.deliveryMinMinutes, r.deliveryMaxMinutes)),
                        _Meta(icon: Icons.delivery_dining_rounded, label: l10n.deliveryFee(r.deliveryFee)),
                        if (distanceKm case final km?)
                          _Meta(icon: Icons.near_me_rounded, label: l10n.distanceKm(km.toStringAsFixed(1))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOpen ? AppColors.mint : context.colors.onSurface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isOpen ? context.l10n.openNow : context.l10n.closed,
        style: context.text.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: isOpen ? AppColors.onMint : context.colors.surface,
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: context.sufra.muted),
        const SizedBox(width: 4),
        Text(label, style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

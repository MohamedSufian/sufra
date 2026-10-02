import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/context_x.dart';
import '../../../../core/widgets/plate_art.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../address/address_sheet.dart';
import '../../../address/addresses_controller.dart';
import '../../domain/models.dart';
import '../home_providers.dart';
import '../restaurant_filters.dart';
import 'filter_sheet.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final address = ref.watch(addressesProvider.select((b) => b.selected));
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: context.sufra.softAccent, borderRadius: BorderRadius.circular(14)),
          child: Icon(Icons.location_on_outlined, color: context.isDark ? AppColors.darkLink : AppColors.ember),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: () => showAddressSheet(context, ref),
            borderRadius: BorderRadius.circular(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.deliverTo, style: context.text.bodySmall?.copyWith(color: context.sufra.muted)),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        address?.area.resolve(context.locale) ?? l10n.chooseAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HomeSearchBar extends ConsumerWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final activeFilters = ref.watch(restaurantFiltersProvider.select((f) => f.activeCount));
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: ref.read(searchQueryProvider.notifier).update,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          tooltip: l10n.filters,
          onPressed: () => showFilterSheet(context),
          style: IconButton.styleFrom(
            fixedSize: const Size(56, 56),
            backgroundColor: context.sufra.contrastButton,
            foregroundColor: context.sufra.onContrastButton,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          // The count of active filters, so a filtered list never looks like missing restaurants.
          icon: Badge(
            isLabelVisible: activeFilters > 0,
            label: Text('$activeFilters'),
            backgroundColor: AppColors.saffron,
            textColor: AppColors.ink,
            child: const Icon(Icons.tune_rounded),
          ),
        ),
      ],
    );
  }
}

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = PlatePalette.of(4);
    // A minimum, not a fixed height: the title wraps to two lines on narrow phones and with large system fonts.
    return Container(
      constraints: const BoxConstraints(minHeight: 136),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: AppColors.ember, borderRadius: BorderRadius.circular(26)),
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          PositionedDirectional(
            end: -40,
            top: -20,
            child: Container(
              width: 176,
              height: 176,
              decoration: const BoxDecoration(color: AppColors.saffron, shape: BoxShape.circle),
            ),
          ),
          PositionedDirectional(
            end: -8,
            top: 14,
            child: PlateArt(palette: palette, size: 108)
                .animate(onPlay: (c) => c.repeat())
                .rotate(duration: 24.seconds),
          ),
          Padding(
            // Leave the plate's side clear so the title never runs under it.
            padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 120, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(l10n.dealBadge, style: context.text.labelMedium?.copyWith(color: Colors.white)),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.dealTitle,
                  maxLines: 2,
                  style: context.text.titleLarge?.copyWith(color: Colors.white, fontSize: 19, height: 1.3),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.dealCode('SUFRA20'),
                  style: context.text.labelLarge?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: context.text.titleLarge?.copyWith(fontSize: 18))),
        if (onSeeAll != null) TextButton(onPressed: onSeeAll, child: Text(context.l10n.seeAll)),
      ],
    );
  }
}

class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selected = ref.watch(selectedCategoryProvider);

    return SizedBox(
      height: 44,
      child: switch (categories) {
        AsyncData(:final value) => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: value.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) => _CategoryChip(
            category: value[i],
            selected: value[i].id == selected,
            onTap: () => ref.read(selectedCategoryProvider.notifier).select(value[i].id),
          ),
        ),
        AsyncError() => const SizedBox.shrink(),
        _ => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 5,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, _) => const ShimmerBox(width: 88, height: 44, radius: 999),
        ),
      },
    );
  }
}

/// Its own widget so it rebuilds with the theme and language, not only the list.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.selected, required this.onTap});

  final FoodCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 220.ms,
      decoration: BoxDecoration(
        color: selected ? AppColors.ember : context.colors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: selected ? AppColors.ember : context.sufra.border),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (category.dotColor.a > 0) ...[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? Colors.white : category.dotColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  category.name.resolve(context.locale),
                  style: context.text.labelLarge?.copyWith(
                    color: selected ? Colors.white : context.colors.onSurface,
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

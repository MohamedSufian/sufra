import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/context_x.dart';
import '../home_providers.dart';
import '../restaurant_filters.dart';

String sortLabel(BuildContext context, RestaurantSort sort) => switch (sort) {
  RestaurantSort.recommended => context.l10n.sortRecommended,
  RestaurantSort.nearest => context.l10n.sortNearest,
  RestaurantSort.rating => context.l10n.sortRating,
  RestaurantSort.fastest => context.l10n.sortFastest,
  RestaurantSort.deliveryFee => context.l10n.sortDeliveryFee,
};

IconData sortIcon(RestaurantSort sort) => switch (sort) {
  RestaurantSort.recommended => Icons.auto_awesome_rounded,
  RestaurantSort.nearest => Icons.near_me_rounded,
  RestaurantSort.rating => Icons.star_rounded,
  RestaurantSort.fastest => Icons.bolt_rounded,
  RestaurantSort.deliveryFee => Icons.delivery_dining_rounded,
};

Future<void> showFilterSheet(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  // Above the tabs' floating navigation bar, which would otherwise cover the sheet's bottom.
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  backgroundColor: context.colors.surface,
  builder: (_) => const _FilterSheet(),
);

/// Edits a draft; nothing changes on the home screen until "Show results".
class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late var _draft = ref.read(restaurantFiltersProvider);

  void _update(RestaurantFilters next) {
    HapticFeedback.selectionClick();
    setState(() => _draft = next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final origin = ref.watch(distanceOriginProvider);
    // Live count of what the draft would show, with the current category and search applied.
    final count = switch (ref.watch(restaurantsProvider)) {
      AsyncData(:final value) => _draft
          .apply(filterRestaurants(value, ref.watch(selectedCategoryProvider), ref.watch(searchQueryProvider)), origin.point)
          .length,
      _ => null,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.filters, style: context.text.titleLarge)),
              TextButton(
                onPressed: _draft.isDefault ? null : () => _update(const RestaurantFilters()),
                child: Text(l10n.reset),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(l10n.sortBy, style: context.text.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final sort in RestaurantSort.values)
                _Pill(
                  label: sortLabel(context, sort),
                  icon: sortIcon(sort),
                  selected: _draft.sort == sort,
                  onTap: () => _update(_draft.copyWith(sort: sort)),
                ),
            ],
          ),
          if (_draft.sort == RestaurantSort.nearest) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: context.sufra.muted),
                const SizedBox(width: 6),
                Text(
                  origin.fromAddress ? l10n.distanceFromAddress : l10n.distanceFromCenter,
                  style: context.text.bodySmall?.copyWith(color: context.sufra.muted),
                ),
              ],
            ),
          ],
          const SizedBox(height: 22),
          Text(l10n.showOnly, style: context.text.titleMedium),
          const SizedBox(height: 4),
          _Toggle(
            icon: Icons.storefront_rounded,
            label: l10n.filterOpenOnly,
            value: _draft.openOnly,
            onChanged: (v) => _update(_draft.copyWith(openOnly: v)),
          ),
          _Toggle(
            icon: Icons.star_rounded,
            label: l10n.filterTopRated,
            value: _draft.topRatedOnly,
            onChanged: (v) => _update(_draft.copyWith(topRatedOnly: v)),
          ),
          _Toggle(
            icon: Icons.delivery_dining_rounded,
            label: l10n.filterCheapDelivery,
            value: _draft.cheapDeliveryOnly,
            onChanged: (v) => _update(_draft.copyWith(cheapDeliveryOnly: v)),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: count == 0
                ? null
                : () {
                    ref.read(restaurantFiltersProvider.notifier).set(_draft);
                    Navigator.pop(context);
                  },
            child: Text(count == null ? l10n.filters : l10n.showResults(count)),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.icon, required this.selected, required this.onTap});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: selected ? AppColors.ember : context.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: selected ? AppColors.ember : context.sufra.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: selected ? Colors.white : context.sufra.muted),
                const SizedBox(width: 6),
                Text(label, style: context.text.labelLarge?.copyWith(color: selected ? Colors.white : null)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.icon, required this.label, required this.value, required this.onChanged});

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      activeThumbColor: Colors.white,
      activeTrackColor: AppColors.ember,
      secondary: Icon(icon, color: context.sufra.muted),
      title: Text(label, style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

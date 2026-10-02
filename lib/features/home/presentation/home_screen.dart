import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/context_x.dart';
import '../../../core/widgets/state_views.dart';
import 'home_providers.dart';
import 'restaurant_filters.dart';
import 'widgets/filter_sheet.dart';
import 'widgets/home_sections.dart';
import 'widgets/restaurant_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// Room under the list so the floating navigation bar never covers content.
  static const bottomInset = 120.0;

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(categoriesProvider);
    ref.invalidate(restaurantsProvider);
    await ref.read(restaurantsProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final restaurants = ref.watch(restaurantsProvider);
    final category = ref.watch(selectedCategoryProvider);
    final query = ref.watch(searchQueryProvider);
    final filters = ref.watch(restaurantFiltersProvider);
    final origin = ref.watch(distanceOriginProvider).point;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverList.list(
                  children: [
                    const HomeHeader(),
                    const SizedBox(height: 20),
                    Text(l10n.greetingGuest, style: context.text.bodyLarge?.copyWith(color: context.sufra.muted)),
                    Text(l10n.homeHeadline, style: context.text.headlineSmall),
                    const SizedBox(height: 20),
                    const HomeSearchBar(),
                    const SizedBox(height: 20),
                    const PromoBanner(),
                    const SizedBox(height: 16),
                    SectionTitle(title: l10n.categories),
                    const SizedBox(height: 4),
                  ]
                      .animate(interval: 40.ms)
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
                ),
              ),
              const SliverToBoxAdapter(child: CategoryChips()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(child: SectionTitle(title: l10n.nearYou)),
                      // The current sort, one tap from changing it.
                      ActionChip(
                        avatar: Icon(sortIcon(filters.sort), size: 16),
                        label: Text(sortLabel(context, filters.sort)),
                        onPressed: () => showFilterSheet(context),
                        shape: const StadiumBorder(),
                        side: BorderSide(color: context.sufra.border),
                      ),
                    ],
                  ),
                ),
              ),
              switch (restaurants) {
                AsyncData(:final value) => () {
                  final list = filters.apply(filterRestaurants(value, category, query), origin);
                  if (list.isEmpty) {
                    return SliverToBoxAdapter(
                      child: MessageView(
                        icon: Icons.search_off_rounded,
                        title: l10n.noResultsTitle,
                        body: l10n.noResultsBody,
                        actionLabel: filters.isDefault ? null : l10n.reset,
                        onAction: ref.read(restaurantFiltersProvider.notifier).reset,
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, bottomInset),
                    sliver: SliverList.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, i) => RestaurantCard(
                        key: ValueKey(list[i].id),
                        restaurant: list[i],
                        distanceKm: RestaurantFilters.distanceKm(origin, list[i]),
                        onTap: () => context.go(AppRoutes.restaurant(list[i].id)),
                      ).animate().fadeIn(delay: (60 * i).ms, duration: 350.ms).slideY(begin: 0.1, end: 0),
                    ),
                  );
                }(),
                AsyncError() => SliverToBoxAdapter(
                  child: MessageView(
                    icon: Icons.wifi_off_rounded,
                    title: l10n.errorTitle,
                    body: l10n.errorBody,
                    actionLabel: l10n.retry,
                    onAction: () => _refresh(ref),
                    isError: true,
                  ),
                ),
                _ => SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, bottomInset),
                  sliver: SliverList.separated(
                    itemCount: 3,
                    separatorBuilder: (_, _) => const SizedBox(height: 20),
                    itemBuilder: (_, _) => const RestaurantCardSkeleton(),
                  ),
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

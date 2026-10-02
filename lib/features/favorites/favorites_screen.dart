import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/utils/context_x.dart';
import '../../core/widgets/state_views.dart';
import '../home/presentation/home_providers.dart';
import '../home/presentation/home_screen.dart';
import '../home/presentation/widgets/restaurant_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final favorites = ref.watch(favoritesProvider);
    final restaurants = ref.watch(restaurantsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navFavorites)),
      body: switch (restaurants) {
        AsyncData(:final value) when value.any((r) => favorites.contains(r.id)) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, HomeScreen.bottomInset),
          children: [
            for (final r in value.where((r) => favorites.contains(r.id))) ...[
              RestaurantCard(key: ValueKey(r.id), restaurant: r, onTap: () => context.go(AppRoutes.restaurant(r.id))),
              const SizedBox(height: 16),
            ],
          ],
        ),
        AsyncData() => Center(
          child: MessageView(
            icon: Icons.favorite_border_rounded,
            title: l10n.favoritesEmptyTitle,
            body: l10n.favoritesEmptyBody,
            actionLabel: l10n.browseRestaurants,
            onAction: () => context.go(AppRoutes.home),
          ),
        ),
        AsyncError() => Center(
          child: MessageView(
            icon: Icons.wifi_off_rounded,
            title: l10n.errorTitle,
            body: l10n.errorBody,
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(restaurantsProvider),
            isError: true,
          ),
        ),
        _ => ListView(
          padding: const EdgeInsets.all(20),
          children: const [RestaurantCardSkeleton()],
        ),
      },
    );
  }
}

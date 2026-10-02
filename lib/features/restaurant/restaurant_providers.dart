import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home/data/restaurants_repository.dart';
import '../home/domain/models.dart';
import '../home/presentation/home_providers.dart';

/// null when no restaurant has that id (a stale link, for example).
final restaurantByIdProvider = FutureProvider.family<Restaurant?, String>((ref, id) async {
  final all = await ref.watch(restaurantsProvider.future);
  return all.where((r) => r.id == id).firstOrNull;
});

final menuProvider = FutureProvider.family<RestaurantMenu, String>(
  (ref, restaurantId) => ref.watch(restaurantsRepositoryProvider).fetchMenu(restaurantId),
);

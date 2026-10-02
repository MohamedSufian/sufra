import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/settings_controller.dart';
import '../data/restaurants_repository.dart';
import '../domain/models.dart';

final categoriesProvider = FutureProvider<List<FoodCategory>>(
  (ref) => ref.watch(restaurantsRepositoryProvider).fetchCategories(),
);

final restaurantsProvider = FutureProvider<List<Restaurant>>(
  (ref) => ref.watch(restaurantsRepositoryProvider).fetchRestaurants(),
);

class SelectedCategory extends Notifier<String> {
  @override
  String build() => FoodCategory.allId;

  void select(String id) => state = id;
}

final selectedCategoryProvider = NotifierProvider<SelectedCategory, String>(SelectedCategory.new);

class SearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

final searchQueryProvider = NotifierProvider<SearchQuery, String>(SearchQuery.new);

/// Applies the selected category and search text to a loaded list.
List<Restaurant> filterRestaurants(List<Restaurant> all, String categoryId, String query) {
  return [
    for (final r in all)
      if ((categoryId == FoodCategory.allId || r.categoryIds.contains(categoryId)) &&
          (query.trim().isEmpty || r.name.matches(query) || r.cuisine.matches(query)))
        r,
  ];
}

/// Favorite restaurant ids, kept on the device for now (moves to the account after sign-in).
class Favorites extends Notifier<Set<String>> {
  static const _key = 'favorites.restaurantIds';

  @override
  Set<String> build() {
    final raw = ref.watch(sharedPreferencesProvider).getString(_key);
    return raw == null ? {} : (jsonDecode(raw) as List).cast<String>().toSet();
  }

  void toggle(String id) {
    state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
    ref.read(sharedPreferencesProvider).setString(_key, jsonEncode(state.toList()));
  }
}

final favoritesProvider = NotifierProvider<Favorites, Set<String>>(Favorites.new);

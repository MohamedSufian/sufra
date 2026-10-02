import 'package:flutter/painting.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models.dart';
import 'restaurants_repository.dart';

/// Reads the catalog from Supabase (see supabase/schema.sql). Mapping lives in [CatalogRows]
/// so it can be tested without a server.
class SupabaseRestaurantsRepository implements RestaurantsRepository {
  SupabaseRestaurantsRepository(this._db);

  final SupabaseClient _db;

  // postgrest's .order() sorts descending unless told otherwise, hence ascending: true everywhere.
  @override
  Future<List<FoodCategory>> fetchCategories() async {
    final rows = await _db.from('categories').select().order('sort', ascending: true);
    return [for (final r in rows) CatalogRows.category(r)];
  }

  @override
  Future<List<Restaurant>> fetchRestaurants() async {
    final rows = await _db.from('restaurants').select().order('sort', ascending: true);
    return [for (final r in rows) CatalogRows.restaurant(r)];
  }

  @override
  Future<RestaurantMenu> fetchMenu(String restaurantId) async {
    final (sections, products) = await (
      _db.from('menu_sections').select().eq('restaurant_id', restaurantId).order('sort', ascending: true),
      // One round trip: dishes with their option groups and choices embedded.
      _db.from('products').select('*, option_groups(*, option_choices(*))').eq('restaurant_id', restaurantId).order('sort', ascending: true),
    ).wait;
    return RestaurantMenu(
      sections: [for (final s in sections) CatalogRows.section(s)],
      products: [for (final p in products) CatalogRows.product(p)],
    );
  }
}

/// Database rows → app models.
abstract final class CatalogRows {
  static LocalizedText _text(Map<String, dynamic> row, String column) =>
      LocalizedText(ar: row['${column}_ar'] as String, en: row['${column}_en'] as String);

  /// '#AARRGGBB' → Color.
  static Color color(String hex) => Color(int.parse(hex.replaceFirst('#', ''), radix: 16));

  static int _bySort(Map<String, dynamic> a, Map<String, dynamic> b) => (a['sort'] as int).compareTo(b['sort'] as int);

  static FoodCategory category(Map<String, dynamic> r) =>
      FoodCategory(id: r['id'] as String, name: _text(r, 'name'), dotColor: color(r['dot_color'] as String));

  static Restaurant restaurant(Map<String, dynamic> r) => Restaurant(
    id: r['id'] as String,
    name: _text(r, 'name'),
    cuisine: _text(r, 'cuisine'),
    area: _text(r, 'area'),
    rating: (r['rating'] as num).toDouble(),
    ratingCount: r['rating_count'] as int,
    deliveryMinMinutes: r['delivery_min'] as int,
    deliveryMaxMinutes: r['delivery_max'] as int,
    deliveryFee: r['delivery_fee'] as int,
    minOrder: r['min_order'] as int,
    isOpen: r['is_open'] as bool,
    categoryIds: {...(r['category_ids'] as List).cast<String>()},
    artIndex: r['art_index'] as int,
    latitude: (r['lat'] as num).toDouble(),
    longitude: (r['lng'] as num).toDouble(),
  );

  static MenuSection section(Map<String, dynamic> r) => MenuSection(id: r['id'] as String, name: _text(r, 'name'));

  static Product product(Map<String, dynamic> r) {
    final groups = [...(r['option_groups'] as List? ?? const []).cast<Map<String, dynamic>>()]..sort(_bySort);
    return Product(
      id: r['id'] as String,
      restaurantId: r['restaurant_id'] as String,
      sectionId: r['section_id'] as String,
      name: _text(r, 'name'),
      description: _text(r, 'desc'),
      price: r['price'] as int,
      artIndex: r['art_index'] as int,
      isPopular: r['is_popular'] as bool,
      isAvailable: r['is_available'] as bool,
      optionGroups: [
        for (final g in groups)
          OptionGroup(
            id: g['id'] as String,
            name: _text(g, 'name'),
            isRequired: g['is_required'] as bool,
            maxSelections: g['max_selections'] as int,
            choices: [
              for (final c in [...(g['option_choices'] as List? ?? const []).cast<Map<String, dynamic>>()]..sort(_bySort))
                OptionChoice(id: c['id'] as String, name: _text(c, 'name'), priceDelta: c['price_delta'] as int),
            ],
          ),
      ],
    );
  }
}

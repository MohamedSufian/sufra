import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backend/backend.dart';
import '../domain/models.dart';
import 'fake_menus.dart';
import 'supabase_restaurants_repository.dart';

/// The screens only know this interface; the fake below gets swapped for Supabase later.
abstract interface class RestaurantsRepository {
  Future<List<FoodCategory>> fetchCategories();
  Future<List<Restaurant>> fetchRestaurants();
  Future<RestaurantMenu> fetchMenu(String restaurantId);
}

/// Supabase when it's configured, the built-in sample data otherwise (demo mode).
final restaurantsRepositoryProvider = Provider<RestaurantsRepository>((ref) {
  final db = ref.watch(supabaseProvider);
  return db == null ? FakeRestaurantsRepository() : SupabaseRestaurantsRepository(db);
});

/// Sample Gaza data with a network-like delay. Names are made up.
class FakeRestaurantsRepository implements RestaurantsRepository {
  FakeRestaurantsRepository({this.delay = const Duration(milliseconds: 900)});

  final Duration delay;

  @override
  Future<List<FoodCategory>> fetchCategories() async {
    await Future<void>.delayed(delay);
    return _categories;
  }

  @override
  Future<List<Restaurant>> fetchRestaurants() async {
    await Future<void>.delayed(delay);
    return _restaurants;
  }

  @override
  Future<RestaurantMenu> fetchMenu(String restaurantId) async {
    await Future<void>.delayed(delay);
    return fakeMenus[restaurantId] ?? const RestaurantMenu(sections: [], products: []);
  }

  static const _categories = [
    FoodCategory(id: FoodCategory.allId, name: LocalizedText(ar: 'الكل', en: 'All'), dotColor: Color(0x00000000)),
    FoodCategory(id: 'shawarma', name: LocalizedText(ar: 'شاورما', en: 'Shawarma'), dotColor: Color(0xFFE9A23B)),
    FoodCategory(id: 'grill', name: LocalizedText(ar: 'مشاوي', en: 'Grill'), dotColor: Color(0xFFFF5A36)),
    FoodCategory(id: 'falafel', name: LocalizedText(ar: 'فلافل', en: 'Falafel'), dotColor: Color(0xFF4FB063)),
    FoodCategory(id: 'sweets', name: LocalizedText(ar: 'حلويات', en: 'Sweets'), dotColor: Color(0xFFFFB627)),
    FoodCategory(id: 'seafood', name: LocalizedText(ar: 'سمك', en: 'Seafood'), dotColor: Color(0xFF2EC4B6)),
    FoodCategory(id: 'pizza', name: LocalizedText(ar: 'بيتزا', en: 'Pizza'), dotColor: Color(0xFFC0392B)),
  ];

  static const _restaurants = [
    Restaurant(
      id: 'bahr-grill',
      name: LocalizedText(ar: 'مشاوي البحر', en: 'Al-Bahr Grill'),
      cuisine: LocalizedText(ar: 'مشاوي · شاورما', en: 'Grill · Shawarma'),
      area: LocalizedText(ar: 'الرمال', en: 'Al-Rimal'),
      rating: 4.8, ratingCount: 312,
      deliveryMinMinutes: 25, deliveryMaxMinutes: 35, deliveryFee: 5, minOrder: 20,
      isOpen: true, categoryIds: {'grill', 'shawarma'}, artIndex: 0,
      latitude: 31.5240, longitude: 34.4420,
    ),
    Restaurant(
      id: 'rimal-knafeh',
      name: LocalizedText(ar: 'بيت كنافة الرمال', en: 'Rimal Knafeh House'),
      cuisine: LocalizedText(ar: 'حلويات · كنافة', en: 'Sweets · Knafeh'),
      area: LocalizedText(ar: 'الرمال', en: 'Al-Rimal'),
      rating: 4.9, ratingCount: 540,
      deliveryMinMinutes: 20, deliveryMaxMinutes: 30, deliveryFee: 5, minOrder: 15,
      isOpen: true, categoryIds: {'sweets'}, artIndex: 1,
      latitude: 31.5218, longitude: 34.4455,
    ),
    Restaurant(
      id: 'shati-falafel',
      name: LocalizedText(ar: 'فلافل الشاطئ', en: 'Shati Falafel'),
      cuisine: LocalizedText(ar: 'فلافل · فول · حمص', en: 'Falafel · Foul · Hummus'),
      area: LocalizedText(ar: 'الشاطئ', en: 'Al-Shati'),
      rating: 4.7, ratingCount: 228,
      deliveryMinMinutes: 15, deliveryMaxMinutes: 25, deliveryFee: 3, minOrder: 10,
      isOpen: true, categoryIds: {'falafel'}, artIndex: 2,
      latitude: 31.5330, longitude: 34.4460,
    ),
    Restaurant(
      id: 'saha-shawarma',
      name: LocalizedText(ar: 'شاورما الساحة', en: 'Al-Saha Shawarma'),
      cuisine: LocalizedText(ar: 'شاورما · سندويشات', en: 'Shawarma · Sandwiches'),
      area: LocalizedText(ar: 'الساحة', en: 'Al-Saha'),
      rating: 4.7, ratingCount: 402,
      deliveryMinMinutes: 20, deliveryMaxMinutes: 30, deliveryFee: 4, minOrder: 15,
      isOpen: true, categoryIds: {'shawarma'}, artIndex: 5,
      latitude: 31.5040, longitude: 34.4660,
    ),
    Restaurant(
      id: 'mina-seafood',
      name: LocalizedText(ar: 'سمك الميناء', en: 'Al-Mina Seafood'),
      cuisine: LocalizedText(ar: 'سمك · مأكولات بحرية', en: 'Fish · Seafood'),
      area: LocalizedText(ar: 'الميناء', en: 'Gaza Port'),
      rating: 4.6, ratingCount: 190,
      deliveryMinMinutes: 35, deliveryMaxMinutes: 45, deliveryFee: 7, minOrder: 40,
      isOpen: false, categoryIds: {'seafood'}, artIndex: 3,
      latitude: 31.5265, longitude: 34.4330,
    ),
    Restaurant(
      id: 'talhawa-pizza',
      name: LocalizedText(ar: 'بيتزا تل الهوا', en: 'Tal Al-Hawa Pizza'),
      cuisine: LocalizedText(ar: 'بيتزا · معجنات', en: 'Pizza · Pastries'),
      area: LocalizedText(ar: 'تل الهوا', en: 'Tal Al-Hawa'),
      rating: 4.3, ratingCount: 156,
      deliveryMinMinutes: 30, deliveryMaxMinutes: 40, deliveryFee: 5, minOrder: 25,
      isOpen: true, categoryIds: {'pizza'}, artIndex: 4,
      latitude: 31.5080, longitude: 34.4400,
    ),
  ];
}

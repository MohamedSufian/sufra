import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sufra/core/backend/backend.dart';
import 'package:sufra/core/settings/settings_controller.dart';
import 'package:sufra/features/address/address.dart';
import 'package:sufra/features/auth/auth.dart';
import 'package:sufra/features/cart/cart_controller.dart';
import 'package:sufra/features/home/data/restaurants_repository.dart';
import 'package:sufra/features/home/data/supabase_restaurants_repository.dart';
import 'package:sufra/features/home/domain/models.dart';
import 'package:sufra/features/orders/orders_controller.dart';

void main() {
  group('catalog rows (shapes from supabase/schema.sql)', () {
    test('category colors are #AARRGGBB; transparent means no dot', () {
      final c = CatalogRows.category({'id': 'all', 'name_ar': 'الكل', 'name_en': 'All', 'dot_color': '#00000000', 'sort': 0});
      expect(c.dotColor.a, 0);
      expect(CatalogRows.color('#FFFF5A36').toARGB32(), 0xFFFF5A36);
    });

    test('a restaurant row, with numeric(2,1) rating and text[] categories', () {
      final r = CatalogRows.restaurant({
        'id': 'bahr-grill', 'name_ar': 'مشاوي البحر', 'name_en': 'Al-Bahr Grill',
        'cuisine_ar': 'مشاوي', 'cuisine_en': 'Grill', 'area_ar': 'الرمال', 'area_en': 'Al-Rimal',
        'rating': 4.8, 'rating_count': 312, 'delivery_min': 25, 'delivery_max': 35, 'delivery_fee': 5,
        'min_order': 20, 'is_open': true, 'category_ids': ['grill', 'shawarma'], 'art_index': 0,
        'lat': 31.524, 'lng': 34.442, 'sort': 0,
      });
      expect(r.name.ar, 'مشاوي البحر');
      expect(r.categoryIds, {'grill', 'shawarma'});
      expect(r.latitude, 31.524);
    });

    test('a product with embedded option groups, sorted by their sort column', () {
      final p = CatalogRows.product({
        'id': 'bahr-grill.mix', 'restaurant_id': 'bahr-grill', 'section_id': 'grill',
        'name_ar': 'مشكل مشاوي', 'name_en': 'Mixed grill', 'desc_ar': '', 'desc_en': '',
        'price': 45, 'art_index': 0, 'is_popular': true, 'is_available': true, 'sort': 0,
        'option_groups': [
          {
            'id': 'extras', 'name_ar': 'إضافات', 'name_en': 'Extras', 'is_required': false, 'max_selections': 3, 'sort': 1,
            'option_choices': [
              {'id': 'extras.fries', 'name_ar': 'بطاطا', 'name_en': 'Fries', 'price_delta': 6, 'sort': 2},
              {'id': 'extras.bread', 'name_ar': 'خبز', 'name_en': 'Bread', 'price_delta': 2, 'sort': 0},
            ],
          },
          {
            'id': 'size', 'name_ar': 'الحجم', 'name_en': 'Size', 'is_required': true, 'max_selections': 1, 'sort': 0,
            'option_choices': [
              {'id': 'size.regular', 'name_ar': 'فردية', 'name_en': 'Single', 'price_delta': 0, 'sort': 0},
            ],
          },
        ],
      });
      expect(p.optionGroups.map((g) => g.id), ['size', 'extras']);
      expect(p.optionGroups.last.choices.map((c) => c.id), ['extras.bread', 'extras.fries']);
      expect(p.optionGroups.first.isRequired, isTrue);
    });

    test('the seed export and the app agree: every sample dish survives the round trip', () async {
      final repo = FakeRestaurantsRepository(delay: Duration.zero);
      final menu = await repo.fetchMenu('bahr-grill');
      for (final p in menu.products) {
        final row = {
          'id': p.id, 'restaurant_id': p.restaurantId, 'section_id': p.sectionId,
          'name_ar': p.name.ar, 'name_en': p.name.en, 'desc_ar': p.description.ar, 'desc_en': p.description.en,
          'price': p.price, 'art_index': p.artIndex, 'is_popular': p.isPopular, 'is_available': p.isAvailable,
          'option_groups': [
            for (final (gi, g) in p.optionGroups.indexed)
              {
                'id': g.id, 'name_ar': g.name.ar, 'name_en': g.name.en, 'is_required': g.isRequired,
                'max_selections': g.maxSelections, 'sort': gi,
                'option_choices': [
                  for (final (ci, c) in g.choices.indexed)
                    {'id': c.id, 'name_ar': c.name.ar, 'name_en': c.name.en, 'price_delta': c.priceDelta, 'sort': ci},
                ],
              },
          ],
        };
        final back = CatalogRows.product(row);
        expect(back.price, p.price);
        expect([for (final g in back.optionGroups) for (final c in g.choices) c.id],
            [for (final g in p.optionGroups) for (final c in g.choices) c.id]);
      }
    });
  });

  group('order rows', () {
    late Product mix;
    setUpAll(() async {
      mix = (await FakeRestaurantsRepository(delay: Duration.zero).fetchMenu('bahr-grill'))
          .products
          .firstWhere((p) => p.id == 'bahr-grill.mix');
    });

    test('place_order receives ids only, never prices', () {
      final family = mix.optionGroups.first.choices.last;
      final cart = CartState(
        restaurantId: 'bahr-grill',
        lines: [CartLine(product: mix, quantity: 2, choices: [family], note: 'بدون بصل')],
      );
      final lines = OrderRows.linesParam(cart);
      expect(lines.single, {'product_id': 'bahr-grill.mix', 'quantity': 2, 'choice_ids': ['size.family'], 'note': 'بدون بصل'});
      expect(lines.single.keys, isNot(contains('price')));
    });

    test('a returned order row becomes a PlacedOrder in local time', () {
      final o = OrderRows.order({
        'id': 1042,
        'user_id': '00000000-0000-0000-0000-000000000000',
        'restaurant_id': 'bahr-grill',
        'restaurant_ar': 'مشاوي البحر',
        'restaurant_en': 'Al-Bahr Grill',
        'restaurant_lat': 31.524,
        'restaurant_lng': 34.442,
        'lines': [
          {'product': mix.toJson(), 'quantity': 1, 'choices': [], 'note': ''},
        ],
        'address': {
          'id': 'a', 'label': 'home', 'lat': 31.518, 'lng': 34.464, 'areaAr': 'الدرج، غزة', 'areaEn': 'Ad-Daraj, Gaza',
          'landmark': 'قرب مسجد الشمعة', 'details': '', 'phone': '0591234567',
        },
        'payment': 'cash',
        'subtotal': 45,
        'delivery_fee': 5,
        'discount': 9,
        'promo_code': 'SUFRA20',
        'eta_min': 25,
        'eta_max': 35,
        'status': 'placed',
        'placed_at': '2026-10-02T10:00:00+00:00',
      });
      expect(o.id, 1042);
      expect(o.total, 45 + 5 - 9);
      expect(o.lines.single.product.id, mix.id);
      expect(o.address.landmark, 'قرب مسجد الشمعة');
      expect(o.placedAt.isUtc, isFalse);
      expect(o.placedAt.toUtc(), DateTime.utc(2026, 10, 2, 10));
      expect(o.restaurantLatitude, 31.524);
    });
  });

  test('addresses map to their table columns and back', () {
    const a = SavedAddress(
      id: 'a1', label: AddressLabel.work, latitude: 31.5, longitude: 34.4,
      area: LocalizedText(ar: 'الرمال، غزة', en: 'Al-Rimal, Gaza'), landmark: 'مقابل الصيدلية', phone: '0561234567',
      details: 'الطابق 3',
    );
    final row = a.toRow();
    expect(row.keys, containsAll(['area_ar', 'area_en', 'lat', 'lng']));
    expect(row.keys, isNot(contains('user_id'))); // set by the database from the signed-in user
    final back = SavedAddress.fromRow({...row, 'user_id': 'u', 'created_at': '2026-10-02T10:00:00Z'});
    expect(back.toJson(), a.toJson());
  });

  test('auth errors map to problems the screen can explain', () {
    expect(authProblemFor(const AuthException('x', code: 'invalid_credentials')), AuthProblem.invalidCredentials);
    expect(authProblemFor(const AuthException('x', code: 'email_not_confirmed')), AuthProblem.emailNotConfirmed);
    expect(authProblemFor(const AuthException('x', code: 'user_already_exists')), AuthProblem.userExists);
    expect(authProblemFor(const AuthException('x', code: 'weak_password')), AuthProblem.weakPassword);
    expect(authProblemFor(const AuthException('x')), AuthProblem.network);
  });

  test('the project URL is trimmed to its origin, whatever endpoint was copied', () {
    expect(BackendConfig.normalizeUrl('https://abc.supabase.co/rest/v1/'), 'https://abc.supabase.co');
    expect(BackendConfig.normalizeUrl(' https://abc.supabase.co/ '), 'https://abc.supabase.co');
    expect(BackendConfig.normalizeUrl('https://abc.supabase.co'), 'https://abc.supabase.co');
    expect(BackendConfig.normalizeUrl(''), '');
  });

  test('without Supabase settings the app runs in demo mode on sample data', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
    addTearDown(c.dispose);
    expect(BackendConfig.isConfigured, isFalse);
    expect(c.read(supabaseProvider), isNull);
    expect(c.read(authServiceProvider), isNull);
    expect(c.read(currentUserProvider), isNull);
    expect(c.read(restaurantsRepositoryProvider), isA<FakeRestaurantsRepository>());
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sufra/features/home/data/restaurants_repository.dart';
import 'package:sufra/features/home/domain/models.dart';
import 'package:sufra/features/home/presentation/restaurant_filters.dart';

void main() {
  late List<Restaurant> all;
  const gazaCenter = (latitude: 31.5170, longitude: 34.4530);

  setUpAll(() async {
    all = await FakeRestaurantsRepository(delay: Duration.zero).fetchRestaurants();
  });

  List<String> ids(RestaurantFilters f, [({double latitude, double longitude}) origin = gazaCenter]) =>
      [for (final r in f.apply(all, origin)) r.id];

  test('defaults keep everything, open places first and best rated on top', () {
    final list = ids(const RestaurantFilters());
    expect(list, hasLength(all.length));
    expect(list.first, 'rimal-knafeh'); // 4.9
    expect(list[1], 'bahr-grill'); // 4.8
    expect(list.last, 'mina-seafood'); // the only closed one, despite its 4.6
  });

  test('each "show only" switch narrows the list', () {
    expect(ids(const RestaurantFilters(openOnly: true)), isNot(contains('mina-seafood')));
    expect(ids(const RestaurantFilters(topRatedOnly: true)), isNot(contains('talhawa-pizza'))); // 4.3
    expect(ids(const RestaurantFilters(cheapDeliveryOnly: true)).toSet(), {'shati-falafel', 'saha-shawarma'});
    expect(
      ids(const RestaurantFilters(openOnly: true, topRatedOnly: true, cheapDeliveryOnly: true)).toSet(),
      {'shati-falafel', 'saha-shawarma'},
    );
  });

  test('top rated breaks rating ties by number of ratings', () {
    final list = ids(const RestaurantFilters(sort: RestaurantSort.rating));
    expect(list.take(2), ['rimal-knafeh', 'bahr-grill']);
    // Both 4.7: Al-Saha has 402 ratings, Shati 228.
    expect(list.indexOf('saha-shawarma'), lessThan(list.indexOf('shati-falafel')));
    expect(list.last, 'talhawa-pizza');
  });

  test('fastest and cheapest delivery', () {
    final fastest = ids(const RestaurantFilters(sort: RestaurantSort.fastest));
    expect(fastest.first, 'shati-falafel'); // 15-25 min
    expect(fastest.last, 'mina-seafood'); // 35-45 min

    final cheapest = ids(const RestaurantFilters(sort: RestaurantSort.deliveryFee));
    expect(cheapest.take(2), ['shati-falafel', 'saha-shawarma']); // ₪3, ₪4
    expect(cheapest.last, 'mina-seafood'); // ₪7
  });

  test('nearest depends on where the order goes', () {
    final fromShati = ids(const RestaurantFilters(sort: RestaurantSort.nearest), (latitude: 31.5330, longitude: 34.4460));
    expect(fromShati.first, 'shati-falafel');
    final fromSaha = ids(const RestaurantFilters(sort: RestaurantSort.nearest), (latitude: 31.5040, longitude: 34.4660));
    expect(fromSaha.first, 'saha-shawarma');
  });

  test('the filter button counts what differs from the defaults', () {
    expect(const RestaurantFilters().activeCount, 0);
    expect(const RestaurantFilters().isDefault, isTrue);
    expect(const RestaurantFilters(sort: RestaurantSort.nearest, openOnly: true).activeCount, 2);
    expect(const RestaurantFilters(openOnly: true).copyWith(openOnly: false).isDefault, isTrue);
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/maps/app_map.dart';
import '../../../core/maps/gaza_areas.dart';
import '../../address/addresses_controller.dart';
import '../domain/models.dart';

enum RestaurantSort { recommended, nearest, rating, fastest, deliveryFee }

@immutable
class RestaurantFilters {
  const RestaurantFilters({
    this.sort = RestaurantSort.recommended,
    this.openOnly = false,
    this.topRatedOnly = false,
    this.cheapDeliveryOnly = false,
  });

  static const topRating = 4.5;
  static const cheapDeliveryFee = 4;

  final RestaurantSort sort;
  final bool openOnly;
  final bool topRatedOnly;
  final bool cheapDeliveryOnly;

  /// How many settings differ from the defaults (shown on the filter button).
  int get activeCount =>
      (sort != RestaurantSort.recommended ? 1 : 0) + (openOnly ? 1 : 0) + (topRatedOnly ? 1 : 0) + (cheapDeliveryOnly ? 1 : 0);

  bool get isDefault => activeCount == 0;

  RestaurantFilters copyWith({RestaurantSort? sort, bool? openOnly, bool? topRatedOnly, bool? cheapDeliveryOnly}) =>
      RestaurantFilters(
        sort: sort ?? this.sort,
        openOnly: openOnly ?? this.openOnly,
        topRatedOnly: topRatedOnly ?? this.topRatedOnly,
        cheapDeliveryOnly: cheapDeliveryOnly ?? this.cheapDeliveryOnly,
      );

  /// Keeps the restaurants that pass, in the chosen order. Distances are from [origin].
  List<Restaurant> apply(List<Restaurant> all, MapPoint origin) {
    double km(Restaurant r) => distanceKm(origin, r);
    final kept = [
      for (final r in all)
        if ((!openOnly || r.isOpen) &&
            (!topRatedOnly || r.rating >= topRating) &&
            (!cheapDeliveryOnly || r.deliveryFee <= cheapDeliveryFee))
          r,
    ];
    int byOpen(Restaurant a, Restaurant b) => (b.isOpen ? 1 : 0) - (a.isOpen ? 1 : 0);
    final Comparator<Restaurant> order = switch (sort) {
      // Open places first, then the best rated, then the closest.
      RestaurantSort.recommended => (a, b) {
        final open = byOpen(a, b);
        if (open != 0) return open;
        final rating = b.rating.compareTo(a.rating);
        return rating != 0 ? rating : km(a).compareTo(km(b));
      },
      RestaurantSort.nearest => (a, b) => km(a).compareTo(km(b)),
      RestaurantSort.rating => (a, b) {
        final rating = b.rating.compareTo(a.rating);
        return rating != 0 ? rating : b.ratingCount.compareTo(a.ratingCount);
      },
      RestaurantSort.fastest => (a, b) {
        final max = a.deliveryMaxMinutes.compareTo(b.deliveryMaxMinutes);
        return max != 0 ? max : a.deliveryMinMinutes.compareTo(b.deliveryMinMinutes);
      },
      RestaurantSort.deliveryFee => (a, b) {
        final fee = a.deliveryFee.compareTo(b.deliveryFee);
        return fee != 0 ? fee : km(a).compareTo(km(b));
      },
    };
    return kept..sort(order);
  }

  static double distanceKm(MapPoint origin, Restaurant r) =>
      GazaAreas.distanceKm(origin.latitude, origin.longitude, r.latitude, r.longitude);
}

class RestaurantFiltersController extends Notifier<RestaurantFilters> {
  @override
  RestaurantFilters build() => const RestaurantFilters();

  void set(RestaurantFilters filters) => state = filters;

  void reset() => state = const RestaurantFilters();
}

final restaurantFiltersProvider =
    NotifierProvider<RestaurantFiltersController, RestaurantFilters>(RestaurantFiltersController.new);

/// Where distances are measured from: the selected address, else Gaza City center.
final distanceOriginProvider = Provider<({MapPoint point, bool fromAddress})>((ref) {
  final address = ref.watch(addressesProvider.select((b) => b.selected));
  return address == null
      ? (point: (latitude: GazaAreas.defaultLatitude, longitude: GazaAreas.defaultLongitude), fromAddress: false)
      : (point: (latitude: address.latitude, longitude: address.longitude), fromAddress: true);
});

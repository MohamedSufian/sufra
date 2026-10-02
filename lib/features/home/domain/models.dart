import 'package:flutter/widgets.dart';

/// Text stored in both languages, as it will be in the database (name_ar / name_en).
@immutable
class LocalizedText {
  const LocalizedText({required this.ar, required this.en});

  final String ar;
  final String en;

  String resolve(Locale locale) => locale.languageCode == 'ar' ? ar : en;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    return ar.contains(q) || en.toLowerCase().contains(q);
  }
}

@immutable
class FoodCategory {
  const FoodCategory({required this.id, required this.name, required this.dotColor});

  static const allId = 'all';

  final String id;
  final LocalizedText name;
  final Color dotColor;
}

@immutable
class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.area,
    required this.rating,
    required this.ratingCount,
    required this.deliveryMinMinutes,
    required this.deliveryMaxMinutes,
    required this.deliveryFee,
    required this.minOrder,
    required this.isOpen,
    required this.categoryIds,
    required this.artIndex,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final LocalizedText name;
  final LocalizedText cuisine;
  final LocalizedText area;
  final double rating;
  final int ratingCount;
  final int deliveryMinMinutes;
  final int deliveryMaxMinutes;

  /// Shekels.
  final int deliveryFee;
  final int minOrder;
  final bool isOpen;
  final Set<String> categoryIds;

  /// Which illustrated plate to show until real photos exist.
  final int artIndex;
  final double latitude;
  final double longitude;
}

@immutable
class MenuSection {
  const MenuSection({required this.id, required this.name});

  final String id;
  final LocalizedText name;
}

/// One pick inside an [OptionGroup], e.g. "Large" or "Extra cheese".
@immutable
class OptionChoice {
  const OptionChoice({required this.id, required this.name, this.priceDelta = 0});

  /// Unique within its product (prefixed with the group id).
  final String id;
  final LocalizedText name;

  /// Shekels added to the dish price.
  final int priceDelta;

  Map<String, Object?> toJson() => {'id': id, 'nameAr': name.ar, 'nameEn': name.en, 'priceDelta': priceDelta};

  factory OptionChoice.fromJson(Map<String, Object?> json) => OptionChoice(
    id: json['id']! as String,
    name: LocalizedText(ar: json['nameAr']! as String, en: json['nameEn']! as String),
    priceDelta: json['priceDelta']! as int,
  );
}

/// A set of choices for a dish: a required size, optional extras, and so on.
@immutable
class OptionGroup {
  const OptionGroup({
    required this.id,
    required this.name,
    required this.choices,
    this.isRequired = false,
    this.maxSelections = 1,
  });

  final String id;
  final LocalizedText name;
  final List<OptionChoice> choices;

  /// At least one choice must be picked.
  final bool isRequired;
  final int maxSelections;

  bool get isSingle => maxSelections == 1;
}

@immutable
class Product {
  const Product({
    required this.id,
    required this.restaurantId,
    required this.sectionId,
    required this.name,
    required this.description,
    required this.price,
    required this.artIndex,
    this.isPopular = false,
    this.isAvailable = true,
    this.optionGroups = const [],
  });

  final String id;
  final String restaurantId;
  final String sectionId;
  final LocalizedText name;
  final LocalizedText description;

  /// Shekels.
  final int price;
  final int artIndex;
  final bool isPopular;
  final bool isAvailable;
  final List<OptionGroup> optionGroups;

  bool get hasOptions => optionGroups.isNotEmpty;

  /// Enough to show a saved cart line without reloading the menu (option groups aren't needed there).
  Map<String, Object?> toJson() => {
    'id': id,
    'restaurantId': restaurantId,
    'sectionId': sectionId,
    'nameAr': name.ar,
    'nameEn': name.en,
    'descAr': description.ar,
    'descEn': description.en,
    'price': price,
    'artIndex': artIndex,
  };

  factory Product.fromJson(Map<String, Object?> json) => Product(
    id: json['id']! as String,
    restaurantId: json['restaurantId']! as String,
    sectionId: json['sectionId']! as String,
    name: LocalizedText(ar: json['nameAr']! as String, en: json['nameEn']! as String),
    description: LocalizedText(ar: json['descAr']! as String, en: json['descEn']! as String),
    price: json['price']! as int,
    artIndex: json['artIndex']! as int,
  );
}

@immutable
class RestaurantMenu {
  const RestaurantMenu({required this.sections, required this.products});

  final List<MenuSection> sections;
  final List<Product> products;

  bool get isEmpty => products.isEmpty;

  List<Product> productsIn(String sectionId) => [
    for (final p in products)
      if (p.sectionId == sectionId) p,
  ];
}

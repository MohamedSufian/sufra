import 'package:material_ui/material_ui.dart';

import '../home/domain/models.dart';

enum AddressLabel { home, work, other }

/// Where an order goes. In Gaza a pin plus a landmark ("near the mosque…") finds a door
/// better than a street address.
@immutable
class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.area,
    required this.landmark,
    required this.phone,
    this.details = '',
  });

  final String id;
  final AddressLabel label;
  final double latitude;
  final double longitude;
  final LocalizedText area;
  final String landmark;

  /// Street, building, floor — optional.
  final String details;
  final String phone;

  Map<String, Object?> toJson() => {
    'id': id,
    'label': label.name,
    'lat': latitude,
    'lng': longitude,
    'areaAr': area.ar,
    'areaEn': area.en,
    'landmark': landmark,
    'details': details,
    'phone': phone,
  };

  /// The addresses table's columns (supabase/schema.sql); user_id is filled in by the database.
  Map<String, Object?> toRow() => {
    'id': id,
    'label': label.name,
    'lat': latitude,
    'lng': longitude,
    'area_ar': area.ar,
    'area_en': area.en,
    'landmark': landmark,
    'details': details,
    'phone': phone,
  };

  factory SavedAddress.fromRow(Map<String, dynamic> row) => SavedAddress.fromJson({
    ...row,
    'areaAr': row['area_ar'],
    'areaEn': row['area_en'],
  });

  factory SavedAddress.fromJson(Map<String, Object?> json) => SavedAddress(
    id: json['id']! as String,
    label: AddressLabel.values.asNameMap()[json['label']] ?? AddressLabel.other,
    latitude: (json['lat']! as num).toDouble(),
    longitude: (json['lng']! as num).toDouble(),
    area: LocalizedText(ar: json['areaAr']! as String, en: json['areaEn']! as String),
    landmark: json['landmark']! as String,
    details: json['details'] as String? ?? '',
    phone: json['phone']! as String,
  );
}

/// A pin the user confirmed on the map, on its way to the details form.
@immutable
class AddressDraft {
  const AddressDraft({required this.latitude, required this.longitude, required this.area, this.editing});

  final double latitude;
  final double longitude;
  final LocalizedText area;

  /// The saved address being changed, if any.
  final SavedAddress? editing;
}

abstract final class PhoneNumbers {
  /// Jawwal (059) and Ooredoo (056) mobiles, with an optional +970/+972 prefix.
  static final _mobile = RegExp(r'^(?:(?:\+|00)97[02]|0)5[69]\d{7}$');

  static String normalize(String input) => input.replaceAll(RegExp(r'[\s\-()]'), '');

  static bool isValidMobile(String input) => _mobile.hasMatch(normalize(input));
}

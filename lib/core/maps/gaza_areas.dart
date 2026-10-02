import 'dart:math' as math;

import '../../features/home/domain/models.dart';

/// Gaza neighborhoods and towns with an approximate center. Matching a pin to the nearest one
/// works offline, unlike a reverse-geocoding service.
class GazaArea {
  const GazaArea(this.name, this.latitude, this.longitude);

  final LocalizedText name;
  final double latitude;
  final double longitude;
}

abstract final class GazaAreas {
  /// Gaza City center; where the map opens when we know nothing better.
  static const defaultLatitude = 31.5170;
  static const defaultLongitude = 34.4530;

  /// Farther than this from every known area counts as outside the delivery zone.
  static const maxDistanceKm = 4.0;

  static const all = [
    GazaArea(LocalizedText(ar: 'الرمال، غزة', en: 'Al-Rimal, Gaza'), 31.5230, 34.4440),
    GazaArea(LocalizedText(ar: 'تل الهوا، غزة', en: 'Tal al-Hawa, Gaza'), 31.5030, 34.4350),
    GazaArea(LocalizedText(ar: 'الشيخ رضوان، غزة', en: 'Sheikh Radwan, Gaza'), 31.5370, 34.4610),
    GazaArea(LocalizedText(ar: 'النصر، غزة', en: 'An-Nasr, Gaza'), 31.5310, 34.4550),
    GazaArea(LocalizedText(ar: 'الشاطئ، غزة', en: 'Al-Shati, Gaza'), 31.5330, 34.4460),
    GazaArea(LocalizedText(ar: 'الشجاعية، غزة', en: "Shuja'iyya, Gaza"), 31.5100, 34.4800),
    GazaArea(LocalizedText(ar: 'الزيتون، غزة', en: 'Az-Zeitoun, Gaza'), 31.4990, 34.4580),
    GazaArea(LocalizedText(ar: 'الدرج، غزة', en: 'Ad-Daraj, Gaza'), 31.5180, 34.4640),
    GazaArea(LocalizedText(ar: 'التفاح، غزة', en: 'At-Tuffah, Gaza'), 31.5230, 34.4750),
    GazaArea(LocalizedText(ar: 'الصبرة، غزة', en: 'As-Sabra, Gaza'), 31.5080, 34.4560),
    GazaArea(LocalizedText(ar: 'الشيخ عجلين، غزة', en: 'Sheikh Ijlin, Gaza'), 31.4930, 34.4400),
    GazaArea(LocalizedText(ar: 'جباليا', en: 'Jabalia'), 31.5330, 34.4900),
    GazaArea(LocalizedText(ar: 'بيت لاهيا', en: 'Beit Lahia'), 31.5480, 34.4990),
    GazaArea(LocalizedText(ar: 'بيت حانون', en: 'Beit Hanoun'), 31.5390, 34.5370),
    GazaArea(LocalizedText(ar: 'النصيرات', en: 'Nuseirat'), 31.4500, 34.3930),
    GazaArea(LocalizedText(ar: 'البريج', en: 'Bureij'), 31.4400, 34.4030),
    GazaArea(LocalizedText(ar: 'المغازي', en: 'Maghazi'), 31.4220, 34.3880),
    GazaArea(LocalizedText(ar: 'دير البلح', en: 'Deir al-Balah'), 31.4180, 34.3520),
    GazaArea(LocalizedText(ar: 'خانيونس', en: 'Khan Younis'), 31.3460, 34.3060),
    GazaArea(LocalizedText(ar: 'رفح', en: 'Rafah'), 31.2870, 34.2510),
  ];

  /// The closest known area, or null when the point is outside the delivery zone.
  static GazaArea? nearest(double latitude, double longitude) {
    GazaArea? best;
    var bestKm = double.infinity;
    for (final a in all) {
      final km = distanceKm(latitude, longitude, a.latitude, a.longitude);
      if (km < bestKm) {
        best = a;
        bestKm = km;
      }
    }
    return bestKm <= maxDistanceKm ? best : null;
  }

  /// Great-circle distance (haversine).
  static double distanceKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    double rad(double d) => d * math.pi / 180;
    final dLat = rad(lat2 - lat1);
    final dLng = rad(lng2 - lng1);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.pow(math.sin(dLng / 2), 2);
    return 2 * r * math.asin(math.sqrt(a));
  }
}

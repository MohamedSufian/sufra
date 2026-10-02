import 'app_map.dart';

/// A gently curved stand-in for the street route between two points, until a routing
/// service draws the real one. Points run from [from] to [to].
List<MapPoint> curvedRoute(MapPoint from, MapPoint to, {int segments = 48, double bend = 0.18}) {
  // Quadratic Bézier whose control point sits off the midpoint, perpendicular to the straight line.
  final dLat = to.latitude - from.latitude;
  final dLng = to.longitude - from.longitude;
  final control = (
    latitude: (from.latitude + to.latitude) / 2 - dLng * bend,
    longitude: (from.longitude + to.longitude) / 2 + dLat * bend,
  );
  return [
    for (var i = 0; i <= segments; i++)
      () {
        final t = i / segments;
        final a = (1 - t) * (1 - t), b = 2 * (1 - t) * t, c = t * t;
        return (
          latitude: a * from.latitude + b * control.latitude + c * to.latitude,
          longitude: a * from.longitude + b * control.longitude + c * to.longitude,
        );
      }(),
  ];
}

/// Splits [route] at [progress] (0..1): the part already travelled and the part ahead,
/// sharing the point where the rider is.
({List<MapPoint> done, List<MapPoint> ahead, MapPoint at}) splitRoute(List<MapPoint> route, double progress) {
  final exact = progress.clamp(0.0, 1.0) * (route.length - 1);
  final i = exact.floor().clamp(0, route.length - 2);
  final t = exact - i;
  final p = route[i], q = route[i + 1];
  final at = (latitude: p.latitude + (q.latitude - p.latitude) * t, longitude: p.longitude + (q.longitude - p.longitude) * t);
  return (done: [...route.sublist(0, i + 1), at], ahead: [at, ...route.sublist(i + 1)], at: at);
}

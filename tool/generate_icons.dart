// Generates the app icon and splash images from the Sufra logo geometry.
// Run: dart run tool/generate_icons.dart
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const coral = [0xFF, 0x5A, 0x36, 255];
const ember = [0xD7, 0x40, 0x1B, 255];
const white = [0xFF, 0xFF, 0xFF, 255];
const clear = [0, 0, 0, 0];

/// What the logo paints at a point in its 64x64 design space.
enum _Hit { none, pin, cut }

final _steamA = _steamPolyline(27);
final _steamB = _steamPolyline(37);

List<math.Point<double>> _steamPolyline(double x0) => [
  for (var i = 0; i <= 40; i++)
    math.Point(x0 - 1.6 * math.sin(2 * math.pi * i / 40), 12 + 8 * i / 40),
];

double _distToPolyline(double x, double y, List<math.Point<double>> pts) {
  var best = double.infinity;
  for (var i = 0; i < pts.length - 1; i++) {
    final a = pts[i], b = pts[i + 1];
    final dx = b.x - a.x, dy = b.y - a.y;
    final t = (((x - a.x) * dx + (y - a.y) * dy) / (dx * dx + dy * dy)).clamp(0.0, 1.0);
    final px = a.x + t * dx - x, py = a.y + t * dy - y;
    best = math.min(best, math.sqrt(px * px + py * py));
  }
  return best;
}

_Hit _logoAt(double x, double y) {
  // Pin: circle + cone down to the tip.
  const cx = 32.0, cy = 26.6, r = 23.0, tipY = 60.0;
  final inCircle = (x - cx) * (x - cx) + (y - cy) * (y - cy) <= r * r;
  final vx = x - cx, vy = y - tipY;
  final d = tipY - cy;
  final half = math.asin(r / d);
  // The cone only runs from the tip up to the tangent points; the circle covers the rest.
  final coneHeight = math.sqrt(d * d - r * r) * math.cos(half);
  final inCone = vy <= 0 && -vy <= coneHeight && math.atan2(vx.abs(), -vy) <= half;
  if (!inCircle && !inCone) return _Hit.none;

  // Bowl: lower half-disc.
  if (y >= 27 && (x - 32) * (x - 32) + (y - 27) * (y - 27) <= 13 * 13) return _Hit.cut;

  // Steam: two wavy strokes.
  if (x > 22 && x < 42 && y > 10 && y < 22) {
    if (_distToPolyline(x, y, _steamA) <= 1.5 || _distToPolyline(x, y, _steamB) <= 1.5) {
      return _Hit.cut;
    }
  }
  return _Hit.pin;
}

bool _inRoundRect(double x, double y, double l, double t, double s, double rad) {
  if (x < l || y < t || x > l + s || y > t + s) return false;
  final qx = math.max(math.max(l + rad - x, x - (l + s - rad)), 0.0);
  final qy = math.max(math.max(t + rad - y, y - (t + s - rad)), 0.0);
  return qx * qx + qy * qy <= rad * rad;
}

void render(
  String path, {
  required int size,
  required List<int> background,
  List<int>? tile,
  double tileFraction = 0,
  required List<int> pin,
  required List<int> cut,
  required double logoFraction,
}) {
  final image = img.Image(width: size, height: size, numChannels: 4);
  final logoSize = size * logoFraction;
  final unit = logoSize / 64;
  final ox = (size - logoSize) / 2;
  final oy = (size - logoSize) / 2;
  final tileSize = size * tileFraction;
  final tileOrigin = (size - tileSize) / 2;
  const ss = 4; // supersampling per axis

  for (var py = 0; py < size; py++) {
    for (var px = 0; px < size; px++) {
      var r = 0.0, g = 0.0, b = 0.0, a = 0.0;
      for (var sy = 0; sy < ss; sy++) {
        for (var sx = 0; sx < ss; sx++) {
          final x = px + (sx + 0.5) / ss;
          final y = py + (sy + 0.5) / ss;
          var c = background;
          if (tile != null && _inRoundRect(x, y, tileOrigin, tileOrigin, tileSize, tileSize * 0.28)) {
            c = tile;
          }
          switch (_logoAt((x - ox) / unit, (y - oy) / unit)) {
            case _Hit.pin:
              c = pin;
            case _Hit.cut:
              c = cut;
            case _Hit.none:
              break;
          }
          // Premultiplied accumulation keeps transparent edges clean.
          final ca = c[3] / 255;
          r += c[0] * ca;
          g += c[1] * ca;
          b += c[2] * ca;
          a += ca;
        }
      }
      const n = ss * ss;
      final alpha = a / n;
      image.setPixelRgba(
        px,
        py,
        alpha == 0 ? 0 : (r / n / alpha).round(),
        alpha == 0 ? 0 : (g / n / alpha).round(),
        alpha == 0 ? 0 : (b / n / alpha).round(),
        (alpha * 255).round(),
      );
    }
  }
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(img.encodePng(image));
  stdout.writeln('wrote $path');
}

void main() {
  const dir = 'assets/icon';
  render('$dir/app_icon.png',
      size: 1024, background: coral, pin: white, cut: coral, logoFraction: 0.62);
  render('$dir/app_icon_foreground.png',
      size: 1024, background: clear, pin: white, cut: coral, logoFraction: 0.46);
  render('$dir/splash_logo.png',
      size: 512, background: clear, tile: white, tileFraction: 0.62,
      pin: coral, cut: white, logoFraction: 0.4);
  render('$dir/splash_logo_android12.png',
      size: 1152, background: clear, pin: white, cut: ember, logoFraction: 0.4);
  render('$dir/logo_mark.png',
      size: 512, background: clear, pin: coral, cut: clear, logoFraction: 1);
}

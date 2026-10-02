import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

/// The one place that knows which map SDK we use (OpenStreetMap via flutter_map today).
/// Moving to Google Maps means rewriting this file; screens only use [AppMap] and the types below.
class AppMapController {
  final _inner = MapController();

  void moveTo(double latitude, double longitude, {double? zoom}) =>
      _inner.move(LatLng(latitude, longitude), zoom ?? _inner.camera.zoom);

  void dispose() => _inner.dispose();
}

typedef MapPoint = ({double latitude, double longitude});

/// A widget pinned to a map point; [anchorBottom] puts the point at the child's bottom (pins)
/// instead of its center (dots).
@immutable
class AppMapMarker {
  const AppMapMarker({
    required this.point,
    required this.child,
    this.size = 44,
    this.anchorBottom = false,
  });

  final MapPoint point;
  final Widget child;
  final double size;
  final bool anchorBottom;
}

@immutable
class AppMapLine {
  const AppMapLine({
    required this.points,
    required this.color,
    this.width = 5,
    this.dashed = false,
  });

  final List<MapPoint> points;
  final Color color;
  final double width;
  final bool dashed;
}

class AppMap extends StatefulWidget {
  const AppMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 16,
    this.controller,
    this.interactive = true,
    this.onMoveStart,
    this.onMoveEnd,
    this.markers = const [],
    this.lines = const [],
    this.fitPoints = const [],
    this.fitPadding = const EdgeInsets.all(48),
  });

  final double latitude;
  final double longitude;
  final double zoom;
  final AppMapController? controller;
  final bool interactive;
  final VoidCallback? onMoveStart;

  /// Called with the map center once the user (or [AppMapController]) stops moving it.
  final void Function(double latitude, double longitude)? onMoveEnd;

  final List<AppMapMarker> markers;
  final List<AppMapLine> lines;

  /// When given, the map opens framing all of these instead of at [latitude]/[longitude].
  final List<MapPoint> fitPoints;
  final EdgeInsets fitPadding;

  static LatLng _ll(MapPoint p) => LatLng(p.latitude, p.longitude);

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  // Built once: fresh MapOptions on every rebuild (the tracking screen rebuilds each second)
  // keep resetting the map and cancel tile loads. Only a theme switch rebuilds them.
  MapOptions? _options;
  Brightness? _optionsBrightness;

  MapOptions _buildOptions(BuildContext context) {
    final w = widget;
    return MapOptions(
      initialCenter: LatLng(w.latitude, w.longitude),
      initialZoom: w.zoom,
      initialCameraFit: w.fitPoints.length < 2
          ? null
          : CameraFit.coordinates(
              coordinates: [for (final p in w.fitPoints) AppMap._ll(p)],
              padding: w.fitPadding,
              maxZoom: 17,
            ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      minZoom: 11,
      maxZoom: 19,
      interactionOptions: InteractionOptions(
        flags: w.interactive
            ? InteractiveFlag.all & ~InteractiveFlag.rotate
            : InteractiveFlag.none,
      ),
      // Reads the callbacks from the current widget, so they stay fresh without new options.
      onMapEvent: (event) {
        if (event is MapEventMoveStart) widget.onMoveStart?.call();
        if (event is MapEventMoveEnd ||
            event is MapEventFlingAnimationEnd ||
            event is MapEventScrollWheelZoom) {
          widget.onMoveEnd?.call(
            event.camera.center.latitude,
            event.camera.center.longitude,
          );
        }
        if (event is MapEventMove &&
            event.source == MapEventSource.mapController) {
          widget.onMoveEnd?.call(
            event.camera.center.latitude,
            event.camera.center.longitude,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final brightness = Theme.of(context).brightness;
    if (_options == null || _optionsBrightness != brightness) {
      _options = _buildOptions(context);
      _optionsBrightness = brightness;
    }
    final dark = brightness == Brightness.dark;
    // flutter_map still builds with the legacy Material library; the bridge hands it our theme.
    // The bridge is deprecated by design (a migration aid); drop it once flutter_map moves to material_ui.
    // ignore: deprecated_member_use
    return MaterialUiCompatibilityBridge(
      child: FlutterMap(
        mapController: w.controller?._inner,
        options: _options!,
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'ps.sufra.sufra',
            tileBuilder: dark ? darkModeTileBuilder : null,
          ),
          if (w.lines.isNotEmpty)
            PolylineLayer(
              polylines: [
                for (final l in w.lines)
                  Polyline(
                    points: [for (final p in l.points) AppMap._ll(p)],
                    color: l.color,
                    strokeWidth: l.width,
                    strokeCap: StrokeCap.round,
                    strokeJoin: StrokeJoin.round,
                    pattern: l.dashed
                        ? StrokePattern.dashed(segments: [2, l.width * 2.4])
                        : const StrokePattern.solid(),
                  ),
              ],
            ),
          if (w.markers.isNotEmpty)
            MarkerLayer(
              markers: [
                for (final m in w.markers)
                  Marker(
                    point: AppMap._ll(m.point),
                    width: m.size,
                    height: m.size,
                    alignment: m.anchorBottom
                        ? Alignment.topCenter
                        : Alignment.center,
                    child: m.child,
                  ),
              ],
            ),
          // OSM requires visible credit; the compact (i) button keeps small previews clear.
          RichAttributionWidget(
            alignment: AttributionAlignment.bottomLeft,
            showFlutterMapAttribution: false,
            attributions: [TextSourceAttribution('OpenStreetMap contributors')],
          ),
        ],
      ),
    );
  }
}

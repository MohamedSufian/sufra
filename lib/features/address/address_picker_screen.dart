import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/location/location_service.dart';
import '../../core/maps/app_map.dart';
import '../../core/maps/gaza_areas.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/context_x.dart';
import '../../core/widgets/sufra_logo.dart';
import 'address.dart';

/// Step 1 of adding an address: move the map under a fixed pin. Pops with the saved address.
class AddressPickerScreen extends StatefulWidget {
  const AddressPickerScreen({super.key, this.editing});

  final SavedAddress? editing;

  @override
  State<AddressPickerScreen> createState() => _AddressPickerScreenState();
}

class _AddressPickerScreenState extends State<AddressPickerScreen> {
  final _map = AppMapController();
  late double _lat = widget.editing?.latitude ?? GazaAreas.defaultLatitude;
  late double _lng = widget.editing?.longitude ?? GazaAreas.defaultLongitude;
  late GazaArea? _area = GazaAreas.nearest(_lat, _lng);
  var _moving = false;
  var _locating = false;

  @override
  void initState() {
    super.initState();
    // A new address starts from where the user is, when we may ask.
    if (widget.editing == null) WidgetsBinding.instance.addPostFrameCallback((_) => _locate(quiet: true));
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  void _onMoveEnd(double lat, double lng) {
    setState(() {
      _moving = false;
      _lat = lat;
      _lng = lng;
      _area = GazaAreas.nearest(lat, lng);
    });
  }

  /// [quiet]: on open, don't nag about missing permission; the map works without it.
  Future<void> _locate({bool quiet = false}) async {
    setState(() => _locating = true);
    final result = await currentLocation();
    if (!mounted) return;
    setState(() => _locating = false);
    final l10n = context.l10n;
    final message = switch (result) {
      LocationFound(:final latitude, :final longitude) when GazaAreas.nearest(latitude, longitude) == null =>
        l10n.locationOutside,
      LocationFound(:final latitude, :final longitude) => () {
        _map.moveTo(latitude, longitude, zoom: 17);
        return null;
      }(),
      LocationServiceOff() => l10n.locationDisabled,
      LocationDenied() => quiet ? null : l10n.locationDenied,
      LocationFailed() => quiet ? null : l10n.locationFailed,
    };
    if (message != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _confirm() async {
    final area = _area;
    if (area == null) return;
    final saved = await context.push<SavedAddress>(
      AppRoutes.addressDetails,
      extra: AddressDraft(latitude: _lat, longitude: _lng, area: area.name, editing: widget.editing),
    );
    if (saved != null && mounted) context.pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final area = _area;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AppMap(
              latitude: _lat,
              longitude: _lng,
              controller: _map,
              onMoveStart: () => setState(() => _moving = true),
              onMoveEnd: _onMoveEnd,
            ),
          ),
          // The pin stays centered; it lifts while the map moves underneath.
          Center(
            child: IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 56),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSlide(
                      offset: _moving ? const Offset(0, -0.25) : Offset.zero,
                      duration: 180.ms,
                      curve: Curves.easeOut,
                      child: const SufraLogo(size: 56, color: AppColors.ember, cutColor: Colors.white),
                    ),
                    AnimatedContainer(
                      duration: 180.ms,
                      width: _moving ? 10 : 18,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l10n.back,
                    onPressed: () => context.pop(),
                    style: IconButton.styleFrom(
                      fixedSize: const Size(44, 44),
                      backgroundColor: context.colors.surface,
                      foregroundColor: context.colors.onSurface,
                    ),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(l10n.pickLocationTitle, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton.small(
                    heroTag: null,
                    tooltip: l10n.myLocation,
                    onPressed: _locating ? null : _locate,
                    backgroundColor: context.colors.surface,
                    foregroundColor: AppColors.ember,
                    child: _locating
                        ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2.5))
                        : const Icon(Icons.my_location_rounded),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 30, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              area == null ? Icons.wrong_location_rounded : Icons.location_on_rounded,
                              color: area == null ? context.colors.error : AppColors.ember,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: 200.ms,
                                child: Text(
                                  area?.name.resolve(context.locale) ?? l10n.outsideDeliveryArea,
                                  key: ValueKey(area),
                                  style: context.text.titleMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          area == null ? l10n.outsideDeliveryAreaBody : l10n.pickLocationHint,
                          style: context.text.bodyMedium?.copyWith(color: context.sufra.muted),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: area == null || _moving ? null : _confirm,
                            child: Text(l10n.confirmLocation),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

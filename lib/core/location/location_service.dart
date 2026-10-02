import 'package:geolocator/geolocator.dart';

sealed class LocationResult {
  const LocationResult();
}

class LocationFound extends LocationResult {
  const LocationFound(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

/// Location services are switched off on the device.
class LocationServiceOff extends LocationResult {
  const LocationServiceOff();
}

class LocationDenied extends LocationResult {
  const LocationDenied();
}

class LocationFailed extends LocationResult {
  const LocationFailed();
}

/// Asks for permission when needed and returns the device position, never throwing.
Future<LocationResult> currentLocation() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return const LocationServiceOff();
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return const LocationDenied();
    }
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 12)),
    );
    return LocationFound(p.latitude, p.longitude);
  } on Object {
    return const LocationFailed(); // Timeouts and platform errors: let the user move the map by hand.
  }
}

import 'dart:io';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

const double zoomLevel = 18;

const double boundryLngLength = 0.0015;
const double boundryLatLength = boundryLngLength / 1.5;

Future<bool> isLocationPermitted() async {
  if (Platform.isLinux) return false;

  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (serviceEnabled) return true;

  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse) return true;

  return await requestPermission();
}

Future<bool> requestPermission() async {
  await Geolocator.requestPermission();
  LocationPermission permission = await Geolocator.checkPermission();
  return permission != LocationPermission.denied &&
      permission != LocationPermission.deniedForever;
}

Future<LatLng> getPosition() async {
  var position = await Geolocator.getCurrentPosition();

  return LatLng(position.latitude, position.longitude);
}

class DebugPoints {
  // ignore: non_constant_identifier_names
  static LatLng get Sofia {
    return const LatLng(42.698334, 23.319941);
  }

  // ignore: non_constant_identifier_names
  static LatLng get Eindhoven {
    return const LatLng(51.4231, 5.4623);
  }
}

double getDistance(LatLng p1, LatLng p2) {
  return sqrt(
      pow(p1.latitude - p2.latitude, 2) + pow(p1.longitude - p2.longitude, 2));
}

bool shouldAdd(LatLng p, List<LatLng> newPoints, List<List<LatLng>> allPoints) {
  return newPoints.isEmpty || getDistance(p, newPoints.last) > 0.0001;
}

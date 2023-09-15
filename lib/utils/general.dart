import 'dart:math';

import 'package:latlong2/latlong.dart';

const double zoomLevel = 18;

const double pointsMinDistance = 0.0001; // ~ 11.1m
const double pointsMinDistanceExpanded = pointsMinDistance * 3;

const double boundryLngLength = 0.0015;
const double boundryLatLength = boundryLngLength / 1.5;

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

bool arePointsClose(
  LatLng p1,
  LatLng p2, {
  double distance = pointsMinDistance,
}) {
  var dist = sqrt(
      pow(p1.latitude - p2.latitude, 2) + pow(p1.longitude - p2.longitude, 2));

  return dist > distance;
}

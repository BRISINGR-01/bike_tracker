import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

Future<bool> isLocationPermitted() async {
  if (Platform.isLinux) return false;

  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      // return Future.error('Location permissions are denied');
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    // return Future.error(
    //     'Location permissions are permanently denied, we cannot request permissions.');
    return false;
  }

  return true;
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

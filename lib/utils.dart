import 'dart:convert';
import 'dart:io';

import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:geolocator/geolocator.dart';

Future<String> getMarkersFilePath() async {
  Directory directory = await getApplicationDocumentsDirectory();

  String filePath = path.join(directory.path, "marks.json");

  File file = File(filePath);
  if (!(await file.exists())) {
    file.createSync();
    file.writeAsStringSync("[]");
  }

  return filePath;
}

addMarker(LatLng marker) async {
  File file = File(await getMarkersFilePath());
  String rawJson = file.readAsStringSync();

  List coordinates = jsonDecode(rawJson);

  coordinates.add([marker.latitude, marker.longitude]);

  file.writeAsStringSync(jsonEncode(coordinates));
}

Future<List<LatLng>> getAllMarkers() async {
  String rawJson = File(await getMarkersFilePath()).readAsStringSync();

  List coordinates = jsonDecode(rawJson);

  return coordinates.map((coor) => LatLng(coor[0], coor[1])).toList();
}

Future<bool> isLocationPermitted() async {
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

// Future<String> getUserID() async {
//   // Obtain shared preferences.
//   final prefs = await SharedPreferences.getInstance();

// // Save an integer value to 'counter' key.
//   await prefs.setInt('counter', 10);
// // Save an boolean value to 'repeat' key.
// }

class Observable {}

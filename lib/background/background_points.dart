import 'package:bike_tracker/utils/sql_wrapper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class BackgroundPoints {
  SQLWrapper db;
  BackgroundPoints(this.db);
  List<LatLng> points = [];

  void add(Position event) {
    print("background");

    points.add(LatLng(event.latitude, event.longitude));
  }

  void clear() {}

  Future<void> save() {
    return db.insert(points);
  }
}

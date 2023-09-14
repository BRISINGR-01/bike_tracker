// import 'package:bike_tracker/utils/points_db.dart';
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart';

// class BackgroundPoints {
//   PointsDB db;
//   BackgroundPoints(this.db);
//   List<LatLng> points = [];

//   void add(Position event) {
//     http.readBytes(Uri.http(
//         "192.168.1.113:3000", "points-${event.latitude}, ${event.longitude}"));

//     db.addFromBackground(points);
//     points.add(LatLng(event.latitude, event.longitude));
//   }

//   void clear() {}

//   Future<void> save() {
//     return db.addFromBackground(points);
//   }
// }

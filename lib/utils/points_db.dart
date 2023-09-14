import 'package:bike_tracker/utils/custom_bounds.dart';
import 'package:bike_tracker/utils/sql_wrapper.dart';
import 'package:latlong2/latlong.dart';

class PointsDB {
  final SQLWrapper _db;
  PointsDB._(this._db);

  static Future<PointsDB> init() async {
    var db = await SQLWrapper.init();

    return PointsDB._(db);
  }

  Future<void> addFromMain(List<LatLng> points) async {
    return _db.insert(points);
  }

  Future<void> addFromBackground(List<LatLng> points) async {
    return _db.insert(points);
  }

  Future<List<List<LatLng>>> get(CustomBounds bounds) async {
    return _db.get(bounds);
  }

  Future<void> stop() {
    return _db.stop();
  }
}

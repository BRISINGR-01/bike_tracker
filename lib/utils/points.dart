import 'package:bike_tracker/utils/points_db.dart';
import 'package:bike_tracker/utils/general.dart';
import 'package:bike_tracker/utils/custom_bounds.dart';
import 'package:latlong2/latlong.dart';

// distance between visibleBounds and end of screen when bounds are updated
const double bufferExtend = 0.001;

class Points {
  List<List<LatLng>> allPoints = [[]];
  List<LatLng> newPoints = [];
  CustomBounds _bounds = CustomBounds.outsideOfMap;
  late PointsDB _db;

  Future<void> changeBoundries(LatLng center) async {
    await save();
    _bounds = CustomBounds.fromPoint(center);
    await populate();
  }

  Future<void> add(LatLng p) async {
    if (!_bounds.isWhithin(p)) await changeBoundries(p);

    if (shouldAdd(p)) {
      // newPoints.add(p);
    }
  }

  bool shouldAdd(LatLng p) {
    return newPoints.isEmpty || getDistance(p, newPoints.last) > 0.0001;
  }

  Future<void> setUp(PointsDB db, LatLng center) async {
    _db = db;
    _bounds = CustomBounds.fromPoint(center);
    await populate();
  }

  Future<void> populate() async {
    allPoints = await _db.get(_bounds);
  }

  Future<void> save() async {
    // await _db.add(newPoints);
    allPoints.add(newPoints);
    newPoints.clear();
  }
}

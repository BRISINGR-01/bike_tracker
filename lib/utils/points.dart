import 'package:bike_tracker/utils/points_db.dart';
import 'package:bike_tracker/utils/general.dart';
import 'package:bike_tracker/utils/custom_bounds.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

class Points {
  List<List<LatLng>> allPoints = [[]];
  List<LatLng> newPoints = [];
  CustomBounds bounds = CustomBounds.outsideOfMap;
  late PointsDB _db;

  void changeBoundries(LatLng center) async {
    await save();
    bounds.move(center);
    populate();
  }

  Future<void> add(LatLng p) async {
    if (!shouldAdd(p)) return;
    // print(p);
    newPoints.add(p);

    if (bounds.shouldExpand(p)) changeBoundries(p);
  }

  bool shouldAdd(LatLng p) {
    return newPoints.isEmpty || getDistance(p, newPoints.last) > 0.0001;
  }

  void setUp(
    PointsDB db,
    LatLng center,
    MapController mapController,
  ) {
    _db = db;
    bounds = CustomBounds.fromPoint(center);

    var screenMiddle = mapController.latLngToScreenPoint(center);
    var screen = screenMiddle.scaleBy(const CustomPoint(2, 2));

    var lowerRightCoord = mapController.latLngToScreenPoint(bounds.lowerRight);
    var upperLeftCoord = mapController.latLngToScreenPoint(bounds.upperLeft);

    int loopBuffer = 0;
    // north
    while (upperLeftCoord.y > 0 && loopBuffer++ < 10) {
      bounds.expand(LatLng(
        bounds.upperLeft.latitude + boundryBufferLat,
        center.longitude,
      ));
      upperLeftCoord = mapController.latLngToScreenPoint(bounds.upperLeft);
    }
    loopBuffer = 0;
    // south
    while (lowerRightCoord.y < screen.y && loopBuffer++ < 10) {
      bounds.expand(LatLng(
        bounds.lowerRight.latitude - boundryBufferLat,
        center.longitude,
      ));
      lowerRightCoord = mapController.latLngToScreenPoint(bounds.lowerRight);
    }
    loopBuffer = 0;
    // east
    while (lowerRightCoord.x < screen.x && loopBuffer++ < 10) {
      bounds.expand(LatLng(
        center.latitude,
        bounds.lowerRight.longitude + boundryBufferLng,
      ));
      lowerRightCoord = mapController.latLngToScreenPoint(bounds.lowerRight);
    }
    loopBuffer = 0;
    // west
    while (upperLeftCoord.x > 0 && loopBuffer++ < 10) {
      bounds.expand(LatLng(
        center.latitude,
        bounds.upperLeft.longitude - boundryBufferLng,
      ));
      upperLeftCoord = mapController.latLngToScreenPoint(bounds.upperLeft);
    }

    populate();
  }

  void populate() {
    _db.get(bounds).then((value) {
      allPoints = value;
    });
  }

  Future<void> save() async {
    // avoid adding the points twice
    var p = newPoints.toList();
    newPoints.clear();
    print(p.length);

    await _db.add(p);
  }
}

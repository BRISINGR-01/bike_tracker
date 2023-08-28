import 'dart:math';

import 'package:bike_tracker/utils/points_db.dart';
import 'package:bike_tracker/utils/general.dart';
import 'package:bike_tracker/utils/custom_bounds.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

class Points {
  List<List<LatLng>> allPoints = [];
  List<LatLng> newPoints = [];
  CustomBounds outerBounds = CustomBounds.outsideOfMap;
  CustomBounds innerBounds = CustomBounds.outsideOfMap;
  late PointsDB _db;

  Future<void> add(LatLng p) async {
    if (!shouldAdd(p)) return;
    // print(p);
    newPoints.add(p);
  }

  bool shouldAdd(LatLng p) {
    return newPoints.isEmpty || getDistance(p, newPoints.last) > 0.0001;
  }

  Future<void> setUp(
    PointsDB db,
    LatLng center,
    MapController mapController,
  ) {
    _db = db;

    return setBoundries(center, mapController);
  }

  Future<void> setBoundries(LatLng center, MapController mapController) {
    if (mapController.zoom < 5) {
      outerBounds = CustomBounds.wholeMap;
      innerBounds = CustomBounds.fromPoint(center);
      return populate();
    }

    outerBounds = CustomBounds.fromPoint(center);
    innerBounds = CustomBounds.fromPoint(center);

    var screenMiddle = mapController.latLngToScreenPoint(center);
    var screen = screenMiddle.scaleBy(const CustomPoint(2, 2));

    var lowerRightCoord =
        mapController.latLngToScreenPoint(outerBounds.lowerRight);
    var upperLeftCoord =
        mapController.latLngToScreenPoint(outerBounds.upperLeft);

    num coef = zoomLevel + 1 - mapController.zoom;

    if (coef > 1) coef = pow(coef, 3.5);

    double lengthLat = boundryLatLength * coef;
    double lengthLng = boundryLngLength * coef;

    int loopBuffer = 0;
    // north
    while (upperLeftCoord.y > 0 && loopBuffer++ < 10) {
      outerBounds.expandNorth(boundryLatLength: lengthLat);
      upperLeftCoord = mapController.latLngToScreenPoint(outerBounds.upperLeft);
    }
    loopBuffer = 0;

    // south
    while (lowerRightCoord.y < screen.y && loopBuffer++ < 10) {
      outerBounds.expandSouth(boundryLatLength: lengthLat);
      lowerRightCoord =
          mapController.latLngToScreenPoint(outerBounds.lowerRight);
    }
    loopBuffer = 0;

    // east
    while (lowerRightCoord.x < screen.x && loopBuffer++ < 10) {
      outerBounds.expandEast(boundryLngLength: lengthLng);
      lowerRightCoord =
          mapController.latLngToScreenPoint(outerBounds.lowerRight);
    }
    loopBuffer = 0;

    // west
    while (upperLeftCoord.x > 0 && loopBuffer++ < 10) {
      outerBounds.expandWest(boundryLngLength: lengthLng);
      upperLeftCoord = mapController.latLngToScreenPoint(outerBounds.upperLeft);
    }

    outerBounds.expandNorth(boundryLatLength: lengthLat);
    outerBounds.expandSouth(boundryLatLength: lengthLat);
    outerBounds.expandEast(boundryLngLength: lengthLng);
    outerBounds.expandWest(boundryLngLength: lengthLng);

    return populate();
  }

  void adjustBoundries(LatLng center) async {
    bool hasExpanded = false;

    if (innerBounds.shouldExpandNorth(center)) {
      hasExpanded = true;
      outerBounds.expandNorth(shouldMove: true);
      innerBounds.expandNorth(shouldMove: true);
    } else if (innerBounds.shouldExpandSouth(center)) {
      hasExpanded = true;
      outerBounds.expandSouth(shouldMove: true);
      innerBounds.expandSouth(shouldMove: true);
    } else if (innerBounds.shouldExpandWest(center)) {
      hasExpanded = true;
      outerBounds.expandWest(shouldMove: true);
      innerBounds.expandWest(shouldMove: true);
    } else if (innerBounds.shouldExpandEast(center)) {
      hasExpanded = true;
      outerBounds.expandEast(shouldMove: true);
      innerBounds.expandEast(shouldMove: true);
    }

    if (hasExpanded) {
      await save();
      populate().then((_) {
        if (allPoints.isEmpty) return;

        allPoints.last.add(center);
      });
    }
  }

  Future<void> populate() {
    return _db.get(outerBounds).then((value) {
      allPoints = value;
    });
  }

  Future<void> save() async {
    // avoid adding the points twice
    var p = newPoints.toList();
    newPoints.clear();

    await _db.add(p);
  }
}

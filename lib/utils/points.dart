import 'dart:math';

import 'package:bike_tracker/utils/points_db.dart';
import 'package:bike_tracker/utils/general.dart';
import 'package:bike_tracker/utils/custom_bounds.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

class Points {
  List<List<LatLng>> allPoints = [[]];
  LatLng prevPoint = CustomBounds.outsideOfMap.upperLeft;
  CustomBounds outerBounds = CustomBounds.outsideOfMap;
  CustomBounds innerBounds = CustomBounds.outsideOfMap;
  late PointsDB _db;

  Future<void> add(LatLng p) async {
    if (shouldAdd(p)) {
      allPoints.last.add(p);
      save(p);
    }
  }

  bool shouldAdd(LatLng p) {
    return allPoints.last.isEmpty || arePointsClose(p, allPoints.last.last);

    // direction is defined using current point and last two points

    // final last = newPoints.last;
    // final lastButOne = newPoints[newPoints.length - 2];

    // var lngDif1 = prevPoint.longitude - p.longitude;
    // if (lngDif1 == 0) lngDif1 = 0.0000000001;
    // var lngDif2 = lastButOne.longitude - last.longitude;
    // if (lngDif2 == 0) lngDif2 = 0.0000000001;

    // final latDif1 = last.latitude - p.latitude;
    // final latDif2 = lastButOne.latitude - last.latitude;

    // final direction1 = latDif1 / lngDif1;
    // final direction2 = latDif2 / lngDif2;

    // // print(latDif1 / latDif2);
    // // print(lngDif1 / lngDif2);

    // var distance = ((prevPoint.latitude - last.latitude).abs() +
    //         (prevPoint.longitude - last.longitude).abs()) *
    //     3000;

    // prevPoint = p;

    // return (direction1 - direction2).abs() > 1 - distance;
  }

  Future<void> setUp(
    PointsDB db,
    LatLng center,
    MapController mapController,
  ) {
    _db = db;
    prevPoint = center;

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

  Future<void> adjustBoundries(MapPosition mapPosition) async {
    if (mapPosition.center == null) return;

    final LatLng center = mapPosition.center!;

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

    if (hasExpanded && mapPosition.zoom == zoomLevel) {
      await populate();

      if (allPoints.isEmpty) return;

      // connect new points and old ones (they are different layers)
      allPoints.last.add(center);
    }
  }

  Future<void> populate() {
    return _db.get(outerBounds).then((value) {
      if (value.isEmpty) value.add([]);
      allPoints = value;
    });
  }

  Future<void> save(LatLng p) {
    return _db.add(p);
  }
}

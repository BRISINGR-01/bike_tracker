import 'package:bike_tracker/utils/general.dart';
import 'package:latlong2/latlong.dart';

class CustomBounds {
  LatLng upperLeft;
  LatLng lowerRight;

  CustomBounds(this.upperLeft, this.lowerRight);

  static get outsideOfMap {
    return CustomBounds(const LatLng(90, 180), const LatLng(90, 180));
  }

  bool shouldExpandNorth(LatLng p) =>
      upperLeft.latitude - boundryBufferLat < p.latitude;
  bool shouldExpandSouth(LatLng p) =>
      lowerRight.latitude + boundryBufferLat > p.latitude;
  bool shouldExpandEast(LatLng p) =>
      lowerRight.longitude - boundryBufferLng < p.longitude;
  bool shouldExpandWest(LatLng p) =>
      upperLeft.longitude + boundryBufferLng > p.longitude;

  shouldExpand(LatLng p) {
    return shouldExpandNorth(p) ||
        shouldExpandWest(p) ||
        shouldExpandEast(p) ||
        shouldExpandSouth(p);
  }

  expand(LatLng p) {
    if (shouldExpandNorth(p)) {
      upperLeft =
          LatLng(upperLeft.latitude + boundryLatLength, upperLeft.longitude);
    } else if (shouldExpandSouth(p)) {
      lowerRight =
          LatLng(lowerRight.latitude - boundryLatLength, lowerRight.longitude);
    } else if (shouldExpandEast(p)) {
      lowerRight =
          LatLng(lowerRight.latitude, lowerRight.longitude + boundryLngLength);
    } else if (shouldExpandWest(p)) {
      upperLeft =
          LatLng(upperLeft.latitude, upperLeft.longitude - boundryLngLength);
    }
  }

  move(LatLng p) {
    if (shouldExpandNorth(p)) {
      upperLeft =
          LatLng(upperLeft.latitude + boundryLatLength, upperLeft.longitude);
      lowerRight =
          LatLng(lowerRight.latitude + boundryLatLength, lowerRight.longitude);
    } else if (shouldExpandSouth(p)) {
      upperLeft =
          LatLng(upperLeft.latitude - boundryLatLength, upperLeft.longitude);
      lowerRight =
          LatLng(lowerRight.latitude - boundryLatLength, lowerRight.longitude);
    } else if (shouldExpandEast(p)) {
      upperLeft =
          LatLng(upperLeft.latitude, upperLeft.longitude + boundryLngLength);
      lowerRight =
          LatLng(lowerRight.latitude, lowerRight.longitude + boundryLngLength);
    } else if (shouldExpandWest(p)) {
      upperLeft =
          LatLng(upperLeft.latitude, upperLeft.longitude - boundryLngLength);
      lowerRight =
          LatLng(lowerRight.latitude, lowerRight.longitude - boundryLngLength);
    }
  }

  static fromPoint(LatLng p) {
    LatLng upperLeft = LatLng(
      (p.latitude - p.latitude % boundryLatLength) + boundryLatLength,
      (p.longitude - p.longitude % boundryLngLength),
    );
    LatLng lowerRight = LatLng(
      (p.latitude - p.latitude % boundryLatLength),
      (p.longitude - p.longitude % boundryLngLength) + boundryLngLength,
    );

    return CustomBounds(upperLeft, lowerRight);
  }
}

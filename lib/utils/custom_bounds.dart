import 'package:bike_tracker/utils/general.dart';
import 'package:latlong2/latlong.dart';

class CustomBounds {
  LatLng upperLeft;
  LatLng lowerRight;

  CustomBounds(this.upperLeft, this.lowerRight);

  static CustomBounds get outsideOfMap {
    return CustomBounds(const LatLng(90, 180), const LatLng(90, 180));
  }

  static CustomBounds get wholeMap {
    return CustomBounds(const LatLng(90, -180), const LatLng(-90, 180));
  }

  bool shouldExpandNorth(LatLng p) => upperLeft.latitude < p.latitude;

  void expandNorth({
    shouldMove = false,
    double boundryLatLength = boundryLatLength,
  }) {
    upperLeft =
        LatLng(upperLeft.latitude + boundryLatLength, upperLeft.longitude);

    if (shouldMove) {
      lowerRight =
          LatLng(lowerRight.latitude + boundryLatLength, lowerRight.longitude);
    }
  }

  bool shouldExpandSouth(LatLng p) => lowerRight.latitude > p.latitude;

  void expandSouth({
    shouldMove = false,
    double boundryLatLength = boundryLatLength,
  }) {
    lowerRight =
        LatLng(lowerRight.latitude - boundryLatLength, lowerRight.longitude);

    if (shouldMove) {
      upperLeft =
          LatLng(upperLeft.latitude - boundryLatLength, upperLeft.longitude);
    }
  }

  bool shouldExpandEast(LatLng p) => lowerRight.longitude < p.longitude;
  void expandEast({
    shouldMove = false,
    double boundryLngLength = boundryLngLength,
  }) {
    lowerRight =
        LatLng(lowerRight.latitude, lowerRight.longitude + boundryLngLength);
    if (shouldMove) {
      upperLeft =
          LatLng(upperLeft.latitude, upperLeft.longitude + boundryLngLength);
    }
  }

  bool shouldExpandWest(LatLng p) => upperLeft.longitude > p.longitude;

  void expandWest({
    shouldMove = false,
    double boundryLngLength = boundryLngLength,
  }) {
    upperLeft =
        LatLng(upperLeft.latitude, upperLeft.longitude - boundryLngLength);

    if (shouldMove) {
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

import 'package:bike_tracker/utils/general.dart';
import 'package:latlong2/latlong.dart';

class CustomBounds {
  LatLng upperLeft;
  LatLng lowerRight;

  CustomBounds(this.upperLeft, this.lowerRight);

  static get outsideOfMap {
    return CustomBounds(const LatLng(90, 180), const LatLng(90, 180));
  }

  isWhithin(LatLng p) {
    return upperLeft.latitude < p.latitude &&
        upperLeft.longitude < p.longitude &&
        lowerRight.latitude > p.latitude &&
        lowerRight.longitude > p.longitude;
  }

  static fromPoint(LatLng p) {
    return CustomBounds(
      LatLng((p.latitude - p.latitude % boundryLatLength),
          (p.longitude - p.longitude % boundryLongLength)),
      LatLng((p.latitude - p.latitude % boundryLatLength) + boundryLatLength,
          (p.longitude - p.longitude % boundryLongLength) + boundryLongLength),
    );
  }
}

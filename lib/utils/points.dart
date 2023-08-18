import 'package:bike_tracker/utils/points_db.dart';
import 'package:bike_tracker/utils/general.dart';
import 'package:latlong2/latlong.dart';

// distance between visibleBounds and end of screen when bounds are updated
const double bufferExtend = 0.001;

class Points {
  List<LatLng> _allPoints = [];
  List<LatLng> _newPoints = [];
  Bounds _bounds = Bounds.outsideOfMap;
  // final PointsDB _db;
  Bounds? _visibleBounds;

  // Points( this._db, this._visibleBounds);

  List<LatLng> get list => _allPoints;

  void _adjust(LatLng center) async {
    await save();
  }

  void add(LatLng p) {
    _adjust(p);
    if (_allPoints.isEmpty || getDistance(p, _allPoints.last) > 0.0001) {
      _allPoints.add(p);
      _newPoints.add(p);
    }
  }

  Future<void> save() async {
    // await _db.add(_bounds, _newPoints);
  }
}

class Bounds {
  LatLng upperLeft;
  LatLng lowerRight;

  Bounds(this.upperLeft, this.lowerRight);

  static get outsideOfMap {
    return Bounds(const LatLng(90, 180), const LatLng(90, 180));
  }

  isWhithin(LatLng p) {
    return upperLeft.latitude < p.latitude &&
        upperLeft.longitude < p.longitude &&
        lowerRight.latitude > p.latitude &&
        lowerRight.longitude > p.longitude;
  }
}

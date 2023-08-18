import 'package:bike_tracker/utils/points.dart';
import 'package:latlong2/latlong.dart';

class PointsDB {
  Bounds currentBounds;

  PointsDB(this.currentBounds);

  void initialize() async {}
  Future<void> add(List<LatLng> points) async {}
  Future<void> get(Bounds newBounds) async {
    // ...
    currentBounds = newBounds;
  }
}

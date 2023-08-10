import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationDot {
  late Marker marker;
  late LatLng position;
  LocationDot(Position currentPosition) {
    position = LatLng(currentPosition.latitude, currentPosition.longitude);
    marker = Marker(
      width: 30,
      height: 30,
      point: position,
      builder: (ctx) => SizedBox(
        child: Container(
          color: Colors.blue,
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blue,
            ),
            shape: BoxShape.circle,
          ),
          // child: ...,
        ),
      ),
    );
  }
}

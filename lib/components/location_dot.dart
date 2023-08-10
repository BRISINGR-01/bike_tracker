import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationDot extends Marker {
  final LatLng position;
  LocationDot(this.position)
      : super(
          width: 30,
          height: 30,
          point: position,
          builder: (ctx) => SizedBox(
            child: Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: Colors.blue,
                border: Border.all(
                  color: Colors.blue,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );

  static Future<LocationDot> init() async {
    var position = await Geolocator.getCurrentPosition();

    var coordinates = LatLng(position.latitude, position.longitude);

    return LocationDot(coordinates);
  }

  static LocationDot get debug {
    return LocationDot(const LatLng(0, 0));
  }
}

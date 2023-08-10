import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationDot extends Marker {
  final LatLng position;
  LocationDot(this.position)
      : super(
          width: 15,
          height: 15,
          point: position,
          builder: (ctx) => SizedBox(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
}

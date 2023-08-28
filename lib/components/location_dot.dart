import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationDot extends Marker {
  final LatLng position;
  final double zoom;
  LocationDot(this.position, this.zoom)
      : super(
          width: zoom - 3,
          height: zoom - 3,
          point: position,
          builder: (ctx) => SizedBox(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.greenAccent,
                border: Border.fromBorderSide(BorderSide(color: Colors.green)),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationDot extends Marker {
  final LatLng position;
  final double zoom;
  final Color color;
  final Color colorInner;

  LocationDot(this.position, this.zoom, this.color, this.colorInner)
      : super(
          width: zoom - 3,
          height: zoom - 3,
          point: position,
          builder: (_) => SizedBox(
            child: Container(
              decoration: BoxDecoration(
                color: colorInner,
                border: Border.fromBorderSide(BorderSide(color: color)),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
}

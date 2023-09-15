import 'package:bike_tracker/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationDot extends Marker {
  final LatLng position;
  final double zoom;

  LocationDot(this.position, this.zoom)
      : super(
          width: zoom - 1,
          height: zoom - 1,
          point: position,
          builder: (_) => SizedBox(
            child: Container(
              decoration: BoxDecoration(
                color: CustomColorsScheme.trail,
                border: const Border.fromBorderSide(
                    BorderSide(width: 3, color: CustomColorsScheme.secondary)),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
}

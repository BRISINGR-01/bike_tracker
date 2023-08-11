import 'dart:io';
import 'dart:typed_data';

import 'package:bike_tracker/map_providers/drawable_image.dart';
import 'package:flutter/src/painting/image_provider.dart';
import 'package:flutter_map/flutter_map.dart';

class DrawableTileProvider extends TileProvider {
  final Uint8List placeholder;
  DrawableTileProvider({required this.placeholder}) : super(headers: const {});

  @override
  ImageProvider<Object> getImage(
    TileCoordinates coordinates,
    TileLayer options,
  ) {
    final file = File(getTileUrl(coordinates, options));

    return DrawableImageProvider(file, placeholder);
  }
}

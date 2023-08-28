import 'dart:io';
import 'dart:typed_data';

import 'package:bike_tracker/map_providers/downloadable_image_provider.dart';
import 'package:flutter/services.dart';
// ignore: implementation_imports
import 'package:flutter/src/painting/image_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';

class NetworkAndFileTileProvider extends TileProvider {
  final Uint8List placeholder;

  NetworkAndFileTileProvider({
    super.headers = const {},
    required this.placeholder,
    BaseClient? httpClient,
  }) : httpClient = httpClient ?? RetryClient(Client());

  final BaseClient httpClient;

  @override
  ImageProvider<Object> getImage(
    TileCoordinates coordinates,
    TileLayer options,
  ) {
    final file = File(getTileUrl(coordinates, options));
    final fallbackUrl = getTileFallbackUrl(coordinates, options);

    if (file.existsSync()) return FileImage(file);

    return DownloadableImageProvider(
      url: fallbackUrl!,
      headers: headers,
      destination: file,
      placeholder: placeholder,
      httpClient: httpClient,
    );
  }
}

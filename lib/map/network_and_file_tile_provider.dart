import 'dart:io';
import 'dart:typed_data';

import 'package:bike_tracker/map/downloadable_image_provider.dart';
import 'package:flutter/services.dart';
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

    if (file.existsSync()) return FileImage(file);

    return DownloadableImageProvider(
      url: getTileFallbackUrl(coordinates, options)!,
      headers: headers,
      destination: file,
      placeholder: placeholder,
      httpClient: httpClient,
    );
  }
}

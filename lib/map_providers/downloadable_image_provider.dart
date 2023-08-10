import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart';

/// Dedicated [ImageProvider] to fetch tiles from the network
class DownloadableImageProvider
    extends ImageProvider<DownloadableImageProvider> {
  /// The URL to fetch the tile from (GET request)
  final String url;

  /// The file where to save the image
  final File destination;

  /// In case an image cannot be fetched or saved, this is a fallback placeholder image
  final Uint8List placeholder;

  /// The HTTP client to use to make network requests
  final BaseClient httpClient;

  /// The headers to include with the tile fetch request
  final Map<String, String> headers;

  /// Dedicated [ImageProvider] to fetch tiles from the network
  DownloadableImageProvider(
      {required this.url,
      required this.destination,
      required this.headers,
      required this.httpClient,
      required this.placeholder});

  @override
  ImageStreamCompleter loadImage(
    DownloadableImageProvider key,
    ImageDecoderCallback decode,
  ) {
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: 1,
      debugLabel: url,
      informationCollector: () => [
        DiagnosticsProperty('URL', url),
        DiagnosticsProperty('Current provider', key),
      ],
    );
  }

  @override
  Future<DownloadableImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) =>
      SynchronousFuture<DownloadableImageProvider>(this);

  Future<Codec> _loadAsync(
    DownloadableImageProvider key,
    StreamController<ImageChunkEvent> chunkEvents,
    ImageDecoderCallback decode,
  ) async {
    Uint8List bytes;
    try {
      bytes = await httpClient.readBytes(
        Uri.parse(url),
        headers: headers,
      );
    } catch (_) {
      bytes = placeholder;
    }

    destination
        .create(recursive: true)
        .then((value) => value.writeAsBytesSync(bytes, flush: true));

    return decode(await ImmutableBuffer.fromUint8List(bytes));
  }
}

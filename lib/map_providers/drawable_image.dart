import 'dart:async';
import 'dart:ui';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class DrawableImageProvider extends ImageProvider<DrawableImageProvider> {
  final File destination;
  final Uint8List placeholder;

  DrawableImageProvider(this.destination, this.placeholder);

  @override
  ImageStreamCompleter loadImage(
    DrawableImageProvider key,
    ImageDecoderCallback decode,
  ) {
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      informationCollector: () => [],
      scale: 1,
    );
  }

  @override
  Future<DrawableImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) =>
      SynchronousFuture<DrawableImageProvider>(this);

  Future<Codec> _loadAsync(
    DrawableImageProvider key,
    StreamController<ImageChunkEvent> chunkEvents,
    ImageDecoderCallback decode,
  ) async {
    var loopBuffer = 0;
    while (!destination.existsSync() && loopBuffer < 10) {
      loopBuffer++;
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!destination.existsSync()) {
      return decode(await ImmutableBuffer.fromUint8List(placeholder));
    }

    return decode(
        await ImmutableBuffer.fromUint8List(destination.readAsBytesSync()));
  }
}

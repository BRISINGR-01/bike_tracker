import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class TileFilesDetails {
  late String tilesLocalDirectory;
  late Uint8List tilePlaceholder;
  bool hasLoaded = false;

  TileFilesDetails();

  Future<void> fetch() async {
    tilesLocalDirectory = (await getApplicationDocumentsDirectory()).path;
    tilePlaceholder =
        (await rootBundle.load("assets/placeholder.png")).buffer.asUint8List();
    hasLoaded = true;
  }

  clearCache() {
    if (!hasLoaded) return;

    var dir = Directory(join(tilesLocalDirectory, "map"));

    if (dir.existsSync()) dir.delete();
  }

  String get tileFileUrl => join(
        tilesLocalDirectory,
        "maps",
        "{z}",
        "{x}",
        "{y}.png",
      );
}

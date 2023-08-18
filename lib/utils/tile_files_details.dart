import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class TileFilesDetails {
  final String tilesLocalDirectory;
  final Uint8List tilePlaceholder;

  const TileFilesDetails(this.tilesLocalDirectory, this.tilePlaceholder);
  static fetch() async {
    return TileFilesDetails(
      (await getApplicationDocumentsDirectory()).path,
      (await rootBundle.load("assets/placeholder.png")).buffer.asUint8List(),
    );
  }
}

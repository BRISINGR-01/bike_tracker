import 'package:bike_tracker/utils/custom_bounds.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as path;

const String tableName = "points";
const String latColumn = "lat";
const String longColumn = "long";

class SQLWrapper {
  final Database _dbInstance;
  SQLWrapper._(this._dbInstance);

  static Future<SQLWrapper> init() async {
    sqfliteFfiInit();

    var dbDirectory = await getApplicationDocumentsDirectory();
    var instance = await databaseFactoryFfi
        .openDatabase(path.join(dbDirectory.path, 'points-database.sql'));

    // instance.execute('''
    //   DROP TABLE IF EXISTS '$tableName'
    // ''');
    instance.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $latColumn float(3, 6) NOT NULL,
        $longColumn float(3, 6) NOT NULL
      );
    ''');

    return SQLWrapper._(instance);
  }

  Future execute(String sqlQuery) => _dbInstance.execute(sqlQuery);

  Future<List<List<LatLng>>> get(CustomBounds bounds) async {
    List<Map<String, Object?>> result =
        await _dbInstance.query(tableName, columns: [
      latColumn,
      longColumn,
      "rowid"
    ], where: """
            ? > $latColumn AND
            ? < $longColumn AND
            ? < $latColumn AND
            ? > $longColumn
            """, whereArgs: [
      bounds.upperLeft.latitude,
      bounds.upperLeft.longitude,
      bounds.lowerRight.latitude,
      bounds.lowerRight.longitude,
    ]);

    List<List<LatLng>> coordinates = [];
    int lastId = -1;
    for (var row in result) {
      int id = row["rowid"] as int;
      if (id - lastId != 1) {
        coordinates.add([]);
      }

      coordinates.last
          .add(LatLng(row[latColumn] as double, row[longColumn] as double));
      lastId = id;
    }

    return coordinates;
  }

  Future<void> insert(List<LatLng> coords) async {
    for (var coord in coords) {
      await _dbInstance.insert(tableName, {
        latColumn: coord.latitude.toStringAsFixed(5),
        longColumn: coord.longitude.toStringAsFixed(5),
      });
    }
  }

  Future<void> stop() {
    return _dbInstance.close();
  }
}

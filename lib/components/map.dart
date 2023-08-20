import 'dart:io';
import 'package:bike_tracker/components/loader.dart';
import 'package:bike_tracker/components/location_dot.dart';
import 'package:bike_tracker/map_providers/network_and_file_tile_provider.dart';
import 'package:bike_tracker/utils/custom_bounds.dart';
import 'package:bike_tracker/utils/points_db.dart';
import 'package:bike_tracker/utils/general.dart';
import 'package:bike_tracker/utils/points.dart';
import 'package:bike_tracker/utils/tile_files_details.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' show join;

class Map extends StatefulWidget {
  const Map({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MapState();
}

class MapState extends State<Map> {
  final mapController = MapController();
  LatLng? position;
  bool shouldRequestPermissions = false;
  bool hasStarted = false;
  Points points = Points();
  Function(MapPosition, bool)? onUserMoveMap;

  Future<void> prepare() async {
    if (kDebugMode && (Platform.isLinux || Platform.isMacOS)) {
      setState(() {
        position = DebugPoints.Eindhoven;
      });

      await points.setUp(await PointsDB.init(), DebugPoints.Eindhoven);
      onUserMoveMap = mapMoveDebug;
      mapController.move(DebugPoints.Eindhoven, mapController.zoom);
    } else if (await isLocationPermitted()) {
      var currentPosition = await getPosition();
      if (mounted) {
        setState(() {
          position = currentPosition;
        });
      }

      await points.setUp(await PointsDB.init(), currentPosition);
      mapController.move(currentPosition, mapController.zoom);
      Geolocator.getPositionStream()
          .listen((event) => onMove(LatLng(event.latitude, event.longitude)));
    } else {
      setState(() {
        shouldRequestPermissions = true;
      });
    }
  }

  void mapMoveDebug(MapPosition position, bool hasGesture) {
    if (kDebugMode &&
        position.center != null &&
        (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      onMove(position.center!);
    }
  }

  void onMove(LatLng newPosition) {
    if (!hasStarted) return;

    setState(() {
      position = newPosition;
      points.add(newPosition);
    });

    moveToPosition(newPosition);
  }

  void toggleStart() async {
    if (position == null) {
      await prepare();
    }

    if (!shouldRequestPermissions) {
      if (position != null) {
        moveToPosition(position!);
        points.save();
      }

      setState(() {
        hasStarted = !hasStarted;
      });
    }
  }

  moveToPosition(LatLng newPosition) {
    mapController.move(newPosition, zoomLevel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: Text(
          hasStarted ? "Stop" : "Start",
          style: TextStyle(
              color: hasStarted ? Colors.white : Colors.black, fontSize: 16),
        ),
        extendedPadding: const EdgeInsets.all(24),
        extendedIconLabelSpacing: 12,
        elevation: 24,
        shape: const StadiumBorder(side: BorderSide()),
        onPressed: toggleStart,
        backgroundColor:
            hasStarted ? Colors.red : Colors.lightBlueAccent.shade200,
        icon: Icon(
          Icons.flag,
          color: hasStarted ? Colors.white : Colors.black,
          size: 30,
        ),
      ),
      body: FutureBuilder(
          future: TileFilesDetails.fetch(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Loader();
            var details = snapshot.data as TileFilesDetails;
            String tileFileUrl = join(
                details.tilesLocalDirectory, "maps", "{z}", "{x}", "{y}.png");

            return FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: position,
                zoom: zoomLevel,
                minZoom: hasStarted ? zoomLevel : 3,
                maxZoom: hasStarted ? zoomLevel : 18,
                maxBounds: LatLngBounds(
                  const LatLng(-90, -180.0),
                  const LatLng(90.0, 180.0),
                ),
                onMapReady: prepare,
                onPositionChanged: onUserMoveMap,
              ),
              nonRotatedChildren: [
                if (position != null)
                  MarkerLayer(markers: [LocationDot(position!)]),
                if (shouldRequestPermissions)
                  AlertDialog(
                    shape: const RoundedRectangleBorder(
                        side: BorderSide(),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    title: const Text("Location Permissions are required"),
                    content: const Text("Allow Location?"),
                    elevation: 24,
                    actions: [
                      TextButton(
                        onPressed: () async {
                          if (await requestPermission()) prepare();
                        },
                        child: const Text("Allow"),
                      ),
                      TextButton(
                        onPressed: () =>
                            setState(() => shouldRequestPermissions = false),
                        child: const Text("Cancel"),
                      )
                    ],
                  ),
              ],
              children: [
                TileLayer(
                  urlTemplate: tileFileUrl,
                  fallbackUrl: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  tileProvider: NetworkAndFileTileProvider(
                    placeholder: details.tilePlaceholder,
                  ),
                ),
                ...points.allPoints.map(
                  (pointsList) => PolylineLayer(
                    polylines: [
                      Polyline(
                        points: pointsList,
                        color: Colors.blue,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                ),
                if (position != null)
                  PolygonLayer(
                    polygons: [
                      Polygon(points: [
                        LatLng(
                            (position!.latitude -
                                    position!.latitude % boundryLatLength) +
                                boundryLatLength,
                            (position!.longitude -
                                    position!.longitude % boundryLongLength) +
                                boundryLongLength),
                        LatLng(
                            (position!.latitude -
                                    position!.latitude % boundryLatLength) +
                                boundryLatLength,
                            (position!.longitude -
                                position!.longitude % boundryLongLength)),
                        LatLng(
                            (position!.latitude -
                                position!.latitude % boundryLatLength),
                            (position!.longitude -
                                position!.longitude % boundryLongLength)),
                        LatLng(
                            (position!.latitude -
                                position!.latitude % boundryLatLength),
                            (position!.longitude -
                                    position!.longitude % boundryLongLength) +
                                boundryLongLength),
                      ], borderColor: Colors.black, borderStrokeWidth: 2),
                    ],
                  ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: points.newPoints,
                      color: Colors.blue,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              ],
            );
          }),
    );
  }
}

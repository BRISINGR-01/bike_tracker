import 'dart:io';
import 'package:bike_tracker/components/loader.dart';
import 'package:bike_tracker/components/location_dot.dart';
import 'package:bike_tracker/map_providers/drawable_tile_provider.dart';
import 'package:bike_tracker/map_providers/network_and_file_tile_provider.dart';
import 'package:bike_tracker/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
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

  Future getTileFilesDetails() async {
    return {
      "tilesLocalDirectory": (await getApplicationDocumentsDirectory()).path,
      "tilePlaceholder": (await rootBundle.load("assets/placeholder.png"))
          .buffer
          .asUint8List(),
    };
  }

  Future<void> initializeLocation() async {
    if (kDebugMode && (Platform.isLinux || Platform.isMacOS)) {
      setState(() {
        position = DebugPoints.Eindhoven;
      });
      mapController.move(DebugPoints.Eindhoven, mapController.zoom);
    } else if (await isLocationPermitted()) {
      var currentPosition = await getPosition();
      if (mounted) {
        setState(() {
          position = currentPosition;
        });
      }
      mapController.move(currentPosition, mapController.zoom);
      Geolocator.getPositionStream()
          .listen((event) => onMove(LatLng(event.latitude, event.longitude)));
    } else {
      setState(() {
        shouldRequestPermissions = true;
      });
    }
  }

  void onUserMoveMap(MapPosition position, bool hasGesture) {
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
    });
    moveToPosition(newPosition);
    paint(newPosition);
  }

  void paint(LatLng newPosition) {
    print(newPosition);
    var p = const Epsg3857().latLngToPoint(newPosition, mapController.zoom);
    print("${p.x}/${p.y}");
  }

  void toggleStart() async {
    if (position == null) {
      await initializeLocation();
    }

    if (!shouldRequestPermissions) {
      if (!hasStarted && position != null) moveToPosition(position!);

      setState(() {
        hasStarted = !hasStarted;
      });
    }
  }

  moveToPosition(LatLng newPosition) {
    //? add animation
    //? https://github.com/fleaflet/flutter_map/blob/master/example/lib/pages/animated_map_controller.dart

    mapController.move(newPosition, zoomLevel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: Text(
          hasStarted ? "Cancel" : "Start",
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
          future: getTileFilesDetails(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Loader();
            String tileFileUrl = join(
                snapshot.data["tilesLocalDirectory"] as String,
                "maps",
                "{z}",
                "{x}",
                "{y}.png");
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
                onMapReady: initializeLocation,
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
                        onPressed: initializeLocation,
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
                    placeholder: snapshot.data["tilePlaceholder"] as Uint8List,
                  ),
                  tileBuilder: (context, tileWidget, tile) => Stack(children: [
                    Container(
                      decoration: BoxDecoration(border: Border.all()),
                      child: tileWidget,
                    ),
                    Container(
                        color: Colors.grey, child: Text(tile.coordinatesKey))
                  ]),
                ),
                // TileLayer(
                //   urlTemplate: tileFileUrl,
                //   tileProvider: DrawableTileProvider(
                //     placeholder: snapshot.data["tilePlaceholder"] as Uint8List,
                //   ),
                //   tileBuilder: (context, tileWidget, tile) => Stack(children: [
                //     Container(
                //       decoration: BoxDecoration(border: Border.all()),
                //       child: tileWidget,
                //     ),
                //     Container(
                //         color: Colors.red, child: Text("tile.coordinatesKey"))
                //   ]),
                // ),
              ],
            );
          }),
    );
  }
}

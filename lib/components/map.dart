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
  bool isDebug = kDebugMode &&
      (Platform.isLinux || Platform.isWindows || Platform.isMacOS);
  TileFilesDetails tileFilesDetails = TileFilesDetails();
  var scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> prepare() async {
    LatLng? newPosition;

    if (isDebug) {
      newPosition = DebugPoints.Eindhoven;
    } else if (await isLocationPermitted()) {
      newPosition = await getPosition();

      Geolocator.getPositionStream().listen(
          (event) => moveToPosition(LatLng(event.latitude, event.longitude)));
    } else {
      setState(() {
        shouldRequestPermissions = true;
      });
    }

    if (newPosition != null) {
      moveToPosition(newPosition);
      points
          .setUp(await PointsDB.init(), newPosition, mapController)
          .then((_) => setState(() {}));

      setState(() {
        position = newPosition;
      });
    }
  }

  void onMapMove(MapPosition mapPosition, bool hasGesture) {
    if (mapPosition.center == null ||
        position == null ||
        mapPosition.zoom != zoomLevel) return;

    setState(() {
      points.adjustBoundries(mapPosition.center!);

      if (hasStarted) {
        position = mapPosition.center!;
        points.add(position!);
      }
    });
  }

  void toggleStart() async {
    if (position == null) await prepare();

    if (!shouldRequestPermissions) {
      if (position != null) {
        moveToPosition(position!);
        await points.save();

        if (!hasStarted) {
          points.adjustBoundries(position!);
        }
      }

      setState(() {
        hasStarted = !hasStarted;
      });
    }
  }

  moveToPosition(LatLng newPosition) {
    mapController.move(newPosition, zoomLevel);
  }

  onMapEvent(MapEvent p0) {
    if (p0.zoom != zoomLevel && p0.source == MapEventSource.scrollWheel) {
      setState(() {
        points.setBoundries(position!, mapController);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    tileFilesDetails.fetch().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          drawer: Drawer(
            key: scaffoldKey,
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Clear cache'),
                  onTap: tileFilesDetails.clearCache,
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            label: Text(
              hasStarted ? "Stop" : "Start",
              style: TextStyle(
                  color: hasStarted ? Colors.white : Colors.black,
                  fontSize: 16),
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
          body: Stack(
            children: [
              Center(
                child: !tileFilesDetails.hasLoaded
                    ? const Loader()
                    : FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          center: position,
                          zoom: zoomLevel,
                          minZoom: hasStarted ? zoomLevel : 3,
                          maxZoom: hasStarted ? zoomLevel : 18,
                          maxBounds: LatLngBounds(
                            CustomBounds.wholeMap.upperLeft,
                            CustomBounds.wholeMap.lowerRight,
                          ),
                          onMapReady: prepare,
                          onPositionChanged: onMapMove,
                          onMapEvent: onMapEvent,
                        ),
                        nonRotatedChildren: [
                          if (position != null)
                            MarkerLayer(markers: [
                              LocationDot(position!, mapController.zoom)
                            ]),
                          if (shouldRequestPermissions)
                            AlertDialog(
                              shape: const RoundedRectangleBorder(
                                  side: BorderSide(),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              title: const Text(
                                  "Location Permissions are required"),
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
                                  onPressed: () {
                                    setState(
                                        () => shouldRequestPermissions = false);
                                  },
                                  child: const Text("Cancel"),
                                )
                              ],
                            ),
                        ],
                        children: [
                          TileLayer(
                            urlTemplate: tileFilesDetails.tileFileUrl,
                            fallbackUrl:
                                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            tileProvider: NetworkAndFileTileProvider(
                              placeholder: tileFilesDetails.tilePlaceholder,
                            ),
                          ),
                          if (position != null)
                            PolygonLayer(
                              polygons: [
                                Polygon(
                                  points: [
                                    points.innerBounds.upperLeft,
                                    LatLng(
                                        points.innerBounds.upperLeft.latitude,
                                        points
                                            .innerBounds.lowerRight.longitude),
                                    points.innerBounds.lowerRight,
                                    LatLng(
                                        points.innerBounds.lowerRight.latitude,
                                        points.innerBounds.upperLeft.longitude),
                                  ],
                                  borderColor: Colors.blueGrey,
                                  borderStrokeWidth: 2,
                                ),
                              ],
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
                      ),
              ),
              Positioned(
                left: 10,
                top: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.blueAccent.shade100,
                  radius: 25,
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => scaffoldKey.currentState?.openDrawer(),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

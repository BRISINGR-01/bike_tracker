import 'dart:async';
import 'dart:io';
import 'package:bike_tracker/components/loader.dart';
import 'package:bike_tracker/components/location_dot.dart';
import 'package:bike_tracker/map_providers/network_and_file_tile_provider.dart';
import 'package:bike_tracker/utils/custom_bounds.dart';
import 'package:bike_tracker/utils/points_db.dart';
import 'package:bike_tracker/utils/general.dart';
import 'package:bike_tracker/utils/points.dart';
import 'package:bike_tracker/utils/sql_wrapper.dart';
import 'package:bike_tracker/utils/tile_files_details.dart';
import 'package:bike_tracker/utils/user_settings.dart';
import 'package:bike_tracker/background/work_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class Map extends StatefulWidget {
  const Map({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MapState();
}

class MapState extends State<Map> with WidgetsBindingObserver {
  final primary = Colors.lightBlue;
  final secondary = Colors.blue;
  final mapController = MapController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final bool isDebug = kDebugMode &&
      (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

  bool hasStarted = false;
  bool userHasMoved = false;
  bool shouldRequestPermissions = false;

  LatLng? position;
  String? colorToPick;
  StreamSubscription? st;
  final Points points = Points();
  final TileFilesDetails tileFilesDetails = TileFilesDetails();
  final UserSettings userSettings = UserSettings();

  Future<void> prepare() async {
    LatLng? newPosition;

    if (isDebug) {
      newPosition = DebugPoints.Eindhoven;
    } else if (await isLocationPermitted()) {
      newPosition = await getPosition();

      st = Geolocator.getPositionStream().listen((event) {
        var newCurrentPosition = LatLng(event.latitude, event.longitude);

        print("foreground");

        setState(() {
          position = newCurrentPosition;
        });
        moveToPosition(newCurrentPosition);
      });
    } else {
      setState(() {
        shouldRequestPermissions = true;
      });
    }

    if (newPosition != null) {
      moveToPosition(newPosition);
      // first move then set up the points!
      points
          .setUp(await PointsDB.init(), newPosition, mapController)
          .then((_) => setState(() {}));

      setState(() {
        shouldRequestPermissions = false;
        position = newPosition;
      });
    }
  }

  void onMapMove(MapPosition mapPosition, bool hasGesture) {
    if (hasGesture) {
      setState(() {
        userHasMoved = true;
      });

      if (!isDebug) return;
    }

    if (userHasMoved ||
        !hasStarted ||
        position == null ||
        mapPosition.center == null) return;

    setState(() {
      points.adjustBoundries(mapPosition);

      if (hasStarted) {
        points.add(position!);
      }
    });
  }

  void toggleStart() async {
    if (position == null) await prepare();

    if (shouldRequestPermissions || position == null) return;

    if (hasStarted) await points.save();

    moveToPosition(position!);

    setState(() {
      userHasMoved = false;
      hasStarted = !hasStarted;
    });
  }

  moveToPosition(LatLng newPosition) {
    mapController.move(newPosition, zoomLevel);
  }

  onMapEvent(MapEvent p0) {
    if (p0.zoom != mapController.zoom && position != null) {
      setState(() {
        points.setBoundries(position!, mapController);
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    if (st == null || !hasStarted) return;

    switch (state) {
      case AppLifecycleState.paused:
        st!.pause();
        BackgroundTask.start();
        break;

      case AppLifecycleState.resumed:
        BackgroundTask.stop();
        if (st!.isPaused) st!.resume();
        break;

      case AppLifecycleState.detached:
        st!.cancel();
        BackgroundTask.stop();

      default:
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    tileFilesDetails.load().then((_) => setState(() {}));
    userSettings.load().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: scaffoldKey,
          drawer: Drawer(
            backgroundColor: primary,
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Clear cache'),
                  onTap: tileFilesDetails.clearCache,
                ),
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text('Change trail colour'),
                  onTap: () {
                    setState(() {
                      colorToPick = "trail";
                    });
                    scaffoldKey.currentState?.closeDrawer();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text('Change location dot colour'),
                  onTap: () {
                    setState(() {
                      colorToPick = "dot";
                    });
                    scaffoldKey.currentState?.closeDrawer();
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            label: Text(
              hasStarted ? "Stop" : "Start",
              style: TextStyle(
                color: hasStarted ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
            extendedPadding: const EdgeInsets.all(24),
            extendedIconLabelSpacing: 12,
            elevation: 24,
            shape: const StadiumBorder(side: BorderSide()),
            onPressed: toggleStart,
            backgroundColor:
                hasStarted ? Colors.red : Colors.greenAccent.shade400,
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
                          minZoom: 2,
                          maxZoom: 18,
                          maxBounds: LatLngBounds(
                            CustomBounds.wholeMap.upperLeft,
                            CustomBounds.wholeMap.lowerRight,
                          ),
                          interactiveFlags: InteractiveFlag.drag |
                              InteractiveFlag.doubleTapZoom |
                              InteractiveFlag.flingAnimation |
                              InteractiveFlag.pinchMove |
                              InteractiveFlag.pinchZoom,
                          onMapReady: prepare,
                          onPositionChanged: onMapMove,
                          onMapEvent: onMapEvent,
                        ),
                        nonRotatedChildren: [
                          if (position != null)
                            MarkerLayer(markers: [
                              LocationDot(
                                position!,
                                mapController.zoom,
                                userSettings.locationDot,
                                userSettings.locationDotInner,
                              ),
                              LocationDot(
                                points.prevPoint,
                                mapController.zoom,
                                Colors.red,
                                Colors.red.withAlpha(200),
                              )
                            ]),
                          if (colorToPick != null)
                            AlertDialog(
                              title: const Text('Pick a color!'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: colorToPick == "trail"
                                      ? userSettings.trail
                                      : userSettings.locationDot,
                                  onColorChanged: (value) => setState(() {
                                    if (colorToPick == "trail") {
                                      userSettings.trail = value;
                                    } else {
                                      userSettings.locationDot = value;
                                      userSettings.locationDotInner =
                                          value.withAlpha(200);
                                    }
                                  }),
                                ),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text('Reset'),
                                  onPressed: () {
                                    if (colorToPick == "trail") {
                                      userSettings
                                          .resetTrail()
                                          .then((_) => setState(() {}));
                                    } else {
                                      userSettings
                                          .resetDot()
                                          .then((_) => setState(() {}));
                                    }
                                    setState(() {
                                      colorToPick = null;
                                    });
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text('Got it'),
                                  onPressed: () {
                                    if (colorToPick == "trail") {
                                      userSettings.saveTrail();
                                    } else {
                                      userSettings.saveDot();
                                    }
                                    setState(() {
                                      colorToPick = null;
                                    });
                                  },
                                ),
                              ],
                            ),
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
                                  onPressed: () => setState(
                                      () => shouldRequestPermissions = false),
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
                          ...points.allPoints.map(
                            (pointsList) => PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: pointsList,
                                  color: userSettings.trail,
                                  strokeWidth: 4,
                                ),
                              ],
                            ),
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [...points.newPoints, points.prevPoint],
                                color: userSettings.trail,
                                strokeWidth: 4,
                              ),
                            ],
                          ),
                          // if (position != null)
                          //   PolygonLayer(
                          //     polygons: [
                          //       Polygon(
                          //         points: [
                          //           points.innerBounds.upperLeft,
                          //           LatLng(
                          //               points.innerBounds.upperLeft.latitude,
                          //               points
                          //                   .innerBounds.lowerRight.longitude),
                          //           points.innerBounds.lowerRight,
                          //           LatLng(
                          //               points.innerBounds.lowerRight.latitude,
                          //               points.innerBounds.upperLeft.longitude),
                          //         ],
                          //         borderColor: Colors.black,
                          //         borderStrokeWidth: 2,
                          //       ),
                          //     ],
                          //   ),
                        ],
                      ),
              ),
              Positioned(
                left: 10,
                top: 10,
                child: CircleAvatar(
                  backgroundColor: secondary,
                  radius: 25,
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: scaffoldKey.currentState?.openDrawer,
                  ),
                ),
              ),
              if (userHasMoved && position != null)
                Positioned(
                  bottom: 90,
                  right: 20,
                  child: CircleAvatar(
                    backgroundColor: secondary,
                    radius: 25,
                    child: IconButton(
                      icon: const Icon(Icons.my_location_outlined),
                      onPressed: () {
                        setState(() {
                          userHasMoved = false;
                        });
                        moveToPosition(position!);
                      },
                    ),
                  ),
                ),
            ],
          )),
    );
  }
}

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:background_location/background_location.dart';
import 'package:bike_tracker/components/buttons/fab.dart';
import 'package:bike_tracker/components/buttons/nav_button.dart';
import 'package:bike_tracker/components/buttons/return.dart';
import 'package:bike_tracker/components/custom_drawer.dart';
import 'package:bike_tracker/components/loader.dart';
import 'package:bike_tracker/components/location_dot.dart';
import 'package:bike_tracker/components/request_permissions.dart';
import 'package:bike_tracker/map/network_and_file_tile_provider.dart';
import 'package:bike_tracker/utils/custom_bounds.dart';
import 'package:bike_tracker/utils/points_db.dart';
import 'package:bike_tracker/utils/general.dart';
import 'package:bike_tracker/utils/points.dart';
import 'package:bike_tracker/utils/tile_files_details.dart';
import 'package:bike_tracker/utils/user_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

class Map extends StatefulWidget {
  const Map({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MapState();
}

class MapState extends State<Map> {
  final mapController = MapController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final bool isDebug = kDebugMode &&
      (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

  bool hasStarted = false;
  bool userHasMoved = false;
  bool? shouldRequestPermissions;

  LatLng? position;
  String? colorToPick;
  final Points points = Points();
  final TileFilesDetails tileFilesDetails = TileFilesDetails();
  final UserSettings userSettings = UserSettings();

  Future<void> prepare() async {
    LatLng? newPosition;

    if (isDebug) {
      newPosition = DebugPoints.Eindhoven;
    } else if (await isLocationPermitted()) {
      newPosition = await getPosition();
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

      BackgroundLocation.getLocationUpdates((location) {
        if (location.latitude == null || location.longitude == null) return;

        var newCurrentPosition =
            LatLng(location.latitude!, location.longitude!);
        if (newCurrentPosition == position) return;

        if (!userHasMoved) moveToPosition(newCurrentPosition);

        setState(() {
          position = newCurrentPosition;
          if (hasStarted) {
            points.add(newCurrentPosition);
          }
        });
      });

      setState(() {
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

    if (shouldRequestPermissions != false || position == null) return;

    moveToPosition(position!);

    if (hasStarted) {
      await BackgroundLocation.stopLocationService();
    } else {
      await BackgroundLocation.startLocationService();
    }

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
  void initState() {
    super.initState();

    isLocationPermitted().then((isPermitted) async {
      setState(() {
        shouldRequestPermissions = !isPermitted;
      });
    });

    tileFilesDetails.load().then((_) => setState(() {}));
    userSettings.load().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: scaffoldKey,
          drawer: CustomDrawer(
            changeDotColor: () {
              setState(() {
                colorToPick = "dot";
              });
              scaffoldKey.currentState?.closeDrawer();
            },
            changeTrailColor: () {
              setState(() {
                colorToPick = "trail";
              });
              scaffoldKey.currentState?.closeDrawer();
            },
            clearCache: tileFilesDetails.clearCache,
            colorToPick: colorToPick,
          ),
          floatingActionButton:
              FAB(hasStarted: hasStarted, toggleStart: toggleStart),
          body: Stack(
            children: [
              Center(
                child: shouldRequestPermissions == true
                    ? RequestPermissions(onAllow: () async {
                        await isLocationPermitted();
                        setState(() {
                          shouldRequestPermissions = false;
                        });
                      }, onDeny: () {
                        setState(() {
                          shouldRequestPermissions = false;
                        });
                      })
                    : !tileFilesDetails.hasLoaded ||
                            !userSettings.hasLoaded ||
                            shouldRequestPermissions == null
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
                                      child: const Text('Save'),
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
                                    points: [
                                      ...points.newPoints,
                                      points.prevPoint
                                    ],
                                    color: userSettings.trail,
                                    strokeWidth: 4,
                                  ),
                                ],
                              ),
                            ],
                          ),
              ),
              NavButton(onPress: scaffoldKey.currentState?.openDrawer),
              if (userHasMoved && position != null)
                Return(onPress: () {
                  setState(() {
                    userHasMoved = false;
                  });
                  moveToPosition(position!);
                }),
            ],
          )),
    );
  }
}

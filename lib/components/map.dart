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
import 'package:bike_tracker/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

class Map extends StatefulWidget {
  const Map({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MapState();
}

class MapState extends State<Map> with WidgetsBindingObserver {
  final mapController = MapController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final bool isDebug =
      (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

  bool hasStarted = false;
  bool userHasMoved = false;
  bool shouldRequestPermissions = false;
  bool isForeground = true;

  LatLng? position;
  final Points points = Points();
  final TileFilesDetails tileFilesDetails = TileFilesDetails();

  Future<void> prepare() async {
    LatLng? newPosition;

    if (isDebug) {
      newPosition = DebugPoints.Eindhoven;
    } else {
      BackgroundLocation.startLocationService();
      var currentPosition = await BackgroundLocation().getCurrentLocation();

      if (currentPosition.latitude != null &&
          currentPosition.longitude != null) {
        newPosition =
            LatLng(currentPosition.latitude!, currentPosition.longitude!);
      } else {
        setState(() {
          shouldRequestPermissions = true;
        });
      }
    }

    if (newPosition != null) {
      moveToPosition(newPosition);
      // first move then set up the points!
      points.setUp(await PointsDB.init(), newPosition, mapController).then((_) {
        BackgroundLocation.getLocationUpdates((location) {
          if (location.latitude == null || location.longitude == null) return;

          var newCurrentPosition =
              LatLng(location.latitude!, location.longitude!);

          if (newCurrentPosition == position) return;

          if (!userHasMoved && isForeground) moveToPosition(newCurrentPosition);

          setState(() {
            if (hasStarted) {
              points.add(newCurrentPosition);
            }
            position = newCurrentPosition;
          });
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

    if (!hasStarted || position == null || mapPosition.center == null) return;

    setState(() {
      points.adjustBoundries(mapPosition);
    });
  }

  void toggleStart() async {
    if (position == null) await prepare();

    if (shouldRequestPermissions != false || position == null) return;

    moveToPosition(position!);

    points.insertSeperation();

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
    setState(() {
      isForeground = state == AppLifecycleState.resumed;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    tileFilesDetails.load().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: scaffoldKey,
          drawer: CustomDrawer(
            clearCache: tileFilesDetails.clearCache,
          ),
          floatingActionButton:
              FAB(hasStarted: hasStarted, toggleStart: toggleStart),
          body: Stack(
            children: [
              Center(
                child: shouldRequestPermissions == true
                    ? RequestPermissions(
                        onAllow: () => setState(() {
                              shouldRequestPermissions = false;
                            }),
                        onDeny: () => setState(() {
                              shouldRequestPermissions = false;
                            }))
                    : !tileFilesDetails.hasLoaded
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
                                  LocationDot(position!, mapController.zoom),
                                ]),
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
                                      borderColor: Colors.black,
                                      borderStrokeWidth: 6,
                                      points: pointsList,
                                      color: CustomColorsScheme.trail,
                                      strokeWidth: 4,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
              ),
              NavButton(onPress: scaffoldKey.currentState?.openDrawer),
              if (userHasMoved && position != null)
                ReturnToLocationBtn(onPress: () {
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

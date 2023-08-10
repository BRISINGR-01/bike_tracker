import 'dart:io';
import 'dart:typed_data';

import 'package:bike_tracker/components/loader.dart';
import 'package:bike_tracker/components/location_dot.dart';
import 'package:bike_tracker/network_and_file_tile_provider.dart';
// import 'package:bike_tracker/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
// import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart'
// show TapPosition;

class EindhovenMap extends StatefulWidget {
  final LocationDot? locationDot;
  const EindhovenMap({Key? key, required this.locationDot}) : super(key: key);

  @override
  State<StatefulWidget> createState() => EindhovenMapState();
}

class EindhovenMapState extends State<EindhovenMap> {
  List<LatLng> tappedPoints = [];

  // late final MapController _mapController;
  // LocationDot? _locationDot;
  // bool? _hasPermissions;

  int interActiveFlags = InteractiveFlag.all;

  initLocation() async {
    // if (await isLocationPermitted()) {
    //   Position position = await Geolocator.getCurrentPosition();
    //   setState(() {
    //     _hasPermissions = true;
    //     _locationDot = LocationDot(position);
    //   });
    // } else {
    //   setState(() {
    //     _hasPermissions = false;
    //   });
    // }
  }

  @override
  void initState() {
    super.initState();
  }

  Future getTileFilesDetails() async {
    return {
      "tilesLocalDirectory": await getApplicationDocumentsDirectory(),
      "tilePlaceholder": (await rootBundle.load("assets/placeholder.png"))
          .buffer
          .asUint8List(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: getTileFilesDetails(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Loader();
            return FlutterMap(
              options: MapOptions(
                  center: widget.locationDot?.position,
                  zoom: 13,
                  minZoom: 2,
                  maxZoom: 18,
                  // bounds: LatLngBounds(
                  //   LatLng(51.441771, 5.481684),
                  //   LatLng(51.441771, 5.481684),
                  // ),
                  maxBounds: LatLngBounds(
                    const LatLng(-90, -180.0),
                    const LatLng(90.0, 180.0),
                  ),
                  // onTap: _handleTap,
                  onPositionChanged:
                      (MapPosition position, bool hasGesture) {}),
              children: [
                TileLayer(
                  urlTemplate: '/home/alex/Documents/maps/{z}/{x}/{y}.png',
                  fallbackUrl: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  tileProvider: NetworkAndFileTileProvider(
                    tilesLocalDirectory:
                        snapshot.data["tilesLocalDirectory"] as Directory,
                    placeholder: snapshot.data["tilePlaceholder"] as Uint8List,
                  ),
                  // tileBuilder: (context, tileWidget, tile) {
                  //   String coord =
                  //       "${tile.coordinates.z}/${tile.coordinates.x}/${tile.coordinates.y}";
                  //   File file = (tile.imageProvider as FileImage).file;
                  //   if (unloaded.containsKey(coord)) {
                  //     if (unloaded[coord] == null) return const Loader();

                  //     var a4 = file.readAsBytesSync();
                  //     return Image.memory(a4);
                  //     // return Image.memory(unloaded[coord]!);
                  //     // return Image.file(file);
                  //   } else {
                  //     var a5 = file.readAsBytesSync();
                  //     a5.hashCode;
                  //   }

                  //   return tileWidget;
                  // },
                ),
                if (widget.locationDot != null)
                  MarkerLayer(markers: [
                    Marker(
                      width: 30,
                      height: 30,
                      point: widget.locationDot!.position,
                      builder: (ctx) => SizedBox(
                        height: 2,
                        width: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            border: Border.all(
                              color: Colors.blue,
                            ),
                            // shape: BoxShape.circle,
                          ),
                          // child: ...,
                        ),
                      ),
                    ),
                  ]),
              ],
            );
          }),
    );
  }
}

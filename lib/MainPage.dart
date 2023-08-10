import 'dart:io';

import 'package:bike_tracker/components/loader.dart';
import 'package:bike_tracker/components/location_dot.dart';
import 'package:bike_tracker/components/map.dart';
import 'package:bike_tracker/components/request_permissions.dart';
import 'package:bike_tracker/utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  LocationDot? _locationDot;
  bool? _hasPermissions;

  @override
  void initState() {
    super.initState();
    initLocation();
    // getAllMarkers().then((markers) => setState(() => tappedPoints = markers));
  }

  initLocation() async {
    if (!Platform.isLinux && await isLocationPermitted()) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _hasPermissions = true;
        _locationDot = LocationDot(position);
      });
    } else {
      setState(() {
        _hasPermissions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // switch (_hasPermissions) {
    //   case false:
    //     return const RequestPermissions();
    //   case true:
    return EindhovenMap(locationDot: _locationDot);
    //   default:
    //     return const Loader();
    // }
  }
}

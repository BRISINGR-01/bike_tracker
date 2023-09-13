import 'dart:async';

import 'package:bike_tracker/background/background_points.dart';
import 'package:bike_tracker/components/map.dart';
import 'package:bike_tracker/background/work_manager.dart';
import 'package:bike_tracker/utils/sql_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await BackgroundTask.initialize(callbackDispatcher);

  runApp(const MyApp());
}

@pragma('vm:entry-point')
void callbackDispatcher() async {
  WidgetsFlutterBinding.ensureInitialized();
  StreamSubscription? st;
  var db = await SQLWrapper.init();
  BackgroundPoints points = BackgroundPoints(db);

  Workmanager().executeTask((task, inputData) async {
    if (task == taskNameStart) {
      db.insert([LatLng(0, 0)]);
      if (st == null) {
        try {
          st = Geolocator.getPositionStream().listen(points.add);
        } catch (e) {
          print(e);
        }
      } else {
        if (st!.isPaused) st!.resume();
      }
    } else if (task == taskNameExit) {
      if (st != null) st!.pause();
    }

    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bike tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Map(),
    );
  }
}

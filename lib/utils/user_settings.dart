import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  Color trail = Colors.blue;
  Color locationDot = Colors.green;
  Color locationDotInner = Colors.green.withAlpha(200);
  bool hasLoaded = false;

  Future<void> load() async {
    var pref = await SharedPreferences.getInstance();

    String? trailRawColor = pref.getString("trail");

    if (trailRawColor != null) {
      try {
        List<int> colours =
            trailRawColor.split(",").map((e) => int.parse(e)).toList();
        trail = Color.fromARGB(colours[0], colours[1], colours[2], colours[3]);
      } catch (_) {}
    }
    String? dotRawColor = pref.getString("dot");

    if (dotRawColor != null) {
      try {
        List<int> colours =
            dotRawColor.split(",").map((e) => int.parse(e)).toList();
        locationDot =
            Color.fromARGB(colours[0], colours[1], colours[2], colours[3]);
        locationDotInner = locationDot.withAlpha(200);
      } catch (_) {}
    }

    hasLoaded = true;
  }

  Future<void> resetTrail() async {
    trail = Colors.blue;
    var pref = await SharedPreferences.getInstance();
    pref.remove("trail");
  }

  Future<void> resetDot() async {
    locationDot = Colors.green;
    locationDotInner = Colors.green.withAlpha(200);
    var pref = await SharedPreferences.getInstance();
    pref.remove("dot");
  }

  void saveTrail() async {
    var pref = await SharedPreferences.getInstance();
    pref.setString(
        "trail", "${trail.alpha},${trail.red},${trail.green},${trail.blue}");
  }

  void saveDot() async {
    var pref = await SharedPreferences.getInstance();
    pref.setString("dot",
        "${locationDot.alpha},${locationDot.red},${locationDot.green},${locationDot.blue}");
  }
}

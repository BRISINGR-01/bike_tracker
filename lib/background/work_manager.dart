import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

const String taskNameStart = "geo-bike-tracking";
const String taskNameExit = "exit-geo-bike-tracking";
const String tagStart = "background-task-bike-tracker";
const String tagExit = "exit-background-task-bike-tracker";

class BackgroundTask {
  static Future<void> initialize(Function callbackDispatcher) async {
    return Workmanager()
        .initialize(callbackDispatcher, isInDebugMode: kDebugMode);
  }

  static Future<void> start() async {
    return Workmanager().registerOneOffTask(
      "task-identifier",
      taskNameStart,
      tag: tagStart,
    );
  }

  static Future<void> stop() async {
    await Workmanager().registerOneOffTask(
      "exit-bike-tracker-task-identifier",
      taskNameExit,
      tag: tagExit,
    );
    await Workmanager().cancelByTag(tagStart);
    await Workmanager().cancelByTag(tagExit);
  }
}

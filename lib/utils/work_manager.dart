import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:workmanager/workmanager.dart';

const simpleTaskKey = "be.tramckrijte.workmanagerExample.simpleTask";
const rescheduledTaskKey = "be.tramckrijte.workmanagerExample.rescheduledTask";
const failedTaskKey = "be.tramckrijte.workmanagerExample.failedTask";
const simpleDelayedTask = "be.tramckrijte.workmanagerExample.simpleDelayedTask";
const simplePeriodicTask =
    "be.tramckrijte.workmanagerExample.simplePeriodicTask";
const simplePeriodic1HourTask =
    "be.tramckrijte.workmanagerExample.simplePeriodic1HourTask";

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  // Workmanager().cancelAll();

  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case simpleTaskKey:
        print("$simpleTaskKey was executed. inputData = $inputData");
        break;
      case rescheduledTaskKey:
        final key = inputData!['key']!;
        break;
      case failedTaskKey:
        print('failed task');
      case simpleDelayedTask:
        print("$simpleDelayedTask was executed");
        break;
      case simplePeriodicTask:
        print("$simplePeriodicTask was executed");
        break;
      case simplePeriodic1HourTask:
        print("$simplePeriodic1HourTask was executed");
        break;
      case Workmanager.iOSBackgroundTask:
        print("The iOS background fetch was triggered");
        break;
    }

    return Future.value(true);
  });
}

class WorkManagerUtil {
  void initialize() {
    Workmanager().initialize(callbackDispatcher);
  }

  Future<void> cancel() => Workmanager().cancelAll();
}

import 'package:bike_tracker/utils/colors.dart';
import 'package:flutter/material.dart';

class FAB extends StatelessWidget {
  final bool hasStarted;
  final Function() toggleStart;
  const FAB({super.key, required this.hasStarted, required this.toggleStart});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      label: Text(
        hasStarted ? "Stop" : "Start",
        style: TextStyle(
          color: hasStarted
              ? CustomColorsScheme.secondary
              : CustomColorsScheme.primary,
          fontSize: 16,
        ),
      ),
      extendedPadding: const EdgeInsets.all(24),
      extendedIconLabelSpacing: 12,
      elevation: 24,
      shape: const StadiumBorder(side: BorderSide(width: 4)),
      onPressed: toggleStart,
      backgroundColor: hasStarted
          ? CustomColorsScheme.primary
          : CustomColorsScheme.secondary,
      icon: Icon(
        Icons.flag,
        color: hasStarted
            ? CustomColorsScheme.secondary
            : CustomColorsScheme.primary,
        size: 30,
      ),
    );
  }
}

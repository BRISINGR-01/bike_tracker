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
          color: hasStarted ? Colors.white : Colors.black,
          fontSize: 16,
        ),
      ),
      extendedPadding: const EdgeInsets.all(24),
      extendedIconLabelSpacing: 12,
      elevation: 24,
      shape: const StadiumBorder(side: BorderSide()),
      onPressed: toggleStart,
      backgroundColor: hasStarted ? Colors.red : Colors.greenAccent.shade400,
      icon: Icon(
        Icons.flag,
        color: hasStarted ? Colors.white : Colors.black,
        size: 30,
      ),
    );
  }
}

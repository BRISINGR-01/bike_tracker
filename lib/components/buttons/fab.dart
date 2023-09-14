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
          color:
              hasStarted ? Colors.white : Theme.of(context).colorScheme.primary,
          fontSize: 16,
        ),
      ),
      extendedPadding: const EdgeInsets.all(24),
      extendedIconLabelSpacing: 12,
      elevation: 24,
      shape: const StadiumBorder(side: BorderSide()),
      onPressed: toggleStart,
      backgroundColor:
          hasStarted ? Colors.red : Theme.of(context).colorScheme.secondary,
      icon: Icon(
        Icons.flag,
        color:
            hasStarted ? Colors.white : Theme.of(context).colorScheme.primary,
        size: 30,
      ),
    );
  }
}

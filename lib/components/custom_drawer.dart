import 'package:bike_tracker/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final Function() clearCache;
  const CustomDrawer({Key? key, required this.clearCache}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: CustomColorsScheme.secondary,
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(
              Icons.delete,
              color: CustomColorsScheme.primary,
            ),
            title: const Text(
              'Clear cache',
              style: TextStyle(color: CustomColorsScheme.primary),
            ),
            onTap: clearCache,
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String? colorToPick;
  final Function() clearCache;
  final Function() changeTrailColor;
  final Function() changeDotColor;
  const CustomDrawer({
    Key? key,
    required this.changeDotColor,
    required this.changeTrailColor,
    required this.clearCache,
    required this.colorToPick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Clear cache'),
            onTap: clearCache,
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Change trail colour'),
            onTap: changeTrailColor,
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Change location dot colour'),
            onTap: changeDotColor,
          ),
        ],
      ),
    );
  }
}

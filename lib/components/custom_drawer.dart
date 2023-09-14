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
      backgroundColor: Theme.of(context).colorScheme.secondary,
      child: ListView(
        children: [
          ListTile(
            leading: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              'Clear cache',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            onTap: clearCache,
          ),
          ListTile(
            leading: Icon(
              Icons.color_lens,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              'Change trail colour',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            onTap: changeTrailColor,
          ),
          ListTile(
            leading: Icon(Icons.color_lens,
                color: Theme.of(context).colorScheme.primary),
            title: Text(
              'Change location dot colour',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            onTap: changeDotColor,
          ),
        ],
      ),
    );
  }
}

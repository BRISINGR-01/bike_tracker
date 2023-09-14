import 'package:flutter/material.dart';

class Return extends StatelessWidget {
  final Function() onPress;

  const Return({Key? key, required this.onPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 90,
      right: 20,
      child: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        radius: 25,
        child: IconButton(
          icon: Icon(
            Icons.my_location_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: onPress,
        ),
      ),
    );
  }
}

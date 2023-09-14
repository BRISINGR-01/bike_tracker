import 'package:flutter/material.dart';

class NavButton extends StatelessWidget {
  final Function()? onPress;
  const NavButton({Key? key, required this.onPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 10,
      top: 10,
      child: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        radius: 25,
        child: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: onPress,
        ),
      ),
    );
  }
}

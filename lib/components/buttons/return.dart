import 'package:bike_tracker/utils/colors.dart';
import 'package:flutter/material.dart';

class ReturnToLocationBtn extends StatelessWidget {
  final Function() onPress;

  const ReturnToLocationBtn({Key? key, required this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 90,
      right: 20,
      child: CircleAvatar(
        backgroundColor: CustomColorsScheme.secondary,
        radius: 25,
        child: IconButton(
          icon: const Icon(
            Icons.my_location_outlined,
            color: CustomColorsScheme.primary,
          ),
          onPressed: onPress,
        ),
      ),
    );
  }
}

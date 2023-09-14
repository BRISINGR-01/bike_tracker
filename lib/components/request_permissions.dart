import 'package:flutter/material.dart';

class RequestPermissions extends StatelessWidget {
  final Function() onAllow;
  final Function() onDeny;
  const RequestPermissions(
      {super.key, required this.onAllow, required this.onDeny});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          side: BorderSide(),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      title: const Text("Location Permissions are required"),
      content: const Text("Allow Location?"),
      elevation: 24,
      actions: [
        TextButton(
          onPressed: onAllow,
          child: const Text("Allow"),
        ),
        TextButton(
          onPressed: onDeny,
          child: const Text("Cancel"),
        )
      ],
    );
  }
}

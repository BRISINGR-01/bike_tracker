import 'package:flutter/material.dart';

class RequestPermissions extends StatelessWidget {
  const RequestPermissions({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          children: [Text("Location permissions are required")],
        ),
      ),
    );
  }
}

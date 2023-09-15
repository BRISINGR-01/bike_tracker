import 'package:bike_tracker/components/map.dart';
import 'package:bike_tracker/utils/colors.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bike tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme(
          primary: CustomColorsScheme.primary,
          onPrimary: CustomColorsScheme.secondary,
          secondary: CustomColorsScheme.secondary,
          onSecondary: CustomColorsScheme.primary,
          background: CustomColorsScheme.primary,
          onBackground: CustomColorsScheme.secondary,
          surface: CustomColorsScheme.primary,
          onSurface: CustomColorsScheme.secondary,
          brightness: Brightness.dark,
          error: Colors.red,
          onError: CustomColorsScheme.secondary,
        ),
        useMaterial3: true,
      ),
      home: const Map(),
    );
  }
}

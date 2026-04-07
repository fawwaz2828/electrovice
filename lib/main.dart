import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'firebase_options.dart';
import 'config/routes.dart';
import 'config/mapbox_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Wajib di-set sebelum MapWidget dirender (mapbox_maps_flutter v2.x)
  // Token disimpan di lib/config/mapbox_config.dart (gitignored)
  MapboxOptions.setAccessToken(mapboxPublicToken);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Electrovice',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.register,
      getPages: AppRoutes.routes,
      defaultTransition: Transition.noTransition,
    );
  }
}
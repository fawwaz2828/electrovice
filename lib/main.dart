import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/routes.dart';
import 'config/mapbox_config.dart';

// mapbox_maps_flutter hanya support Android & iOS
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    if (dart.library.html) 'config/mapbox_web_stub.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    // Token disimpan di lib/config/mapbox_config.dart (gitignored)
    MapboxOptions.setAccessToken(mapboxPublicToken);
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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

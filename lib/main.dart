import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'config/mapbox_config.dart';
import 'services/fcm_handler.dart';

// mapbox_maps_flutter hanya support Android & iOS
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    if (dart.library.html) 'config/mapbox_web_stub.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    FlutterNativeSplash.preserve(widgetsBinding: binding);
    MapboxOptions.setAccessToken(mapboxPublicToken);
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await FcmHandler.init();
    FlutterNativeSplash.remove();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Electrovice',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.register,
      getPages: AppRoutes.routes,
      defaultTransition: Transition.noTransition,
    );
  }
}

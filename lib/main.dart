import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
<<<<<<< HEAD
      title: 'ELEcTROVICE',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.register,
=======
      title: 'Electrovice',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.home, // Change this to AppRoutes.login if you want to start with the login page
>>>>>>> c390707f315f0f5e377fe4ecdbd7a990109242fe
      getPages: AppRoutes.routes,
    );
  }
}
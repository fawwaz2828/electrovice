import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/theme.dart';
import 'config/routes.dart';

void main() {
  runApp(const ElectroviceApp());
}

class ElectroviceApp extends StatelessWidget {
  const ElectroviceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Electrovice',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.technicianProfile, // Change this to AppRoutes.login if you want to start with the login page
      getPages: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}

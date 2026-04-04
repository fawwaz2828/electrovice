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
      initialRoute: AppRoutes.register,
      getPages: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}

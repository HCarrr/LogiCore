import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logicore/routes/route_name.dart';
import 'package:logicore/routes/app_pages.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: RoutesName.homeScreen,
      getPages: AppPages.routes,
    );
  }
}

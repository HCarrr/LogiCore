import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logicore/controllers/bottom_nav_controller.dart';
import 'package:logicore/widgets/BottomBar.dart';

import 'Home/HomeScreen.dart';
import 'Requests/RequestsScreen.dart';
import 'Inventory/InventoryScreen.dart';
import 'History/HistoryScreen.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});

  final navController = Get.put(BottomNavController());

  final pages = [
    HomeScreen(),
    RequestsScreen(),
    const InventoryScreen(),
    const HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: navController.selectedIndex.value,
          children: pages,
        ),
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}

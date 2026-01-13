import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logicore/controllers/bottom_nav_controller.dart';
import 'package:logicore/utilities/colors.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BottomNavController>();

    return Container(
      decoration: BoxDecoration(
        color: kColorPureWhite,
        boxShadow: [
          BoxShadow(
            color: kColorMediumGrey.withValues(alpha: 0.2),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(
        () => BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.dashboard_rounded,
                size: 24,
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.list_alt_rounded,
                size: 24,
              ),
              label: 'Requests',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.inventory_2_rounded,
                size: 24,
              ),
              label: 'Inventory',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.history_rounded,
                size: 24,
              ),
              label: 'History',
            ),
          ],
          currentIndex: controller.selectedIndex.value,
          onTap: (int index) {
            controller.changeTab(index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: kColorPureWhite,
          selectedItemColor: kColorPrimary,
          unselectedItemColor: kColorGrey,
          selectedLabelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}

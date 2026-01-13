import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logicore/utilities/colors.dart';
import 'package:logicore/widgets/CustomButton.dart';
import 'package:logicore/widgets/ActivityItemWidget.dart';
import 'package:logicore/widgets/HomeShimmerLoading.dart';

import '../../controllers/Requestor/requestor_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.put(RequestorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 246, 246),
      body: Obx(() {
        // Show shimmer loading when loading and no cached data
        if (controller.isLoading.value &&
            controller.activePR.value == 0 &&
            controller.received.value == 0 &&
            controller.recentActivities.isEmpty) {
          return const HomeShimmerLoading();
        }

        return _buildContent();
      }),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.fetchDashboard();
      },
      backgroundColor: kColorPrimary,
      color: Colors.white,
      displacement: 60,
      strokeWidth: 3,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: Get.width,
              decoration: BoxDecoration(
                color: kColorPureWhite,
                boxShadow: [
                  BoxShadow(
                    color: kColorMediumGrey.withValues(alpha: 0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(
                  left: 22.0, top: 45.0, bottom: 10.0, right: 22.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Logicore",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.logout, size: 25),
                    onPressed: () {
                      controller.logout();
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  Text(
                    "Field Staff Portal",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kColorPrimary),
                  ),
                  Text(
                    "Requestor Dashboard",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: kColorPureWhite,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: kColorMediumGrey.withValues(alpha: 0.15),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 66, 133, 244),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.assessment,
                                      color: kColorPureWhite,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "ACTIVE PRS",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: kColorGrey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Obx(() => Text(
                                    controller.activePR.value.toString(),
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ))
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: kColorPureWhite,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: kColorMediumGrey.withValues(alpha: 0.15),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 76, 175, 80),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.check_circle,
                                      color: kColorPureWhite,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "RECEIVED",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: kColorGrey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Obx(() => Text(
                                    controller.received.value.toString(),
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: Get.width,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kColorPureWhite,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: kColorMediumGrey.withValues(alpha: 0.15),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "PENDING ACTIONS",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: kColorGrey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(() => Text(
                                  controller.pendingActions.value.toString(),
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ))
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 235, 220),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.notifications,
                            color: Color.fromARGB(255, 224, 89, 56),
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Custombutton(
                    text: "Create New Purchase Request",
                    onPressed: () {
                      Get.toNamed('/createPurchaseRequest');
                    },
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Text("Recent Activities",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Spacer(),
                      Text("See All",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: kColorPrimary)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kColorPureWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: kColorMediumGrey.withValues(alpha: 0.15),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Obx(() {
                if (controller.recentActivities.isEmpty) {
                  return Center(
                    child: Text(
                      'No recent activities',
                      style: TextStyle(
                        fontSize: 14,
                        color: kColorGrey,
                      ),
                    ),
                  );
                }

                return Column(
                  children:
                      controller.recentActivities.asMap().entries.map((entry) {
                    final activity = entry.value;
                    final isLast =
                        entry.key == controller.recentActivities.length - 1;

                    return ActivityItemWidget(
                      icon: ActivityItemWidget.getIconFromString(activity.icon),
                      iconBg: ActivityItemWidget.getIconBackgroundColor(
                          activity.status),
                      title: activity.title,
                      subtitle: activity.subtitle ?? '',
                      badgeText: activity.statusBadge,
                      badgeColor: ActivityItemWidget.getBadgeColor(
                          activity.statusBadge),
                      showDivider: !isLast,
                      onTap: () {
                        Get.toNamed('/prDetail',
                            arguments: {'prId': activity.id});
                      },
                    );
                  }).toList(),
                );
              }),
            )
          ],
        ),
      ),
    );
  }
}

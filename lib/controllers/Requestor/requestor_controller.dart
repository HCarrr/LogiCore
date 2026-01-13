import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../services/dashboard_service.dart';
import '../../model/Activity/activity_model.dart';

class RequestorController extends GetxController {
  var isLoading = false.obs;

  var activePR = 0.obs;
  var received = 0.obs;
  var pendingActions = 0.obs;
  var recentActivities = <ActivityModel>[].obs;

  @override
  void onInit() {
    // First try to load cached data for instant UI
    _loadCachedData();
    // Then fetch fresh data in background
    fetchDashboard();
    super.onInit();
  }

  /// Load cached data instantly for faster UI
  void _loadCachedData() {
    try {
      final cachedData = DashboardService.getCachedDashboard();
      if (cachedData != null) {
        print('[RequestorController] Loading cached dashboard data');
        activePR.value = cachedData.summary.activePR;
        received.value = cachedData.summary.received;
        pendingActions.value = cachedData.summary.pendingActions;
        recentActivities.value = cachedData.activities;
      }
    } catch (e) {
      print('[RequestorController] Error loading cached data: $e');
    }
  }

  Future<void> fetchDashboard() async {
    try {
      isLoading.value = true;

      final box = GetStorage();
      final token = box.read('token');

      if (token == null) {
        print('[RequestorController] Token not found in storage');
        Get.snackbar('Error', 'Authentication required. Please login again.');
        return;
      }

      print(
          '[RequestorController] Fetching dashboard with token: ${token.substring(0, 20)}...');

      // Fetch dashboard summary and activities in ONE API call
      final dashboardData = await DashboardService.getFullDashboard(token);

      print(
          '[RequestorController] Dashboard data received: activePR=${dashboardData.summary.activePR}, pending=${dashboardData.summary.pendingActions}, received=${dashboardData.summary.received}');
      print(
          '[RequestorController] Activities received: ${dashboardData.activities.length} items');

      activePR.value = dashboardData.summary.activePR;
      received.value = dashboardData.summary.received;
      pendingActions.value = dashboardData.summary.pendingActions;
      recentActivities.value = dashboardData.activities;
    } catch (e) {
      print('[RequestorController] Error fetching dashboard: $e');
      Get.snackbar('Dashboard Error', e.toString(),
          duration: const Duration(seconds: 5));
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    try {
      isLoading.value = true;

      final box = GetStorage();

      // Clear stored data
      await box.remove('token');
      await box.remove('user');

      // Clear dashboard cache
      DashboardService.clearCache();

      print('[RequestorController] User logged out successfully');

      // Navigate to login page
      Get.offAllNamed('/loginPage');

      Get.snackbar('Success', 'Logged out successfully',
          duration: const Duration(seconds: 2));
    } catch (e) {
      print('[RequestorController] Error during logout: $e');
      Get.snackbar('Error', 'Failed to logout: $e',
          duration: const Duration(seconds: 3));
    } finally {
      isLoading.value = false;
    }
  }
}

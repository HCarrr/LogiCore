import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../services/auth/auth_service.dart';
import '../../services/dashboard_service.dart';

class AuthController extends GetxController {
  final box = GetStorage();
  var isLoading = false.obs;

  void login(String email, String password) async {
    // Validation
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Validasi Error',
        'Email dan password wajib diisi',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Email validation
    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Validasi Error',
        'Format email tidak valid',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      isLoading.value = true;

      final result = await AuthService.login(
        email: email.toLowerCase().trim(),
        password: password,
      );

      // Save to local storage
      box.write('token', result.token);
      box.write('role', result.role);
      box.write('userId', result.userId);
      box.write('email', result.email);
      box.write('name', result.name);

      print(
          '[AuthController] Login berhasil: ${result.email} (${result.role})');

      // Prefetch dashboard data in background (non-blocking)
      // This will cache the data so HomeScreen loads instantly
      DashboardService.prefetchDashboard(result.token);

      // Navigate immediately (don't wait for prefetch)
      if (result.role == 'REQUESTOR') {
        Get.offAllNamed('/mainPage');
      } else if (result.role == 'PROCUREMENT') {
        Get.offAllNamed('/mainPage');
      } else if (result.role == 'ADMIN') {
        Get.offAllNamed('/mainPage');
      } else {
        Get.offAllNamed('/mainPage');
      }
    } catch (e) {
      print('[AuthController] Login error: $e');
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Login Gagal',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        backgroundColor: const Color.fromARGB(255, 244, 67, 54),
      );
    } finally {
      isLoading.value = false;
    }
  }
}

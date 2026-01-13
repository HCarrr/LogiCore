import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../services/purchase_request_service.dart';
import '../../services/item_service.dart';
import '../../services/dashboard_service.dart';
import '../../model/PurchaseRequest/purchase_request_model.dart';
import '../Requestor/requestor_controller.dart';

/// Controller untuk Create Purchase Request
///
/// Backend: https://logi-core-backend.vercel.app (Vercel deployment)
/// Data akan disimpan ke database production
class CreatePRController extends GetxController {
  var isLoading = false.obs;
  var selectedItemId = ''.obs;
  var selectedItemName = ''.obs;
  var availableItems = <ItemModel>[].obs;

  // Form controllers
  final quantityController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void onInit() {
    loadItems();
    super.onInit();
  }

  void loadItems() async {
    try {
      final box = GetStorage();
      final token = box.read('token');

      if (token == null) {
        print('[CreatePRController] Token not found');
        return;
      }

      print('[CreatePRController] Loading items...');
      final items = await ItemService.getAllItems(token);
      availableItems.value = items;

      if (items.isNotEmpty) {
        selectedItemId.value = items[0].id;
        selectedItemName.value = items[0].name;
        print('[CreatePRController] Items loaded: ${items.length} items');
      }
    } catch (e) {
      print('[CreatePRController] Error loading items: $e');
    }
  }

  void selectItem(ItemModel item) {
    selectedItemId.value = item.id;
    selectedItemName.value = item.name;
    print('[CreatePRController] Selected item: ${item.name} (ID: ${item.id})');
  }

  void createPurchaseRequest() async {
    try {
      // Validate item selection
      if (selectedItemId.value.isEmpty) {
        Get.snackbar('Error', 'Please select an item');
        return;
      }

      if (quantityController.text.isEmpty) {
        Get.snackbar('Error', 'Quantity is required');
        return;
      }

      final quantity = int.tryParse(quantityController.text);
      if (quantity == null || quantity <= 0) {
        Get.snackbar('Error', 'Quantity must be a positive number');
        return;
      }

      isLoading.value = true;

      final box = GetStorage();
      final token = box.read('token');

      if (token == null) {
        print('[CreatePRController] Token not found in storage');
        Get.snackbar('Error', 'Authentication required. Please login again.');
        return;
      }

      print(
          '[CreatePRController] Creating PR with item: ${selectedItemName.value} (ID: ${selectedItemId.value})');

      // Create PR request with proper item ID
      final createPRRequest = CreatePRRequest(
        items: [
          PRItem(
            itemId: selectedItemId.value,
            quantity: quantity,
            estimatedUnitPrice: null,
            notes: notesController.text.isEmpty ? null : notesController.text,
          ),
        ],
        notes: null,
        requiredDate: null,
      );

      final response = await PurchaseRequestService.createPurchaseRequest(
        token,
        createPRRequest,
      );

      print(
          '[CreatePRController] PR created successfully: ${response.prNumber}');

      // Clear form
      quantityController.clear();
      notesController.clear();
      selectedItemId.value = '';
      selectedItemName.value = '';

      Get.snackbar(
        'Success',
        'Purchase Request ${response.prNumber} created successfully!',
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
      );

      // Clear dashboard cache so it refreshes
      DashboardService.clearCache();

      // Refresh the dashboard controller if it exists
      if (Get.isRegistered<RequestorController>()) {
        final requestorController = Get.find<RequestorController>();
        requestorController.fetchDashboard();
      }

      // Navigate back to main page
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed('/mainPage');
    } catch (e) {
      print('[CreatePRController] Error type: ${e.runtimeType}');
      print('[CreatePRController] Error creating PR: $e');

      // Extract error message
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('timeout')) {
        errorMessage =
            'Timeout - Backend tidak responsive. Please check connection.';
      } else if (errorMessage.contains('Connection refused')) {
        errorMessage = 'Backend tidak dapat diakses. Please check connection.';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    quantityController.dispose();
    notesController.dispose();
    super.onClose();
  }
}

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../services/pr_list_service.dart';
import '../../model/PurchaseRequest/pr_list_model.dart';

class RequestsController extends GetxController {
  var isLoading = true.obs;
  var allPRs = <PRListItem>[].obs;
  var filteredPRs = <PRListItem>[].obs;
  var searchQuery = ''.obs;
  var selectedStatus = 'ALL'.obs;
  var error = Rxn<String>();

  final List<String> statusFilters = [
    'ALL',
    'DRAFT',
    'PENDING',
    'APPROVED',
    'REJECTED',
    'ORDERED',
    'DELIVERED',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchPRs();
  }

  Future<void> fetchPRs() async {
    try {
      isLoading.value = true;
      error.value = null;

      final box = GetStorage();
      final token = box.read('token');

      if (token == null) {
        error.value = 'Authentication required';
        return;
      }

      final prs = await PRListService.getMyPRs(token);
      allPRs.value = prs;
      _applyFilters();
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void setStatusFilter(String status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  void _applyFilters() {
    var result = allPRs.toList();

    // Apply status filter
    if (selectedStatus.value != 'ALL') {
      result = PRListService.filterByStatus(result, selectedStatus.value);
    }

    // Apply search
    if (searchQuery.value.isNotEmpty) {
      result = PRListService.searchPRs(result, searchQuery.value);
    }

    filteredPRs.value = result;
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedStatus.value = 'ALL';
    _applyFilters();
  }
}

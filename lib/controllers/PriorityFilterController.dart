import 'package:get/get.dart';

class PriorityFilterController extends GetxController {
  final RxString selectedFilter = 'Low'.obs;
  final List<String> filterOptions = ['Low', 'Medium', 'High'];

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }
}

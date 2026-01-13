import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:logicore/utilities/colors.dart';
import '../../controllers/Requests/requests_controller.dart';
import '../../model/PurchaseRequest/pr_list_model.dart';

class RequestsScreen extends StatelessWidget {
  RequestsScreen({super.key});

  final controller = Get.put(RequestsController());
  final searchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 246, 246),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildPRList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kColorPureWhite,
        boxShadow: [
          BoxShadow(
            color: kColorMediumGrey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.only(
          left: 22.0, top: 45.0, bottom: 15.0, right: 22.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "My Requests",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Obx(() {
            final count = controller.filteredPRs.length;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kColorPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count PRs',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kColorPrimary,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: kColorPureWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: kColorMediumGrey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: searchTextController,
          onChanged: controller.setSearchQuery,
          decoration: InputDecoration(
            hintText: 'Search by PR number...',
            hintStyle: TextStyle(color: kColorGrey),
            prefixIcon: Icon(Icons.search, color: kColorGrey),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: kColorGrey),
              onPressed: () {
                searchTextController.clear();
                controller.setSearchQuery('');
              },
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final statuses = controller.statusFilters;

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Obx(() {
              final isSelected = controller.selectedStatus.value == status;
              return FilterChip(
                label: Text(status),
                selected: isSelected,
                onSelected: (selected) {
                  controller.setStatusFilter(status);
                },
                backgroundColor: kColorPureWhite,
                selectedColor: kColorPrimary,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : kColorGrey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? kColorPrimary : Colors.grey.shade300,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildPRList() {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final error = controller.error.value;
      final prs = controller.filteredPRs;
      final searchQuery = controller.searchQuery.value;
      final selectedStatus = controller.selectedStatus.value;

      if (isLoading) {
        return _buildShimmerLoading();
      }

      if (error != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                error,
                style: TextStyle(fontSize: 16, color: kColorGrey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: controller.fetchPRs,
                style: ElevatedButton.styleFrom(backgroundColor: kColorPrimary),
                child:
                    const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }

      if (prs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: kColorMediumGrey),
              const SizedBox(height: 16),
              Text(
                searchQuery.isNotEmpty || selectedStatus != 'ALL'
                    ? 'No PRs found with current filters'
                    : 'No purchase requests yet',
                style: TextStyle(fontSize: 16, color: kColorGrey),
              ),
              if (searchQuery.isNotEmpty || selectedStatus != 'ALL') ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    searchTextController.clear();
                    controller.clearFilters();
                  },
                  child: Text('Clear filters',
                      style: TextStyle(color: kColorPrimary)),
                ),
              ],
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchPRs,
        backgroundColor: kColorPrimary,
        color: Colors.white,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: prs.length,
          itemBuilder: (context, index) => _buildPRCard(prs[index]),
        ),
      );
    });
  }

  Widget _buildPRCard(PRListItem pr) {
    final statusColor = _getStatusColor(pr.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kColorPureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kColorMediumGrey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.toNamed('/prDetail', arguments: {'prId': pr.id}),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: kColorPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.receipt_long,
                              color: kColorPrimary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pr.prNumber,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${pr.itemCount} items',
                              style: TextStyle(fontSize: 12, color: kColorGrey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        pr.status,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: Colors.grey.shade200),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 14, color: kColorGrey),
                        const SizedBox(width: 6),
                        Text(pr.formattedDate,
                            style: TextStyle(fontSize: 13, color: kColorGrey)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.attach_money,
                            size: 16, color: kColorPrimary),
                        Text(
                          pr.formattedTotal,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: kColorPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'APPROVED':
      case 'DELIVERED':
        return Colors.green;
      case 'PENDING' || 'SUBMITTED':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      case 'ORDERED':
        return Colors.blue;
      default:
        return kColorGrey;
    }
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shimmer/shimmer.dart';
import 'package:logicore/utilities/colors.dart';
import 'package:logicore/services/purchase_request_service.dart';
import 'package:logicore/model/PurchaseRequest/pr_detail_model.dart';

class PRDetailScreen extends StatefulWidget {
  const PRDetailScreen({super.key});

  @override
  State<PRDetailScreen> createState() => _PRDetailScreenState();
}

class _PRDetailScreenState extends State<PRDetailScreen> {
  PRDetailModel? prDetail;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadPRDetail();
  }

  Future<void> _loadPRDetail() async {
    final prId = Get.arguments?['prId'] ?? Get.parameters['prId'];

    if (prId == null) {
      setState(() {
        error = 'PR ID not provided';
        isLoading = false;
      });
      return;
    }

    try {
      final box = GetStorage();
      final token = box.read('token');

      if (token == null) {
        setState(() {
          error = 'Authentication required';
          isLoading = false;
        });
        return;
      }

      final detail = await PurchaseRequestService.getPRDetail(token, prId);
      setState(() {
        prDetail = detail;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 246, 246),
      appBar: AppBar(
        backgroundColor: kColorPureWhite,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          prDetail?.prNumber ?? 'PR Detail',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
              error!,
              style: TextStyle(fontSize: 16, color: kColorGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  error = null;
                });
                _loadPRDetail();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildItemsCard(),
          if (prDetail!.approvals.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildApprovalsCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = prDetail!.status;
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'APPROVED':
      case 'DELIVERED':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'SUBMITTED':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'REJECTED':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'ORDERED':
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping;
        break;
      default:
        statusColor = kColorGrey;
        statusIcon = Icons.edit;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withValues(alpha: 0.8), statusColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prDetail!.prNumber,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kColorPureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kColorMediumGrey.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Request Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.person_outline,
            'Requestor',
            prDetail!.requestor?.name ?? 'Unknown',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Created',
            _formatDateTime(prDetail!.createdAt),
          ),
          if (prDetail!.requiredDate != null) ...[
            const Divider(height: 24),
            _buildInfoRow(
              Icons.event_outlined,
              'Required Date',
              _formatDate(prDetail!.requiredDate!),
            ),
          ],
          const Divider(height: 24),
          _buildInfoRow(
            Icons.shopping_cart_outlined,
            'Total Items',
            '${prDetail!.totalItems} items',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.attach_money,
            'Est. Total',
            _formatCurrency(prDetail!.totalEstimatedCost),
          ),
          if (prDetail!.notes != null && prDetail!.notes!.isNotEmpty) ...[
            const Divider(height: 24),
            _buildInfoRow(
              Icons.notes_outlined,
              'Notes',
              prDetail!.notes!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: kColorPrimary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: kColorGrey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kColorPureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kColorMediumGrey.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Items',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kColorPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${prDetail!.items.length} items',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kColorPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...prDetail!.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == prDetail!.items.length - 1;
            return _buildItemRow(item, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildItemRow(PRDetailItem item, bool isLast) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: kColorPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: kColorPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.itemCode != null)
                      Text(
                        item.itemCode!,
                        style: TextStyle(fontSize: 12, color: kColorGrey),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${item.quantity} ${item.unit ?? 'pcs'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: kColorPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '× ${_formatCurrency(item.estimatedUnitPrice)}',
                          style: TextStyle(fontSize: 12, color: kColorGrey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                _formatCurrency(item.totalPrice),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildApprovalsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kColorPureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kColorMediumGrey.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Approval History',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...prDetail!.approvals.map((approval) => _buildApprovalRow(approval)),
        ],
      ),
    );
  }

  Widget _buildApprovalRow(PRApproval approval) {
    Color statusColor =
        approval.status == 'APPROVED' ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              approval.status == 'APPROVED' ? Icons.check : Icons.close,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  approval.approver?.name ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (approval.comments != null)
                  Text(
                    approval.comments!,
                    style: TextStyle(fontSize: 12, color: kColorGrey),
                  ),
              ],
            ),
          ),
          Text(
            approval.approvedAt != null
                ? _formatDateTime(approval.approvedAt!)
                : '',
            style: TextStyle(fontSize: 11, color: kColorGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }
}

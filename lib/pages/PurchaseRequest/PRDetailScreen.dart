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
  bool isSubmitting = false;
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

  Future<void> _submitPR() async {
    if (prDetail == null) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final box = GetStorage();
      final token = box.read('token');

      if (token == null) {
        Get.snackbar(
          'Error',
          'Authentication required',
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return;
      }

      await PurchaseRequestService.submitPR(token, prDetail!.id);

      Get.snackbar(
        'Success',
        'Purchase Request submitted successfully!',
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
      );

      // Reload PR detail to get updated status
      _loadPRDetail();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Future<void> _deletePR() async {
    if (prDetail == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Purchase Request'),
        content: Text(
          'Are you sure you want to delete ${prDetail!.prNumber}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      isLoading = true;
    });

    try {
      final box = GetStorage();
      final token = box.read('token');

      if (token == null) {
        Get.snackbar(
          'Error',
          'Authentication required',
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return;
      }

      await PurchaseRequestService.deletePR(token, prDetail!.id);

      Get.snackbar(
        'Success',
        'Purchase Request deleted successfully!',
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
      );

      // Navigate back to previous screen
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showEditDialog() {
    if (prDetail == null || prDetail!.items.isEmpty) return;

    final item = prDetail!.items.first;
    final quantityController =
        TextEditingController(text: item.quantity.toString());
    final priceController = TextEditingController(
      text: item.estimatedUnitPrice > 0
          ? item.estimatedUnitPrice.toStringAsFixed(0)
          : '',
    );
    final notesController = TextEditingController(text: prDetail!.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Purchase Request'),
        backgroundColor: kColorPureWhite,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Harga Satuan (Rp)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updatePR(
                quantity: int.tryParse(quantityController.text),
                price: double.tryParse(priceController.text),
                notes:
                    notesController.text.isEmpty ? null : notesController.text,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: kColorPrimary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePR({int? quantity, double? price, String? notes}) async {
    if (prDetail == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final box = GetStorage();
      final token = box.read('token');

      if (token == null) {
        Get.snackbar(
          'Error',
          'Authentication required',
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
        return;
      }

      await PurchaseRequestService.updatePR(
        token,
        prDetail!.id,
        quantity: quantity,
        estimatedUnitPrice: price,
        notes: notes,
      );

      Get.snackbar(
        'Success',
        'Purchase Request updated successfully!',
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
      );

      // Reload PR detail to get updated data
      setState(() {
        isLoading = true;
      });
      await _loadPRDetail();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      setState(() {
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
          _buildStatusTimeline(),
          const SizedBox(height: 16),
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildItemsCard(),
          if (prDetail!.approvals.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildApprovalsCard(),
          ],
          // Show action buttons only when status is DRAFT
          if (prDetail!.status.toUpperCase() == 'DRAFT') ...[
            const SizedBox(height: 24),
            _buildDraftActionButtons(),
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

  Widget _buildStatusTimeline() {
    final List<String> steps = [
      'Draft',
      'Submitted',
      'Approved',
      'Ordered',
      'Delivered'
    ];
    final String currentStatus = prDetail!.status.toUpperCase();

    // Get current step index based on status
    int currentStepIndex = 0;
    switch (currentStatus) {
      case 'DRAFT':
        currentStepIndex = 0;
        break;
      case 'SUBMITTED':
        currentStepIndex = 1;
        break;
      case 'APPROVED':
        currentStepIndex = 2;
        break;
      case 'ORDERED':
        currentStepIndex = 3;
        break;
      case 'DELIVERED':
        currentStepIndex = 4;
        break;
      case 'REJECTED':
        currentStepIndex = -1; // Special case for rejected
        break;
      default:
        currentStepIndex = 0;
    }

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
            'Status Timeline',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isEven) {
                // Step circle
                final stepIndex = index ~/ 2;
                final isCompleted = stepIndex < currentStepIndex;
                final isCurrent = stepIndex == currentStepIndex;
                final isRejected =
                    currentStatus == 'REJECTED' && stepIndex == 1;

                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isRejected
                              ? Colors.red
                              : (isCompleted || isCurrent)
                                  ? Colors.green
                                  : Colors.grey[300],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isRejected
                                ? Colors.red
                                : (isCompleted || isCurrent)
                                    ? Colors.green
                                    : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: (isCompleted || isCurrent)
                            ? Icon(
                                isRejected ? Icons.close : Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        steps[stepIndex],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: (isCompleted || isCurrent)
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: (isCompleted || isCurrent)
                              ? Colors.black87
                              : Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              } else {
                // Connector line
                final stepIndex = index ~/ 2;
                final isCompleted = stepIndex < currentStepIndex;

                return Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftActionButtons() {
    return Column(
      children: [
        // Edit and Delete buttons row
        Row(
          children: [
            // Edit button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showEditDialog,
                icon: const Icon(
                  Icons.edit,
                  size: 18,
                  color: kColorPureWhite,
                ),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kColorPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Delete button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _deletePR,
                icon:
                    const Icon(Icons.delete, size: 18, color: kColorPureWhite),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : _submitPR,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, size: 20, color: kColorPureWhite),
                      SizedBox(width: 8),
                      Text(
                        'Submit Purchase Request',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
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

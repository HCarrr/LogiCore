import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logicore/widgets/CustomButton.dart';
import 'package:logicore/widgets/LoadingWidgets.dart';

import '../../utilities/colors.dart';
import '../../widgets/InfoContainer.dart';
import '../../widgets/CustomTextField.dart';
import '../../controllers/PurchaseRequest/create_pr_controller.dart';

class CreatePurchaseRequest extends StatelessWidget {
  CreatePurchaseRequest({super.key});

  final controller = Get.put(CreatePRController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 246, 246),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            child: Column(
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
                      left: 22.0, top: 45.0, bottom: 15.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 24,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Center(
                        child: Text(
                          "Create Purchase Request",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoContainer(
                        message:
                            "Data legal adalah data untuk administrasi karyawan yang diatur oleh pihak manajemen.",
                        icon: Icons.info,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Item Details",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      // Item Selection Dropdown
                      Obx(() {
                        if (controller.availableItems.isEmpty) {
                          return Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Loading items...'),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Select Item",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: controller.selectedItemId.value.isEmpty
                                    ? null
                                    : controller.selectedItemId.value,
                                isExpanded: true,
                                hint: Padding(
                                  padding: EdgeInsets.only(left: 12),
                                  child: Text('Select an item'),
                                ),
                                items: controller.availableItems.map((item) {
                                  return DropdownMenuItem<String>(
                                    value: item.id,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(item.name,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500)),
                                          Text(
                                            '${item.sku} • ${item.unit}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (itemId) {
                                  if (itemId != null) {
                                    final item = controller.availableItems
                                        .firstWhere((i) => i.id == itemId);
                                    controller.selectItem(item);
                                  }
                                },
                                underline: SizedBox(),
                              ),
                            ),
                          ],
                        );
                      }),
                      SizedBox(height: 12),
                      CustomTextField(
                        label: "Quantity",
                        inputType: InputType.number,
                        hintText: "Enter quantity",
                        controller: controller.quantityController,
                      ),
                      SizedBox(height: 12),
                      CustomTextField(
                        label: "Notes",
                        inputType: InputType.text,
                        hintText: "Enter additional notes",
                        maxLines: 5,
                        controller: controller.notesController,
                      ),
                      SizedBox(height: 30),
                      Obx(() => Custombutton(
                            text: controller.isLoading.value
                                ? "Creating..."
                                : "Create Purchase Request",
                            icon: controller.isLoading.value
                                ? Icons.hourglass_empty
                                : Icons.add,
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    controller.createPurchaseRequest();
                                  },
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Loading overlay
          Obx(() => controller.isLoading.value
              ? const CreatePRLoadingOverlay()
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

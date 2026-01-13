import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logicore/controllers/PriorityFilterController.dart';
import 'package:logicore/utilities/colors.dart';

class PriorityFilterButton extends StatelessWidget {
  final Function(String)? onFilterChanged;

  PriorityFilterButton({
    super.key,
    this.onFilterChanged,
  });

  final controller = Get.put(PriorityFilterController());

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 240, 240, 240),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: List.generate(
          controller.filterOptions.length,
          (index) {
            final filter = controller.filterOptions[index];
            return Expanded(
              child: Obx(
                () {
                  final isSelected = controller.selectedFilter.value == filter;
                  return GestureDetector(
                    onTap: () {
                      controller.setFilter(filter);
                      onFilterChanged?.call(filter);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? kColorPureWhite : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: kColorMediumGrey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? kColorPrimary : kColorGrey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

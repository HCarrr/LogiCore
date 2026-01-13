import 'package:flutter/material.dart';
import 'package:logicore/utilities/colors.dart';

class InfoContainer extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;

  const InfoContainer({
    super.key,
    required this.message,
    this.icon = Icons.info,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color.fromARGB(255, 207, 226, 251),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconColor ?? const Color.fromARGB(255, 25, 103, 210),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Icon(
                icon,
                color: kColorPureWhite,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor ?? const Color.fromARGB(255, 25, 103, 210),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

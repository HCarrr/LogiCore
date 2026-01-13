import 'package:flutter/material.dart';
import 'package:logicore/utilities/colors.dart';

class Custombutton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  const Custombutton({
    super.key,
    this.onPressed,
    this.text = "Button",
    this.icon = Icons.add,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              backgroundColor ?? const Color.fromARGB(255, 66, 133, 244),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor ?? kColorPureWhite,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor ?? kColorPureWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

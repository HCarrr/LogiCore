import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logicore/utilities/colors.dart';

enum InputType { text, number }

class CustomTextField extends StatelessWidget {
  final String label;
  final InputType inputType;
  final TextEditingController? controller;
  final String? hintText;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.label,
    required this.inputType,
    this.controller,
    this.hintText,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: kColorDarkGrey),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: maxLines,
          keyboardType: inputType == InputType.number
              ? TextInputType.number
              : TextInputType.text,
          inputFormatters: inputType == InputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : [],
          decoration: InputDecoration(
            filled: true,
            fillColor: kColorLightGrey,
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: kColorMediumGrey,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: kColorMediumGrey,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: kColorMediumGrey,
                width: 1.5,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CutsomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool? readOnly;
  final IconData? suffixIcon;
  final void Function()? onTap;
  const CutsomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.validator,
    this.keyboardType,
    this.readOnly,
    this.suffixIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        child: TextFormField(
          readOnly: readOnly ?? false,
          onTap: onTap,
          keyboardType: keyboardType,
          validator: validator,
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: Icon(suffixIcon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              //change border color
              borderSide: BorderSide(color: Colors.black),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}

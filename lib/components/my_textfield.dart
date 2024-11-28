import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Color borderColor; // Border color
  final Color textColor; // Text color

  MyTextField({
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.borderColor = Colors.black, // Default border color is black
    this.textColor = Colors.black, // Default text color
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: textColor), // Apply text color here
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: textColor.withOpacity(0.6)), // Hint color
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 1.0), // Black border by default
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 2.0), // Thicker black border on focus
          borderRadius: BorderRadius.circular(8.0), // Rounded corners on focus
        ),
        filled: true,
        fillColor: Colors.white, // Optional: white background
      ),
    );
  }
}

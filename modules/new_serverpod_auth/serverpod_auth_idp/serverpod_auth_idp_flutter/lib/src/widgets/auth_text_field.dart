import 'package:flutter/material.dart';

/// A standard text field widget for authentication forms.
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final String? hintText;
  final bool isLoading;

  const AuthTextField({
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.hintText,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hintText: hintText,
      ),
      keyboardType: keyboardType,
      enabled: !isLoading,
    );
  }
}

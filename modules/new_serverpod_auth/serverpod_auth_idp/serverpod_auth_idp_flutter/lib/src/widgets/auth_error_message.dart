import 'package:flutter/material.dart';

/// A widget to display an error message.
class AuthErrorMessage extends StatelessWidget {
  final String errorMessage;

  const AuthErrorMessage({
    required this.errorMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        errorMessage,
        style: TextStyle(color: Colors.red.shade900),
      ),
    );
  }
}

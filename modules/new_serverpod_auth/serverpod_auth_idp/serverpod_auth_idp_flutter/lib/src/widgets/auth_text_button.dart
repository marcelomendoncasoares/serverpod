import 'package:flutter/material.dart';

/// A standard text button widget for authentication forms.
class AuthTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isLoading;

  const AuthTextButton({
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: Text(label),
    );
  }
}

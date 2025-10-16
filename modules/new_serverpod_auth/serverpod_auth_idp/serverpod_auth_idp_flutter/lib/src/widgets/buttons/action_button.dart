import 'package:flutter/material.dart';
import '../loading_indicator.dart';

/// A standard action button widget for authentication forms.
class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isLoading;

  const ActionButton({
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        shape: StadiumBorder(),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading ? const LoadingIndicator() : Text(label),
    );
  }
}

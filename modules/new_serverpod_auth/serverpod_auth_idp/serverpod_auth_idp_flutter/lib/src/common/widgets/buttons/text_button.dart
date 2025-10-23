import 'package:flutter/material.dart';

/// A standard text button widget for authentication forms.
class HyperlinkTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const HyperlinkTextButton({
    required this.onPressed,
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

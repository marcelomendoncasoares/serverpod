import 'package:flutter/material.dart' hide TextButton;
import 'package:flutter/material.dart' as material show TextButton;

/// A standard text button widget for authentication forms.
class TextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isLoading;

  const TextButton({
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return material.TextButton(
      onPressed: isLoading ? null : onPressed,
      child: Text(label),
    );
  }
}

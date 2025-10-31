import 'package:flutter/material.dart';

import 'icon.dart';

/// A styled button for Google Sign-In on native platforms.
class GoogleSignInNativeButton extends StatelessWidget {
  final VoidCallback onPressed;

  /// Whether the button is currently loading.
  final bool isLoading;

  /// Whether the button is disabled.
  final bool isDisabled;

  /// Creates a Google Sign-In button for native platforms.
  const GoogleSignInNativeButton({
    required this.onPressed,
    required this.isLoading,
    required this.isDisabled,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // NOTE: Styled according to official guidelines.
    // https://developers.google.com/identity/branding-guidelines#padding
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        shape: StadiumBorder(
          side: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(isLoading ? 'Signing in...' : 'Continue with Google'),
            ),
          ),
          Positioned(
            left: 12,
            top: 0,
            bottom: 0,
            child: GoogleSignInIcon(
              isLoading: isLoading,
              isDisabled: isDisabled,
            ),
          ),
        ],
      ),
    );
  }
}

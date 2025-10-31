import 'package:flutter/material.dart';

/// The Google icon for the Google Sign-In button.
class GoogleSignInIcon extends StatelessWidget {
  /// Whether the button is currently loading.
  final bool isLoading;

  /// Whether the button is disabled.
  final bool isDisabled;

  /// Creates a Google Sign-In icon.
  const GoogleSignInIcon(
      {required this.isDisabled, required this.isLoading, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey,
              ),
            )
          : Image.asset(
              'assets/images/google.png',
              package: 'serverpod_auth_idp_flutter',
              height: 20,
              width: 20,
              color: isDisabled ? const Color(0xff9c9c9c) : null,
            ),
    );
  }
}

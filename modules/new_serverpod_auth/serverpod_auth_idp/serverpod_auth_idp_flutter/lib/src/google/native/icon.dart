import 'package:flutter/material.dart';

/// The Google icon for the Google Sign-In button.
class GoogleSignInIcon extends StatelessWidget {
  /// Whether the button is currently loading.
  final bool isLoading;

  /// Whether the button is disabled.
  final bool isDisabled;

  /// The background color of the icon.
  final Color? backgroundColor;

  /// The border radius of the icon.
  final BorderRadius? borderRadius;

  /// The size of the icon.
  final double size;

  /// Creates a Google Sign-In icon.
  const GoogleSignInIcon({
    this.backgroundColor,
    this.borderRadius,
    this.size = 22,
    required this.isDisabled,
    required this.isLoading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 36,
        width: 36,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        child: Center(
          child: SizedBox(
            height: size,
            width: size,
            child: isLoading
                ? CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.grey,
                  )
                : Image.asset(
                    'assets/images/google.png',
                    package: 'serverpod_auth_idp_flutter',
                    color: isDisabled ? const Color(0xff9c9c9c) : null,
                    fit: BoxFit.scaleDown, // or BoxFit.none
                  ),
          ),
        ),
      ),
    );
  }
}

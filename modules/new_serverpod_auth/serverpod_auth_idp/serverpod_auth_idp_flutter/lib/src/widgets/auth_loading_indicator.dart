import 'package:flutter/material.dart';

/// A widget to show when a request is in progress.
class AuthLoadingIndicator extends StatelessWidget {
  const AuthLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

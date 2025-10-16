import 'package:flutter/material.dart';
import 'auth_error_message.dart';
import 'auth_gaps.dart';

/// A standard page scaffold for authentication screens.
class AuthPageScaffold extends StatelessWidget {
  final String title;
  final List<Widget> pageWidgets;
  final VoidCallback onClose;
  final String? errorMessage;

  const AuthPageScaffold({
    required this.title,
    required this.pageWidgets,
    required this.onClose,
    this.errorMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose,
        ),
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (errorMessage != null) ...[
                AuthErrorMessage(errorMessage: errorMessage!),
                smallGap,
              ],
              ...pageWidgets,
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'error_message.dart';
import 'gaps.dart';

/// A standard page scaffold for authentication screens.
class DefaultScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final String? errorMessage;

  const DefaultScaffold({
    required this.title,
    required this.child,
    this.onBack,
    this.errorMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              )
            : null,
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (errorMessage != null) ...[
                ErrorMessage(errorMessage: errorMessage!),
                smallGap,
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../controllers/email_auth_controller.dart';
import '../widgets/buttons/action_button.dart';
import '../widgets/gaps.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/text_field.dart';

/// Password reset request screen widget.
///
/// Displays an email field for users to request a password reset.
class PasswordResetRequestScreen extends StatelessWidget {
  /// The controller that manages authentication state and logic.
  final EmailAuthController controller;

  /// Creates a password reset request screen widget.
  const PasswordResetRequestScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Request Password Reset',
      onBack: () => controller.navigateTo(EmailFlowScreen.login),
      errorMessage: controller.errorMessage,
      pageWidgets: [
        Text(
          'Enter the email address to request password reset.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        smallGap,
        AuthTextField(
          controller: controller.emailController,
          labelText: 'Email',
          keyboardType: TextInputType.emailAddress,
          isLoading: controller.isLoading,
        ),
        largeGap,
        ActionButton(
          onPressed: controller.startPasswordReset,
          label: 'Request Password Reset',
          isLoading: controller.isLoading,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../email_auth_controller.dart';
import '../../common/widgets/buttons/action_button.dart';
import '../../common/widgets/gaps.dart';
import '../../common/widgets/text_field.dart';

/// Password reset request screen widget.
///
/// Displays an email field for users to request a password reset.
class PasswordResetForm extends StatelessWidget {
  /// The controller that manages authentication state and logic.
  final EmailAuthController controller;

  /// Creates a password reset request screen widget.
  const PasswordResetForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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

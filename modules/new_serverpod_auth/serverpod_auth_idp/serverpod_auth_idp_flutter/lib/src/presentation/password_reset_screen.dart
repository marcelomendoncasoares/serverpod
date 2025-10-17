import 'package:flutter/material.dart';

import '../controllers/email_auth_controller.dart';
import '../widgets/buttons/action_button.dart';
import '../widgets/gaps.dart';
import '../widgets/password_field.dart';
import '../widgets/verification_code.dart';

/// Password reset screen widget.
///
/// Displays a verification code input field and a new password field
/// for users to complete the password reset process.
class PasswordResetScreen extends StatelessWidget {
  /// The controller that manages authentication state and logic.
  final EmailAuthController controller;

  /// Creates a password reset screen widget.
  const PasswordResetScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'A password reset email has been sent. Please check your email and '
          'enter the details below.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        largeGap,
        VerificationCodeInput(
          verificationCodeController: controller.verificationCodeController,
          onCompleted: controller.finishPasswordReset,
          isLoading: controller.isLoading,
        ),
        smallGap,
        PasswordField(
          labelText: 'New Password',
          controller: controller.passwordController,
          isLoading: controller.isLoading,
        ),
        largeGap,
        ActionButton(
          onPressed: controller.finishPasswordReset,
          label: 'Reset Password',
          isLoading: controller.isLoading,
        ),
      ],
    );
  }
}

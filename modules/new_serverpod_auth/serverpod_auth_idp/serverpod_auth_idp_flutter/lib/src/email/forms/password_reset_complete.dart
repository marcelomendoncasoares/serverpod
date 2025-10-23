import 'package:flutter/material.dart';

import '../../common/widgets/buttons/action_button.dart';
import '../../common/widgets/gaps.dart';
import '../../common/widgets/password_field.dart';
import '../../common/widgets/verification_code.dart';
import '../email_auth_controller.dart';
import 'widgets/back_to_sign_in_button.dart';

/// Password reset screen widget.
///
/// Displays a verification code input field and a new password field
/// for users to complete the password reset process.
class PasswordResetCompleteForm extends StatelessWidget {
  /// The controller that manages authentication state and logic.
  final EmailAuthController controller;

  /// Creates a password reset screen widget.
  const PasswordResetCompleteForm({super.key, required this.controller});

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
        BackToSignInButton(controller: controller),
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

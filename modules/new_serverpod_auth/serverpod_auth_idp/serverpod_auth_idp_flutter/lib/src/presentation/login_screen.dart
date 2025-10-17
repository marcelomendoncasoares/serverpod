import 'package:flutter/material.dart';

import '../controllers/email_auth_controller.dart';
import '../widgets/buttons/action_button.dart';
import '../widgets/buttons/text_button.dart' as custom;
import '../widgets/gaps.dart';
import '../widgets/password_field.dart';
import '../widgets/text_field.dart';

/// Login screen widget for email authentication.
///
/// Displays email and password fields with options to sign in,
/// create an account, or reset password.
class LoginScreen extends StatelessWidget {
  /// The controller that manages authentication state and logic.
  final EmailAuthController controller;

  /// Callback function to be called when the screen is closed.
  /// Only valid if this is the starting screen. Otherwise will be ignored.
  final VoidCallback? onBack;

  /// Creates a login screen widget.
  const LoginScreen({super.key, required this.controller, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          controller: controller.emailController,
          labelText: 'Email',
          keyboardType: TextInputType.emailAddress,
          isLoading: controller.isLoading,
        ),
        smallGap,
        PasswordField(
          controller: controller.passwordController,
          isLoading: controller.isLoading,
        ),
        largeGap,
        ActionButton(
          onPressed: controller.login,
          label: 'Sign In',
          isLoading: controller.isLoading,
        ),
        smallGap,
        custom.TextButton(
          onPressed: () => controller.navigateTo(EmailFlowScreen.register),
          label: 'Create Account',
          isLoading: controller.isLoading,
        ),
        smallGap,
        custom.TextButton(
          onPressed: () => controller.navigateTo(EmailFlowScreen.passwordReset),
          label: 'Forgot Password?',
          isLoading: controller.isLoading,
        ),
      ],
    );
  }
}

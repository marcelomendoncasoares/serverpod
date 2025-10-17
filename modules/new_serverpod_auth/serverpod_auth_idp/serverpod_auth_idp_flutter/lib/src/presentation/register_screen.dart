import 'package:flutter/material.dart';

import '../controllers/email_auth_controller.dart';
import '../widgets/buttons/action_button.dart';
import '../widgets/gaps.dart';
import '../widgets/password_field.dart';
import '../widgets/text_field.dart';

/// Registration screen widget for email authentication.
///
/// Displays email and password fields for creating a new account.
class RegisterScreen extends StatelessWidget {
  /// The controller that manages authentication state and logic.
  final EmailAuthController controller;

  /// Callback function to be called when the screen is closed.
  /// Only valid if this is the starting screen. Otherwise will be ignored.
  final VoidCallback? onBack;

  /// Creates a registration screen widget.
  const RegisterScreen({super.key, required this.controller, this.onBack});

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
          onPressed: controller.startRegistration,
          label: 'Register',
          isLoading: controller.isLoading,
        ),
        smallGap,
        TextButton(
          onPressed: () => controller.navigateTo(EmailFlowScreen.login),
          child: Text('Already have an account? Login'),
        ),
      ],
    );
  }
}

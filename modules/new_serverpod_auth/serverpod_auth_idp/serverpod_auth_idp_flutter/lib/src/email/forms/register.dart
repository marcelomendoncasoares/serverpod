import 'package:flutter/material.dart';

import '../../common/widgets/buttons/action_button.dart';
import '../../common/widgets/buttons/text_button.dart';
import '../../common/widgets/gaps.dart';
import '../../common/widgets/password_field.dart';
import '../../common/widgets/text_field.dart';
import '../email_auth_controller.dart';

/// Registration screen widget for email authentication.
///
/// Displays email and password fields for creating a new account.
class RegisterForm extends StatelessWidget {
  /// The controller that manages authentication state and logic.
  final EmailAuthController controller;

  /// Creates a registration screen widget.
  const RegisterForm({super.key, required this.controller});

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
        // Represent the same height as the "Forgot password?" text.
        SizedBox(height: 48),
        largeGap,
        ActionButton(
          onPressed: controller.startRegistration,
          label: 'Create account',
          isLoading: controller.isLoading,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Already have an account?"),
            HyperlinkTextButton(
              onPressed: () => controller.navigateTo(EmailFlowScreen.login),
              label: 'Sign in',
            ),
          ],
        ),
      ],
    );
  }
}

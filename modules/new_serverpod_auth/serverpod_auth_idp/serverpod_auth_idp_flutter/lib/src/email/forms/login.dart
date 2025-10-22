import 'package:flutter/material.dart';

import '../email_auth_controller.dart';
import '../../common/widgets/buttons/action_button.dart';
import '../../common/widgets/buttons/text_button.dart';
import '../../common/widgets/gaps.dart';
import '../../common/widgets/password_field.dart';
import '../../common/widgets/text_field.dart';

/// Login screen widget for email authentication.
///
/// Displays email and password fields with options to sign in,
/// create an account, or reset password.
class LoginForm extends StatelessWidget {
  /// The controller that manages authentication state and logic.
  final EmailAuthController controller;

  /// Creates a login screen widget.
  const LoginForm({super.key, required this.controller});

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
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            HyperlinkTextButton(
              onPressed: () =>
                  controller.navigateTo(EmailFlowScreen.passwordReset),
              label: 'Forgot password?',
            ),
          ],
        ),
        largeGap,
        ActionButton(
          onPressed: controller.login,
          label: 'Log in',
          isLoading: controller.isLoading,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have an account?"),
            HyperlinkTextButton(
              onPressed: () => controller.navigateTo(EmailFlowScreen.register),
              label: 'Sign up',
            ),
          ],
        ),
      ],
    );
  }
}

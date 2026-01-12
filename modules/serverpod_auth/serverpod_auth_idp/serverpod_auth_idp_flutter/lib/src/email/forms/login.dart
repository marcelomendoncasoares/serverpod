import 'package:flutter/material.dart';

import '../../common/widgets/buttons/action_button.dart';
import '../../common/widgets/buttons/text_button.dart';
import '../../common/widgets/gaps.dart';
import '../../common/widgets/password_field.dart';
import '../email_auth_controller.dart';
import 'widgets/email_text_field.dart';
import 'widgets/form_standard_layout.dart';

/// Login form widget for email authentication.
///
/// Displays email and password fields with options to sign in, create a new
/// account, or reset password.
class LoginForm extends StatelessWidget {
  /// The controller that manages authentication state and logic.
  final EmailAuthController controller;

  /// Optional shared [ValueNotifier] to disable buttons when any IDP is processing.
  final ValueNotifier<bool>? sharedLoadingNotifier;

  /// Creates a [LoginForm] widget.
  const LoginForm({
    super.key,
    required this.controller,
    this.sharedLoadingNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = controller.isLoading ||
        (sharedLoadingNotifier?.value ?? false);
    return FormStandardLayout(
      title: 'Sign In with email',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmailTextField(
            controller: controller,
            sharedLoadingNotifier: sharedLoadingNotifier,
          ),
          smallGap,
          PasswordField(
            controller: controller.passwordController,
            isLoading: isLoading,
          ),
          tinyGap,
          Align(
            alignment: Alignment.centerRight,
            child: HyperlinkTextButton(
              onPressed: () =>
                  controller.navigateTo(EmailFlowScreen.requestPasswordReset),
              label: 'Forgot password?',
            ),
          ),
        ],
      ),
      actionButton: ActionButton(
        onPressed:
            controller.emailController.text.isNotEmpty &&
                controller.passwordController.text.isNotEmpty &&
                controller.state == EmailAuthState.idle &&
                !isLoading
            ? controller.login
            : null,
        label: 'Sign in',
        isLoading: isLoading,
      ),
      bottomText: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Don't have an account?"),
          HyperlinkTextButton(
            onPressed: () =>
                controller.navigateTo(EmailFlowScreen.startRegistration),
            label: 'Sign up',
          ),
        ],
      ),
    );
  }
}

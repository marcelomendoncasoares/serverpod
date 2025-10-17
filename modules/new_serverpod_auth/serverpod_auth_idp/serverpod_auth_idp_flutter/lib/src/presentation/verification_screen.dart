import 'package:flutter/material.dart';

import '../controllers/email_auth_controller.dart';
import '../widgets/buttons/action_button.dart';
import '../widgets/gaps.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/verification_code.dart';

/// Email verification screen widget.
///
/// Displays a verification code input field for users to enter
/// the code received via email during registration.
class VerificationScreen extends StatelessWidget {
  /// The controller that manages authentication state and logic.
  final EmailAuthController controller;

  const VerificationScreen({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Verify Email',
      onBack: () => controller.navigateTo(EmailFlowScreen.register),
      errorMessage: controller.errorMessage,
      pageWidgets: [
        Text(
          'A verification email has been sent. Please check your email and '
          'enter the details below.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        largeGap,
        VerificationCodeInput(
          verificationCodeController: controller.verificationCodeController,
          onCompleted: controller.finishRegistration,
          isLoading: controller.isLoading,
        ),
        largeGap,
        ActionButton(
          onPressed: controller.finishRegistration,
          label: 'Verify',
          isLoading: controller.isLoading,
        ),
      ],
    );
  }
}

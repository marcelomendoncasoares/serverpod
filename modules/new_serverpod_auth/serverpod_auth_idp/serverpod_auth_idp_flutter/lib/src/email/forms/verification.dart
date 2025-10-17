import 'package:flutter/material.dart';

import '../email_auth_controller.dart';
import '../../common/widgets/buttons/action_button.dart';
import '../../common/widgets/gaps.dart';
import '../../common/widgets/verification_code.dart';

/// Email verification screen widget.
///
/// Displays a verification code input field for users to enter
/// the code received via email during registration.
class VerificationForm extends StatelessWidget {
  /// The controller that manages authentication state and logic.
  final EmailAuthController controller;

  const VerificationForm({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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

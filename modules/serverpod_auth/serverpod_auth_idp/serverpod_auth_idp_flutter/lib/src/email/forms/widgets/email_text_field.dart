import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../common/text_formatters.dart';
import '../../../common/widgets/text_field.dart';
import '../../email_auth_controller.dart';

/// A text field for email input.
class EmailTextField extends StatelessWidget {
  /// The controller for the email authentication.
  final EmailAuthController controller;

  /// Optional shared [ValueNotifier] to disable field when any IDP is processing.
  final ValueNotifier<bool>? sharedLoadingNotifier;

  /// Creates a new [EmailTextField] widget.
  const EmailTextField({
    required this.controller,
    this.sharedLoadingNotifier,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = controller.isLoading ||
        (sharedLoadingNotifier?.value ?? false);
    return CustomTextField(
      controller: controller.emailController,
      labelText: 'Email',
      keyboardType: TextInputType.emailAddress,
      isLoading: isLoading,
      errorText: controller.error is InvalidEmailException
          ? controller.errorMessage
          : null,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'[\s()<>[\]\\,;:]')),
        const LetterCaseTextFormatter(letterCase: LetterCase.lowercase),
      ],
    );
  }
}

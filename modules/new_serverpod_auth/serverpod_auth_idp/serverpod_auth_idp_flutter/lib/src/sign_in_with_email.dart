import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:serverpod_auth_idp_flutter/src/theme.dart';

import 'controllers/email_auth_controller.dart';
import 'widgets/buttons/action_button.dart';
import 'widgets/buttons/paste_from_clipboard_button.dart';
import 'widgets/buttons/text_button.dart' as custom;
import 'widgets/gaps.dart';
import 'widgets/page_scaffold.dart';
import 'widgets/password_field.dart';
import 'widgets/text_field.dart';

/// A minimal widget that provides email-based authentication functionality.
///
/// This widget is a thin UI layer over [EmailAuthController]. All business
/// logic, state management, and callbacks are handled by the controller.
///
/// For custom UI implementations, use [EmailAuthController] directly.
///
/// Example usage:
/// ```dart
/// final controller = EmailAuthController(
///   client: client,
///   onAuthenticated: () {
///     // Navigate to home screen
///   },
/// );
///
/// SignInWithEmail(controller: controller)
/// ```
class SignInWithEmail extends StatefulWidget {
  /// The controller that manages authentication state and logic.
  final EmailAuthController controller;

  const SignInWithEmail({super.key, required this.controller});

  @override
  State<SignInWithEmail> createState() => _SignInWithEmailState();
}

class _SignInWithEmailState extends State<SignInWithEmail> {
  EmailAuthController get _controller => widget.controller;

  final focusNode = FocusNode();

  bool get _isLoading => _controller.isLoading;

  String? get _errorMessage => _controller.errorMessage;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerStateChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerStateChanged);
    super.dispose();
  }

  /// Rebuild when controller state changes
  void _onControllerStateChanged() => setState(() {});

  // TODO: Create a base class that requires override of each page build method.
  @override
  Widget build(BuildContext context) {
    return switch (_controller.currentScreen) {
      EmailFlowScreen.login => _buildLoginForm(),
      EmailFlowScreen.register => _buildRegisterForm(),
      EmailFlowScreen.verification => _buildVerificationForm(),
      EmailFlowScreen.passwordReset => _buildPasswordResetRequestForm(),
      EmailFlowScreen.passwordResetVerification => _buildPasswordResetForm(),
    };
  }

  /// The default back-to-sign-in button.
  Widget _createBackToSignInButton() {
    return custom.TextButton(
      onPressed: () => _controller.navigateTo(EmailFlowScreen.login),
      label: 'Back to Sign In',
      isLoading: _isLoading,
    );
  }

  // TODO: Move this to the default widgets.
  /// The default verification code input field from package pinput.
  Widget createVerificationCodeInput({
    VoidCallback? onCompleted,
    int length = 6,
  }) {
    final itemWidth = MediaQuery.of(context).size.width / (length + 3);

    final idpTheme = Theme.of(context).idpTheme;
    final defaultPinTheme = idpTheme.defaultPinTheme.copyWith(width: itemWidth);
    final focusedPinTheme = idpTheme.focusedPinTheme.copyWith(width: itemWidth);
    final errorPinTheme = idpTheme.errorPinTheme.copyWith(width: itemWidth);

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyV):
            const PasteTextIntent(SelectionChangedCause.keyboard),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          PasteTextIntent:
              CallbackAction<PasteTextIntent>(onInvoke: (intent) async {
            final data = await Clipboard.getData('text/plain');
            final text = data?.text;
            if (text != null) {
              setState(() {
                _controller.verificationCodeController.text = text;
              });
            }
            return null;
          }),
        },
        child: Container(
          height: 70,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Pinput(
                controller: _controller.verificationCodeController,
                length: length,
                showCursor: false,
                keyboardType: TextInputType.text,
                autofocus: true,
                enabled: !_isLoading,
                focusNode: focusNode,
                defaultPinTheme: defaultPinTheme,
                onCompleted: onCompleted != null ? (_) => onCompleted() : null,
                focusedPinTheme: focusedPinTheme,
                errorPinTheme: errorPinTheme,
              ),
              const SizedBox(width: 16),
              PasteFromClipboardButton(onPaste: (text) {
                setState(() {
                  _controller.verificationCodeController.text = text;
                });
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return PageScaffold(
      title: 'Sign In',
      onClose: () => Navigator.of(context).pop(),
      errorMessage: _errorMessage,
      pageWidgets: [
        AuthTextField(
          controller: _controller.emailController,
          labelText: 'Email',
          keyboardType: TextInputType.emailAddress,
          isLoading: _isLoading,
        ),
        smallGap,
        PasswordField(
          controller: _controller.passwordController,
          isLoading: _isLoading,
        ),
        largeGap,
        ActionButton(
          onPressed: _controller.login,
          label: 'Sign In',
          isLoading: _isLoading,
        ),
        smallGap,
        custom.TextButton(
          onPressed: () => _controller.navigateTo(EmailFlowScreen.register),
          label: 'Create Account',
          isLoading: _isLoading,
        ),
        smallGap,
        custom.TextButton(
          onPressed: () =>
              _controller.navigateTo(EmailFlowScreen.passwordReset),
          label: 'Forgot Password?',
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return PageScaffold(
      title: 'Register',
      onClose: () => Navigator.of(context).pop(),
      errorMessage: _errorMessage,
      pageWidgets: [
        AuthTextField(
          controller: _controller.emailController,
          labelText: 'Email',
          keyboardType: TextInputType.emailAddress,
          isLoading: _isLoading,
        ),
        smallGap,
        PasswordField(
          controller: _controller.passwordController,
          isLoading: _isLoading,
        ),
        largeGap,
        ActionButton(
          onPressed: _controller.startRegistration,
          label: 'Register',
          isLoading: _isLoading,
        ),
        smallGap,
        _createBackToSignInButton(),
      ],
    );
  }

  Widget _buildVerificationForm() {
    return PageScaffold(
      title: 'Verify Email',
      onClose: () => Navigator.of(context).pop(),
      errorMessage: _errorMessage,
      pageWidgets: [
        Text(
          'A verification email has been sent. Please check your email and '
          'enter the details below.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        largeGap,
        createVerificationCodeInput(
          onCompleted: _controller.finishRegistration,
        ),
        largeGap,
        ActionButton(
          onPressed: _controller.finishRegistration,
          label: 'Verify',
          isLoading: _isLoading,
        ),
        smallGap,
        _createBackToSignInButton(),
      ],
    );
  }

  Widget _buildPasswordResetRequestForm() {
    return PageScaffold(
      title: 'Request Password Reset',
      onClose: () => Navigator.of(context).pop(),
      errorMessage: _errorMessage,
      pageWidgets: [
        Text(
          'Enter the email address to request password reset.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        smallGap,
        AuthTextField(
          controller: _controller.emailController,
          labelText: 'Email',
          keyboardType: TextInputType.emailAddress,
          isLoading: _isLoading,
        ),
        largeGap,
        ActionButton(
          onPressed: _controller.startPasswordReset,
          label: 'Request Password Reset',
          isLoading: _isLoading,
        ),
        smallGap,
        _createBackToSignInButton(),
      ],
    );
  }

  Widget _buildPasswordResetForm() {
    return PageScaffold(
      title: 'Reset Password',
      onClose: () => Navigator.of(context).pop(),
      errorMessage: _errorMessage,
      pageWidgets: [
        Text(
          'A password reset email has been sent. Please check your email and '
          'enter the details below.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        largeGap,
        createVerificationCodeInput(),
        smallGap,
        PasswordField(
          labelText: 'New Password',
          controller: _controller.passwordController,
          isLoading: _isLoading,
        ),
        largeGap,
        ActionButton(
          onPressed: _controller.finishPasswordReset,
          label: 'Reset Password',
          isLoading: _isLoading,
        ),
        smallGap,
        _createBackToSignInButton(),
      ],
    );
  }
}

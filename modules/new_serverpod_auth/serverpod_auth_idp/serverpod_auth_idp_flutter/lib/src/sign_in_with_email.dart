import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:serverpod_auth_idp_flutter/src/theme.dart';

import 'controllers/email_auth_controller.dart';
import 'widgets/base_screen.dart';
import 'widgets/password_field.dart';

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

class _SignInWithEmailState extends State<SignInWithEmail>
    with BaseAuthScreenWidgets {
  EmailAuthController get _controller => widget.controller;

  final focusNode = FocusNode();

  @override
  bool get isLoading => _controller.isLoading;

  @override
  String? get errorMessage => _controller.errorMessage;

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
    return createTextButton(
      onPressed: () => _controller.navigateTo(EmailFlowScreen.login),
      label: 'Back to Sign In',
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
                enabled: !isLoading,
                focusNode: focusNode,
                defaultPinTheme: defaultPinTheme,
                onCompleted: onCompleted != null ? (_) => onCompleted() : null,
                focusedPinTheme: focusedPinTheme,
                errorPinTheme: errorPinTheme,
              ),
              const SizedBox(width: 16),
              createPasteFromClipboardButton(onPaste: (text) {
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
    return createPage(
      title: 'Sign In',
      onClose: () => Navigator.of(context).pop(),
      pageWidgets: [
        createTextField(
          controller: _controller.emailController,
          labelText: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        smallGap,
        PasswordField(
          controller: _controller.passwordController,
          isLoading: isLoading,
        ),
        largeGap,
        createActionButton(
          onPressed: _controller.login,
          label: 'Sign In',
        ),
        smallGap,
        createTextButton(
          onPressed: () => _controller.navigateTo(EmailFlowScreen.register),
          label: 'Create Account',
        ),
        smallGap,
        createTextButton(
          onPressed: () =>
              _controller.navigateTo(EmailFlowScreen.passwordReset),
          label: 'Forgot Password?',
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return createPage(
      title: 'Register',
      onClose: () => Navigator.of(context).pop(),
      pageWidgets: [
        createTextField(
          controller: _controller.emailController,
          labelText: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        smallGap,
        PasswordField(
          controller: _controller.passwordController,
          isLoading: isLoading,
        ),
        largeGap,
        createActionButton(
          onPressed: _controller.startRegistration,
          label: 'Register',
        ),
        smallGap,
        _createBackToSignInButton(),
      ],
    );
  }

  Widget _buildVerificationForm() {
    return createPage(
      title: 'Verify Email',
      onClose: () => Navigator.of(context).pop(),
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
        createActionButton(
          onPressed: _controller.finishRegistration,
          label: 'Verify',
        ),
        smallGap,
        _createBackToSignInButton(),
      ],
    );
  }

  Widget _buildPasswordResetRequestForm() {
    return createPage(
      title: 'Request Password Reset',
      onClose: () => Navigator.of(context).pop(),
      pageWidgets: [
        Text(
          'Enter the email address to request password reset.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        smallGap,
        createTextField(
          controller: _controller.emailController,
          labelText: 'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        largeGap,
        createActionButton(
          onPressed: _controller.startPasswordReset,
          label: 'Request Password Reset',
        ),
        smallGap,
        _createBackToSignInButton(),
      ],
    );
  }

  Widget _buildPasswordResetForm() {
    return createPage(
      title: 'Reset Password',
      onClose: () => Navigator.of(context).pop(),
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
          isLoading: isLoading,
        ),
        largeGap,
        createActionButton(
          onPressed: _controller.finishPasswordReset,
          label: 'Reset Password',
        ),
        smallGap,
        _createBackToSignInButton(),
      ],
    );
  }
}

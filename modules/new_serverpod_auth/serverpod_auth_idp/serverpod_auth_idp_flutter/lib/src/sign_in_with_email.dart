import 'package:flutter/material.dart';

import 'controllers/email_auth_controller.dart';
import 'presentation/login_screen.dart';
import 'presentation/password_reset_request_screen.dart';
import 'presentation/password_reset_screen.dart';
import 'presentation/register_screen.dart';
import 'presentation/verification_screen.dart';

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
class SignInWithEmailWidget extends StatefulWidget {
  /// The controller that manages authentication state and logic.
  final EmailAuthController controller;

  /// Callback that is called when the user presses the back button from the
  /// first screen.
  final VoidCallback? onBack;

  /// Creates the sign-in with email screen widget.
  const SignInWithEmailWidget(
      {super.key, required this.controller, this.onBack});

  @override
  State<SignInWithEmailWidget> createState() => _SignInWithEmailWidgetState();
}

class _SignInWithEmailWidgetState extends State<SignInWithEmailWidget> {
  EmailAuthController get _controller => widget.controller;

  /// The first screen of the email flow.
  late EmailFlowScreen firstScreen;

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

  @override
  Widget build(BuildContext context) {
    return switch (_controller.currentScreen) {
      EmailFlowScreen.login =>
        LoginScreen(controller: _controller, onBack: widget.onBack),
      EmailFlowScreen.register =>
        RegisterScreen(controller: _controller, onBack: widget.onBack),
      EmailFlowScreen.verification =>
        VerificationScreen(controller: _controller),
      EmailFlowScreen.passwordReset =>
        PasswordResetRequestScreen(controller: _controller),
      EmailFlowScreen.passwordResetVerification =>
        PasswordResetScreen(controller: _controller),
    };
  }
}

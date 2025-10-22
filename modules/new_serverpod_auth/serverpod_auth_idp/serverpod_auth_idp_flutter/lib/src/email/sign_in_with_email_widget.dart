import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'email_auth_controller.dart';
import 'forms/login.dart';
import 'forms/password_reset_complete.dart';
import 'forms/password_reset.dart';
import 'forms/register.dart';
import 'forms/verification.dart';

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
    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 600),
      reverse: _controller.currentScreen != _controller.startScreen,
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
      child: _buildScreen(),
    );
  }

  Widget _buildScreen() {
    return switch (_controller.currentScreen) {
      EmailFlowScreen.login =>
        LoginForm(controller: _controller, onBack: widget.onBack),
      EmailFlowScreen.register =>
        RegisterForm(controller: _controller, onBack: widget.onBack),
      EmailFlowScreen.verification => VerificationForm(controller: _controller),
      EmailFlowScreen.passwordReset =>
        PasswordResetForm(controller: _controller),
      EmailFlowScreen.passwordResetVerification =>
        PasswordResetCompleteForm(controller: _controller),
    };
  }
}

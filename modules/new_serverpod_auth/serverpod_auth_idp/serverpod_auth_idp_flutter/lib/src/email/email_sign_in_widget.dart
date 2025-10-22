import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';

import 'email_auth_controller.dart';
import 'forms/login.dart';
import 'forms/password_reset_complete.dart';
import 'forms/password_reset.dart';
import 'forms/register.dart';
import 'forms/verification.dart';

/// A widget that provides email-based authentication functionality.
///
/// The widget can manage its own authentication state, or you can provide an
/// external [controller] for advanced use cases like sharing state across
/// multiple widgets or integrating with state management solutions.
///
/// When [controller] is not provided, you must supply [client] and optionally
/// [startScreen], [onAuthenticated], and [onError] callbacks. When [controller]
/// is provided, those parameters are handled by the controller itself.
///
/// Example with managed state:
/// ```
/// EmailSignInWidget(
///   client: client,
///   onAuthenticated: () => Navigator.push(...),
///   onError: (error) => showSnackBar(...),
/// )
/// ```
///
/// Example with external controller:
/// ```
/// final controller = EmailAuthController(
///   client: client,
///   onAuthenticated: ...,
/// );
///
/// EmailSignInWidget(
///   controller: controller,
/// )
/// ```
class EmailSignInWidget extends StatefulWidget {
  /// Controls the authentication state and behavior.
  ///
  /// If null, the widget creates and manages its own [EmailAuthController].
  /// In this case, [client] must be provided.
  ///
  /// If provided, the widget uses this controller instead of creating one,
  /// and [client], [startScreen], [onAuthenticated], and [onError] are ignored.
  final EmailAuthController? controller;

  /// The Serverpod client instance.
  ///
  /// Required when [controller] is null, ignored otherwise.
  final ServerpodClientShared? client;

  /// The initial screen to display.
  ///
  /// Ignored when [controller] is provided.
  final EmailFlowScreen startScreen;

  /// Callback when authentication is successful.
  ///
  /// Ignored when [controller] is provided.
  final VoidCallback? onAuthenticated;

  /// Callback when an error occurs during authentication.
  ///
  /// Ignored when [controller] is provided.
  final Function(Object error)? onError;

  /// Creates an email sign-in widget.
  const EmailSignInWidget({
    this.controller,
    this.client,
    this.startScreen = EmailFlowScreen.login,
    this.onAuthenticated,
    this.onError,
    super.key,
  }) : assert(
          (controller == null || client == null),
          'Either controller or client must be provided, but not both. When '
          'passing a controller, the client, startScreen, onAuthenticated, and '
          'onError parameters are ignored.',
        );

  @override
  State<EmailSignInWidget> createState() => _EmailSignInWidgetState();
}

class _EmailSignInWidgetState extends State<EmailSignInWidget> {
  late final EmailAuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        EmailAuthController(
          client: widget.client!,
          startScreen: widget.startScreen,
          onAuthenticated: widget.onAuthenticated,
          onError: widget.onError,
        );
    _controller.addListener(_onControllerStateChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerStateChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
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
      EmailFlowScreen.login => LoginForm(controller: _controller),
      EmailFlowScreen.register => RegisterForm(controller: _controller),
      EmailFlowScreen.verification => VerificationForm(controller: _controller),
      EmailFlowScreen.passwordReset =>
        PasswordResetForm(controller: _controller),
      EmailFlowScreen.passwordResetVerification =>
        PasswordResetCompleteForm(controller: _controller),
    };
  }
}

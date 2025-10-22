import 'package:flutter/widgets.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';

import 'email_auth_controller.dart';
import 'email_sign_in_view.dart';
import '../common/widgets/default_scaffold.dart';

class EmailSignInWidget extends StatefulWidget {
  /// The Serverpod client instance.
  final ServerpodClientShared client;

  /// The initial screen to display.
  final EmailFlowScreen startScreen;

  /// Callback when the user cancels the sign-in process.
  /// If null, will not show the back button on the first screen.
  final VoidCallback? onBack;

  /// Callback when authentication is successful.
  final VoidCallback? onAuthenticated;

  /// Callback when an error occurs during authentication.
  final Function(Object error)? onError;

  /// Callback when the controller is created. Useful to register callbacks
  /// to the controller to listen to state changes.
  final Function(EmailAuthController)? onControllerCreated;

  const EmailSignInWidget({
    required this.client,
    this.startScreen = EmailFlowScreen.login,
    this.onBack,
    this.onAuthenticated,
    this.onError,
    this.onControllerCreated,
    super.key,
  });

  @override
  State<EmailSignInWidget> createState() => _EmailSignInWidgetState();
}

class _EmailSignInWidgetState extends State<EmailSignInWidget> {
  late final EmailAuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EmailAuthController(
      client: widget.client,
      startScreen: widget.startScreen,
      onAuthenticated: widget.onAuthenticated,
      onError: widget.onError,
    );
    _controller.addListener(_onControllerStateChanged);

    widget.onControllerCreated?.call(_controller);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerStateChanged);
    _controller.dispose();
    super.dispose();
  }

  /// Rebuild when controller state changes
  void _onControllerStateChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: _controller.currentScreen.pageName,
      onBack: () {
        if (!_controller.navigateBack()) {
          widget.onBack?.call();
        }
      },
      errorMessage: _controller.errorMessage,
      child: EmailSignInView(
        controller: _controller,
        onBack: widget.onBack,
      ),
    );
  }
}

extension on EmailFlowScreen {
  String get pageName => switch (this) {
        EmailFlowScreen.login => 'Login',
        EmailFlowScreen.register => 'Register',
        EmailFlowScreen.verification => 'Verification',
        EmailFlowScreen.passwordReset => 'Request Password Reset',
        EmailFlowScreen.passwordResetVerification => 'Reset Password',
      };
}

import 'package:flutter/widgets.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';

import 'controllers/email_auth_controller.dart';
import 'sign_in_with_email.dart';
import 'widgets/default_scaffold.dart';

class SignInWithEmailPage extends StatefulWidget {
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

  const SignInWithEmailPage({
    required this.client,
    this.startScreen = EmailFlowScreen.login,
    this.onBack,
    this.onAuthenticated,
    this.onError,
    super.key,
  });

  @override
  State<SignInWithEmailPage> createState() => _SignInWithEmailPageState();
}

class _SignInWithEmailPageState extends State<SignInWithEmailPage> {
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
      child: SignInWithEmailWidget(
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

import 'package:flutter/widgets.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';

import 'controllers/email_auth_controller.dart';
import 'sign_in_with_email.dart';

class SignInWithEmailPage extends StatefulWidget {
  /// The Serverpod client instance.
  final ServerpodClientShared client;

  /// The initial screen to display.
  final EmailFlowScreen startScreen;

  /// Callback when authentication is successful.
  final VoidCallback? onAuthenticated;

  /// Callback when an error occurs during authentication.
  final Function(Object error)? onError;

  const SignInWithEmailPage({
    required this.client,
    this.startScreen = EmailFlowScreen.login,
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SignInWithEmail(controller: _controller);
  }
}

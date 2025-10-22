import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';

import '../common/widgets/gaps.dart';
import '../email/email_auth_controller.dart';
import '../email/sign_in_with_email_widget.dart';
import '../google/sign_in_with_google_widget.dart';

/// A widget that provides a complete authentication onboarding experience.
///
/// This widget automatically detects which authentication providers are
/// available on the server by checking for their endpoint implementations,
/// and displays the appropriate sign-in options.
///
/// Currently supports:
/// - Email authentication (via [EndpointAuthEmailBase])
/// - Google Sign-In (via [EndpointGoogleIDPBase])
///
/// The widget separates email authentication from other providers with a
/// visual divider showing "Or continue with" text.
///
/// Example usage:
/// ```dart
/// AuthOnboardingWidget(
///   client: client,
///   onAuthenticated: () {
///     Navigator.of(context).pushReplacement(
///       MaterialPageRoute(builder: (_) => HomePage()),
///     );
///   },
///   onError: (error) {
///     ScaffoldMessenger.of(context).showSnackBar(
///       SnackBar(content: Text('Authentication failed: $error')),
///     );
///   },
/// )
/// ```
class AuthOnboardingWidget extends StatefulWidget {
  /// The Serverpod client instance.
  final ServerpodClientShared client;

  /// Callback when authentication is successful.
  final VoidCallback? onAuthenticated;

  /// Callback when an error occurs during authentication.
  final Function(Object error)? onError;

  /// Callback when the user presses the back button from the first screen.
  final VoidCallback? onBack;

  /// Creates an authentication onboarding widget.
  const AuthOnboardingWidget({
    required this.client,
    this.onAuthenticated,
    this.onError,
    this.onBack,
    super.key,
  });

  @override
  State<AuthOnboardingWidget> createState() => _AuthOnboardingWidgetState();
}

class _AuthOnboardingWidgetState extends State<AuthOnboardingWidget> {
  bool _hasEmailAuth = false;
  bool _hasGoogleAuth = false;
  late EmailAuthController _emailController;

  @override
  void initState() {
    super.initState();
    _checkAvailableProviders();
    _emailController = EmailAuthController(
      client: widget.client,
      onAuthenticated: widget.onAuthenticated,
      onError: widget.onError,
    );
    _emailController.addListener(_onControllerStateChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onControllerStateChanged);
    _emailController.dispose();
    super.dispose();
  }

  void _onControllerStateChanged() {
    setState(() {});
  }

  /// Checks which authentication providers are available on the server.
  void _checkAvailableProviders() {
    try {
      widget.client.getEndpointOfType<EndpointAuthEmailBase>();
      _hasEmailAuth = true;
    } on ServerpodClientEndpointNotFound {
      _hasEmailAuth = false;
    }

    try {
      widget.client.getEndpointOfType<EndpointGoogleIDPBase>();
      _hasGoogleAuth = true;
    } on ServerpodClientEndpointNotFound {
      _hasGoogleAuth = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAnyProvider = _hasEmailAuth || _hasGoogleAuth;

    if (!hasAnyProvider) {
      return Center(
        child: Text(
          'No authentication providers configured',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_hasEmailAuth) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (_emailController.currentScreen != EmailFlowScreen.login &&
                  _emailController.currentScreen != EmailFlowScreen.register)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _emailController.navigateBack,
                ),
              Text(
                'Sign in with email',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
          largeGap,
          SignInWithEmailWidget(
            controller: _emailController,
            onBack: widget.onBack,
          ),
          if (_hasGoogleAuth) ...[
            largeGap,
            _buildDivider(context),
            largeGap,
          ],
        ],
        if (_hasGoogleAuth)
          SignInWithGoogleWidget(
            client: widget.client,
            onAuthenticated: widget.onAuthenticated,
            onError: widget.onError,
          ),
      ],
    );
  }

  /// Builds a divider with "Or continue with" text.
  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
        ),
        Expanded(
          child: Divider(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}

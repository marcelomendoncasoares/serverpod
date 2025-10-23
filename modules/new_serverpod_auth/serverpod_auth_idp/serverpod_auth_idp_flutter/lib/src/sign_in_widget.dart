import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';

import 'common/widgets/gaps.dart';
import 'email/email_sign_in_widget.dart';
import 'google/google_sign_in_widget.dart';

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
/// SignInWidget(
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
class SignInWidget extends StatefulWidget {
  /// The Serverpod client instance.
  final ServerpodClientShared client;

  /// Callback when authentication is successful.
  final VoidCallback? onAuthenticated;

  /// Callback when an error occurs during authentication.
  final Function(Object error)? onError;

  /// Creates an authentication onboarding widget.
  const SignInWidget({
    required this.client,
    this.onAuthenticated,
    this.onError,
    super.key,
  });

  @override
  State<SignInWidget> createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  final Set<IdentityProviders> _availableProviders = {};

  @override
  void initState() {
    super.initState();
    _checkAvailableProviders();
  }

  void _checkAvailableProviders() {
    _isProviderAvailable<EndpointAuthEmailBase>(IdentityProviders.email);
    _isProviderAvailable<EndpointGoogleIDPBase>(IdentityProviders.google);
  }

  @override
  Widget build(BuildContext context) {
    if (_availableProviders.isEmpty) {
      return Center(
        child: Text(
          'No authentication providers configured',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
      );
    }

    // TODO: Make this adaptative.
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_availableProviders.contains(IdentityProviders.email))
              EmailSignInWidget(
                client: widget.client,
                onAuthenticated: widget.onAuthenticated,
                onError: widget.onError,
              ),
            if (_availableProviders.length > 1 &&
                _availableProviders.contains(IdentityProviders.email))
              const _SignInSeparator(),
            if (_availableProviders.contains(IdentityProviders.google))
              GoogleSignInWidget(
                client: widget.client,
                onAuthenticated: widget.onAuthenticated,
                onError: widget.onError,
              ),
            if (_availableProviders.length > 1 &&
                _availableProviders.contains(IdentityProviders.google))
              smallGap,
          ],
        ),
      ),
    );
  }

  void _isProviderAvailable<T extends EndpointRef>(
    IdentityProviders provider,
  ) {
    try {
      widget.client.getEndpointOfType<T>();
      _availableProviders.add(provider);
    } on ServerpodClientEndpointNotFound {
      _availableProviders.remove(provider);
    }
  }
}

// TODO: Make an extension on the ClientAuthSessionManager to expose the check
// of available providers.
enum IdentityProviders {
  email,
  google,
  // TODO: Add Apple IDP to the list of supported providers.
  // apple,
}

class _SignInSeparator extends StatelessWidget {
  const _SignInSeparator();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        largeGap,
        Row(
          children: [
            const _SignInExpandedDivider(),
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
            const _SignInExpandedDivider(),
          ],
        ),
        largeGap,
      ],
    );
  }
}

class _SignInExpandedDivider extends StatelessWidget {
  const _SignInExpandedDivider();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Divider(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
      ),
    );
  }
}

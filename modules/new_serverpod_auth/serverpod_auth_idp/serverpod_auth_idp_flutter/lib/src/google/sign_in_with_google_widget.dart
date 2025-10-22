import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';

import 'sign_in_service.dart';
import 'web/button.dart';

/// A widget that provides Google Sign-In functionality for all platforms.
///
/// This widget handles the complete Google authentication flow:
/// 1. Initiates Google Sign-In using the google_sign_in package
/// 2. Obtains the ID token from Google
/// 3. Sends the ID token to the Serverpod backend via [EndpointGoogleIDPBase]
/// 4. Handles the authentication response
///
/// The widget works across all platforms (Android, iOS, macOS, Web).
///
/// Example usage:
/// ```dart
/// SignInWithGoogleWidget(
///   client: client,
///   onAuthenticated: () {
///     // Navigate to home screen
///   },
///   onError: (error) {
///     // Show error message
///   },
/// )
/// ```
class SignInWithGoogleWidget extends StatefulWidget {
  /// The Serverpod client instance.
  final ServerpodClientShared client;

  /// Callback when authentication is successful.
  final VoidCallback? onAuthenticated;

  /// Callback when an error occurs during authentication.
  final Function(Object error)? onError;

  /// A styled button to use for the web platform.
  final GoogleSignInWebButton? webButton;

  /// Whether to attempt to authenticate the user automatically using the
  /// `attemptLightweightAuthentication` method after the widget is initialized.
  ///
  /// The amount of allowable UI is up to the platform to determine, but it
  /// should be minimal. Possible examples include FedCM on the web, and One Tap
  /// on Android. Platforms may even show no UI, and only sign in if a previous
  /// sign-in is being restored. This method is intended to be called as soon
  /// as the application needs to know if the user is signed in, often at
  /// initial launch.
  final bool attemptLightweightSignIn;

  /// Creates a Google Sign-In widget.
  const SignInWithGoogleWidget({
    required this.client,
    this.onAuthenticated,
    this.onError,
    this.webButton,
    this.attemptLightweightSignIn = true,
    super.key,
  });

  @override
  State<SignInWithGoogleWidget> createState() => _SignInWithGoogleWidgetState();
}

class _SignInWithGoogleWidgetState extends State<SignInWithGoogleWidget> {
  bool _isLoading = false;
  bool _isInitialized = false;
  StreamSubscription<GoogleSignInAuthenticationEvent?>? _authSubscription;

  @override
  void initState() {
    super.initState();

    unawaited(
      GoogleSignInService.instance
          .ensureInitialized(auth: widget.client.auth)
          .then((signIn) {
        _authSubscription = signIn.authenticationEvents.listen(
          _handleAuthenticationEvent,
          onError: _handleAuthenticationError,
        );

        if (widget.attemptLightweightSignIn) {
          unawaited(signIn.attemptLightweightAuthentication());
        }

        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }),
    );
  }

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    super.dispose();
  }

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() {
      _isLoading = value;
    });
  }

  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent googleAuthEvent,
  ) async {
    switch (googleAuthEvent) {
      case GoogleSignInAuthenticationEventSignIn(user: final user):
        await _handleServerSideSignIn(idToken: user.authentication.idToken);
      case GoogleSignInAuthenticationEventSignOut():
        await widget.client.auth.signOutDevice();
    }
  }

  Future<void> _handleAuthenticationError(Object error) async {
    widget.onError?.call(error);
  }

  Future<void> _initiateSignIn() async {
    _setLoading(true);

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw StateError('This sign-in method is not supported on this platform');
    }

    try {
      final account = await GoogleSignIn.instance.authenticate();
      await _handleServerSideSignIn(idToken: account.authentication.idToken);
    } catch (e) {
      _setLoading(false);
      widget.onError?.call(e);
    }
  }

  Future<void> _handleServerSideSignIn({required String? idToken}) async {
    try {
      if (idToken == null) {
        throw GoogleSignInException(
          code: GoogleSignInExceptionCode.unknownError,
          description: 'Failed to obtain ID token from Google',
        );
      }

      final endpoint = widget.client.getEndpointOfType<EndpointGoogleIDPBase>();
      final authSuccess = await endpoint.login(idToken: idToken);

      await widget.client.auth.updateSignedInUser(authSuccess);

      _setLoading(false);
      widget.onAuthenticated?.call();
    } catch (error) {
      _setLoading(false);
      widget.onError?.call(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (GoogleSignIn.instance.supportsAuthenticate())
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _initiateSignIn,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Image.asset(
                    'assets/images/google.png',
                    package: 'serverpod_auth_idp_flutter',
                    height: 24,
                    width: 24,
                  ),
            iconAlignment: IconAlignment.start,
            label: Text(_isLoading ? 'Signing in...' : 'Continue with Google'),
            // NOTE: Styled according to official guidelines.
            // https://developers.google.com/identity/branding-guidelines#padding
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              shape: StadiumBorder(),
            ),
          )
        else if (_isInitialized)
          widget.webButton ?? GoogleSignInWebButton()
      ],
    );
  }
}

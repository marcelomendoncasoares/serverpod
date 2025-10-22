import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';

import 'google_auth_controller.dart';
import 'web/button.dart';

/// A widget that provides Google Sign-In functionality for all platforms.
///
/// This widget is a thin UI layer over [GoogleAuthController]. All business
/// logic, state management, and callbacks are handled by the controller.
///
/// For custom UI implementations, use [GoogleAuthController] directly.
///
/// The widget works across all platforms (Android, iOS, macOS, Web).
///
/// Example usage:
/// ```dart
/// GoogleSignInWidget(
///   client: client,
///   onAuthenticated: () {
///     // Navigate to home screen
///   },
///   onError: (error) {
///     // Show error message
///   },
/// )
/// ```
class GoogleSignInWidget extends StatefulWidget {
  /// The Serverpod client instance.
  final ServerpodClientShared client;

  /// Callback when authentication is successful.
  final VoidCallback? onAuthenticated;

  /// Callback when an error occurs during authentication.
  final Function(Object error)? onError;

  /// Callback when the controller is created. Useful to register callbacks
  /// to the controller to listen to state changes.
  final Function(GoogleAuthController)? onControllerCreated;

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
  const GoogleSignInWidget({
    required this.client,
    this.onAuthenticated,
    this.onError,
    this.onControllerCreated,
    this.webButton,
    this.attemptLightweightSignIn = true,
    super.key,
  });

  @override
  State<GoogleSignInWidget> createState() => _GoogleSignInWidgetState();
}

class _GoogleSignInWidgetState extends State<GoogleSignInWidget> {
  late final GoogleAuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GoogleAuthController(
      client: widget.client,
      onAuthenticated: widget.onAuthenticated,
      onError: widget.onError,
      attemptLightweightSignIn: widget.attemptLightweightSignIn,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (GoogleSignIn.instance.supportsAuthenticate())
          ElevatedButton.icon(
            onPressed: _controller.isLoading ? null : _controller.signIn,
            icon: _controller.isLoading
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
            label: Text(_controller.isLoading
                ? 'Signing in...'
                : 'Continue with Google'),
            // NOTE: Styled according to official guidelines.
            // https://developers.google.com/identity/branding-guidelines#padding
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              shape: StadiumBorder(),
            ),
          )
        else if (_controller.isInitialized)
          widget.webButton ?? GoogleSignInWebButton()
      ],
    );
  }
}

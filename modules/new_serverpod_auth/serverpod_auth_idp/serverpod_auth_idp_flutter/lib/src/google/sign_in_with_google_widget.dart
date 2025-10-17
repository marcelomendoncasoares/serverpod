import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';

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

  /// Optional Google Sign-In configuration.
  /// If not provided, uses default configuration.
  final GoogleSignIn? googleSignIn;

  /// Creates a Google Sign-In widget.
  const SignInWithGoogleWidget({
    required this.client,
    this.onAuthenticated,
    this.onError,
    this.googleSignIn,
    super.key,
  });

  @override
  State<SignInWithGoogleWidget> createState() => _SignInWithGoogleWidgetState();
}

class _SignInWithGoogleWidgetState extends State<SignInWithGoogleWidget> {
  late final GoogleSignIn _googleSignIn;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _googleSignIn = widget.googleSignIn ?? GoogleSignIn.instance;
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final GoogleSignInAccount account = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication auth = account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        throw Exception('Failed to obtain ID token from Google');
      }

      final endpoint = widget.client.getEndpointOfType<EndpointGoogleIDPBase>();
      final authSuccess = await endpoint.login(idToken: idToken);

      await widget.client.auth.updateSignedInUser(authSuccess);

      setState(() {
        _isLoading = false;
      });

      widget.onAuthenticated?.call();
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });

      widget.onError?.call(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _handleSignIn,
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
          label: Text(_isLoading ? 'Signing in...' : 'Sign in with Google'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
          ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

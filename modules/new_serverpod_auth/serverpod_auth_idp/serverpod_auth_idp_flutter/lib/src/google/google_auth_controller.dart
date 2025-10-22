import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';

import 'google_sign_in_service.dart';

/// Controller for managing Google-based authentication flows.
///
/// This controller handles all the business logic for Google authentication,
/// including initialization, sign-in, and authentication event handling.
/// It can be used with any UI implementation.
///
/// Example usage:
/// ```dart
/// final controller = GoogleAuthController(
///   client: client,
///   onAuthenticated: () {
///     // Navigate to home screen
///   },
/// );
///
/// // Initiate sign-in
/// await controller.signIn();
///
/// // Listen to state changes
/// controller.addListener(() {
///   // UI will rebuild automatically
///   // Can use `controller.state` to access the current state.
/// });
/// ```
class GoogleAuthController extends ChangeNotifier {
  /// The Serverpod client instance.
  final ServerpodClientShared client;

  /// Callback when authentication is successful.
  final VoidCallback? onAuthenticated;

  /// Callback when an error occurs during authentication.
  final Function(Object error)? onError;

  /// Whether to attempt to authenticate the user automatically using the
  /// `attemptLightweightAuthentication` method after the controller is
  /// initialized.
  ///
  /// The amount of allowable UI is up to the platform to determine, but it
  /// should be minimal. Possible examples include FedCM on the web, and One Tap
  /// on Android. Platforms may even show no UI, and only sign in if a previous
  /// sign-in is being restored. This method is intended to be called as soon
  /// as the application needs to know if the user is signed in, often at
  /// initial launch.
  final bool attemptLightweightSignIn;

  /// Creates a Google authentication controller.
  GoogleAuthController({
    required this.client,
    this.onAuthenticated,
    this.onError,
    this.attemptLightweightSignIn = true,
  }) {
    unawaited(_initialize());
  }

  GoogleAuthState _state = GoogleAuthState.initializing;

  bool _isInitialized = false;

  StreamSubscription<GoogleSignInAuthenticationEvent?>? _authSubscription;

  /// The current state of the authentication flow.
  GoogleAuthState get state => _state;

  /// Whether the controller is currently processing a request.
  bool get isLoading => _state == GoogleAuthState.loading;

  /// Whether the user is authenticated.
  bool get isAuthenticated => client.auth.isAuthenticated;

  /// Whether the controller has been initialized.
  bool get isInitialized => _isInitialized;

  /// The current error message, if any.
  String? get errorMessage => _error?.toString();

  /// The current error, if any.
  Object? get error => _state == GoogleAuthState.error ? _error : null;
  Object? _error;

  /// Initializes the Google Sign-In service and sets up auth event listeners.
  Future<void> _initialize() async {
    try {
      final signIn = await GoogleSignInService.instance
          .ensureInitialized(auth: client.auth);

      _authSubscription = signIn.authenticationEvents.listen(
        _handleAuthenticationEvent,
        onError: _handleAuthenticationError,
      );

      if (attemptLightweightSignIn) {
        unawaited(signIn.attemptLightweightAuthentication());
      }

      _isInitialized = true;
      _setState(GoogleAuthState.idle);
    } catch (e) {
      _error = e;
      _setState(GoogleAuthState.error);
      onError?.call(e);
    }
  }

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    super.dispose();
  }

  /// Initiates the Google Sign-In flow.
  ///
  /// On success, the authentication event will be handled automatically and the
  /// user will be signed in. On failure, transitions to error state with the
  /// error message.
  Future<void> signIn() async {
    _setState(GoogleAuthState.loading);

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw StateError('This sign-in method is not supported on this platform');
    }

    try {
      final account = await GoogleSignIn.instance.authenticate();
      await _handleServerSideSignIn(idToken: account.authentication.idToken);
    } catch (e) {
      _error = e;
      _setState(GoogleAuthState.error);
      onError?.call(e);
    }
  }

  /// Handles authentication events from the Google Sign-In service.
  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent googleAuthEvent,
  ) async {
    switch (googleAuthEvent) {
      case GoogleSignInAuthenticationEventSignIn(user: final user):
        await _handleServerSideSignIn(idToken: user.authentication.idToken);
      case GoogleSignInAuthenticationEventSignOut():
        await client.auth.signOutDevice();
    }
  }

  /// Handles authentication errors from the Google Sign-In service.
  Future<void> _handleAuthenticationError(Object error) async {
    _error = error;
    _setState(GoogleAuthState.error);
    onError?.call(error);
  }

  /// Handles the server-side sign-in process with the Google ID token.
  Future<void> _handleServerSideSignIn({required String? idToken}) async {
    try {
      if (idToken == null) {
        throw GoogleSignInException(
          code: GoogleSignInExceptionCode.unknownError,
          description: 'Failed to obtain ID token from Google',
        );
      }

      final endpoint = client.getEndpointOfType<EndpointGoogleIDPBase>();
      final authSuccess = await endpoint.login(idToken: idToken);

      await client.auth.updateSignedInUser(authSuccess);

      _setState(GoogleAuthState.authenticated);
      onAuthenticated?.call();
    } catch (error) {
      _error = error;
      _setState(GoogleAuthState.error);
      onError?.call(error);
    }
  }

  /// Sets the current state of the authentication flow and notifies listeners.
  void _setState(GoogleAuthState newState) {
    if (newState != GoogleAuthState.error) _error = null;
    _state = newState;
    notifyListeners();
  }
}

/// Represents the state of the Google authentication flow.
enum GoogleAuthState {
  /// The controller is initializing.
  initializing,

  /// Initial idle state.
  idle,

  /// Loading state while processing any request.
  loading,

  /// A request ended with error. The error can be retrieved from the controller.
  error,

  /// Authentication was successful.
  authenticated,
}

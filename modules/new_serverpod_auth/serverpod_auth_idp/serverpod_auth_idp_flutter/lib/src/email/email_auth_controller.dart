import 'package:flutter/widgets.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';

/// Represents the different screens in the email authentication flow.
enum EmailFlowScreen {
  /// Login screen - user enters email and password to sign in.
  login,

  /// Registration screen - user enters email and password to create account.
  register,

  /// Verification screen - user enters verification code and account request ID.
  verification,

  /// Password reset screen - user enters email to request password reset.
  passwordReset,

  /// Password reset verification screen - user enters verification code and new password.
  passwordResetVerification,
}

/// Controller for managing email-based authentication flows.
///
/// This controller handles all the business logic for email authentication,
/// including login, registration, and email verification. It can be used
/// with any UI implementation.
///
/// Example usage:
/// ```dart
/// final controller = EmailAuthController(
///   client: client,
///   onAuthenticated: () {
///     // Navigate to home screen
///   },
/// );
///
/// // Login
/// await controller.login();
///
/// // Start registration
/// await controller.startRegistration();
///
/// // Finish registration
/// await controller.finishRegistration();
///
/// // Listen to state changes
/// controller.addListener(() {
///   // UI will rebuild automatically
///   // Can use `controller.state` to access the current state.
/// });
/// ```
class EmailAuthController extends ChangeNotifier {
  /// The Serverpod client instance.
  final ServerpodClientShared client;

  /// The screen to display when starting the flow.
  final EmailFlowScreen startScreen;

  /// Callback when authentication is successful.
  final VoidCallback? onAuthenticated;

  /// Callback when an error occurs during authentication.
  final Function(Object error)? onError;

  /// Text controller for email input.
  final emailController = TextEditingController();

  /// Text controller for password input.
  final passwordController = TextEditingController();

  /// Text controller for verification code input.
  final verificationCodeController = TextEditingController();

  /// Creates an email authentication controller.
  EmailAuthController({
    required this.client,
    this.startScreen = EmailFlowScreen.login,
    this.onAuthenticated,
    this.onError,
    // TODO: Add validation hooks.
  }) : assert(
            startScreen == EmailFlowScreen.login ||
                startScreen == EmailFlowScreen.register,
            'Can only start on login or register screen') {
    _currentScreen = startScreen;
  }

  late EmailFlowScreen _currentScreen;

  /// Stores the request ID for the current flow, if any.
  UuidValue? _requestId;

  EmailAuthState _state = EmailAuthState.idle;

  /// The current screen in the authentication flow.
  EmailFlowScreen get currentScreen => _currentScreen;

  /// The current state of the authentication flow.
  EmailAuthState get state => _state;

  /// Navigates to a specific screen in the authentication flow.
  ///
  /// The [requestId] parameter can be used to provide a password reset or
  /// account creation request ID. This is useful when starting the flow from
  /// a deep link or push notification.
  void navigateTo(EmailFlowScreen screen, {UuidValue? requestId}) {
    if (screen == _currentScreen) return;
    if (screen == EmailFlowScreen.passwordReset) passwordController.clear();
    if (screen.hasVerificationCode) verificationCodeController.clear();
    if (requestId != null) _requestId = requestId;

    _currentScreen = screen;
    _setState(switch (screen) {
      EmailFlowScreen.verification => EmailAuthState.verificationPending,
      EmailFlowScreen.passwordResetVerification =>
        EmailAuthState.passwordResetPending,
      _ => EmailAuthState.idle,
    });
  }

  /// Navigates back to the previous screen in the authentication flow.
  ///
  /// Returns `true` if the navigation was successful, and `false` if already on
  /// the start screen and there is no previous screen to navigate back to.
  bool navigateBack() {
    if (currentScreen == startScreen) return false;

    navigateTo(switch (currentScreen) {
      EmailFlowScreen.login => EmailFlowScreen.register,
      EmailFlowScreen.register => EmailFlowScreen.login,
      EmailFlowScreen.verification => EmailFlowScreen.register,
      EmailFlowScreen.passwordReset => EmailFlowScreen.login,
      EmailFlowScreen.passwordResetVerification =>
        EmailFlowScreen.passwordReset,
    });

    return true;
  }

  /// Clears the text controllers and previously set request ID, if not on
  /// a verification code screen. Pass [notify] as `false` if calling before
  /// [navigateTo] to avoid notifying listeners twice.
  void resetState({bool notify = true}) {
    emailController.clear();
    passwordController.clear();
    verificationCodeController.clear();
    _setState(_state, notify: true);
  }

  /// Whether the controller is currently processing a request.
  bool get isLoading => _state == EmailAuthState.loading;

  /// Whether the user is authenticated.
  bool get isAuthenticated => client.auth.isAuthenticated;

  /// The current error message, if any.
  String? get errorMessage => _error?.toString();

  /// The current error, if any.
  Object? get error => _state == EmailAuthState.error ? _error : null;
  Object? _error;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    verificationCodeController.dispose();
    super.dispose();
  }

  /// Gets the email authentication endpoint from the client.
  EndpointAuthEmailBase get _emailEndpoint {
    try {
      return client.getEndpointOfType<EndpointAuthEmailBase>();
    } on ServerpodClientEndpointNotFound catch (_) {
      throw StateError(
        'No email authentication endpoint found. Make sure you have extended '
        '"EndpointAuthEmailBase" in your server and exposed it.',
      );
    }
  }

  /// Logs in a user with email and password from the text controllers.
  ///
  /// On success, updates the session manager and calls [onAuthenticated].
  /// On failure, transitions to error state with the error message.
  Future<void> login() async {
    await _guarded(EmailAuthState.authenticated, () async {
      final authSuccess = await _emailEndpoint.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      await client.auth.updateSignedInUser(authSuccess);
    });
  }

  /// Starts the registration process for a new user.
  ///
  /// Sends a verification email to the email address from the text controller.
  /// On success, transitions to verification screen.
  /// On failure, transitions to error state with the error message.
  Future<void> startRegistration() async {
    await _guarded(EmailAuthState.verificationPending, () async {
      _requestId = await _emailEndpoint.startRegistration(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
    });
  }

  /// Completes the registration process with the verification code.
  ///
  /// On success, updates the session manager and calls [onAuthenticated].
  /// On failure, transitions to error state with the error message.
  Future<void> finishRegistration() async {
    await _guarded(EmailAuthState.authenticated, () async {
      final accountRequestId = _requestId;
      if (accountRequestId == null) {
        throw StateError('No registration request was found to finish.');
      }

      final authSuccess = await _emailEndpoint.finishRegistration(
        accountRequestId: accountRequestId,
        verificationCode: verificationCodeController.text.trim(),
      );

      await client.auth.updateSignedInUser(authSuccess);
    });
  }

  /// Starts the password reset process.
  ///
  /// Sends a password reset email to the provided email address.
  /// On success, transitions to password reset pending state.
  /// On failure, transitions to error state with the error message.
  Future<void> startPasswordReset() async {
    await _guarded(EmailAuthState.passwordResetPending, () async {
      final email = emailController.text.trim();
      _requestId = await _emailEndpoint.startPasswordReset(email: email);
    });
  }

  /// Completes the password reset process with a new password.
  ///
  /// Use the [passwordController] to provide the new password.
  /// On success, updates the session manager and transitions to authenticated state.
  /// On failure, transitions to error state with the error message.
  Future<void> finishPasswordReset() async {
    await _guarded(EmailAuthState.authenticated, () async {
      final passwordResetRequestId = _requestId;
      if (passwordResetRequestId == null) {
        throw StateError('No password reset request was found to finish.');
      }

      final authSuccess = await _emailEndpoint.finishPasswordReset(
        passwordResetRequestId: passwordResetRequestId,
        verificationCode: verificationCodeController.text.trim(),
        newPassword: passwordController.text,
      );

      await client.auth.updateSignedInUser(authSuccess);
    });
  }

  /// Sets the current state of the authentication flow and notifies listeners.
  void _setState(EmailAuthState newState, {bool notify = true}) {
    if (newState != EmailAuthState.error) _error = null;
    if (newState == EmailAuthState.idle) _requestId = null;
    _state = newState;
    if (notify) notifyListeners();
  }

  /// Executes the given action and transitions to the target state on success.
  /// If the target state is authenticated, calls [onAuthenticated] callback.
  /// In case of an error, transitions to error state and calls [onError].
  Future<void> _guarded(
    EmailAuthState targetState,
    Future<void> Function() action,
  ) async {
    _setState(EmailAuthState.loading);
    try {
      await action();
      if (targetState == EmailAuthState.passwordResetPending) {
        navigateTo(EmailFlowScreen.passwordResetVerification);
      } else if (targetState == EmailAuthState.verificationPending) {
        navigateTo(EmailFlowScreen.verification);
      } else {
        _setState(targetState);
        if (targetState == EmailAuthState.authenticated) {
          onAuthenticated?.call();
        }
      }
    } catch (e) {
      _error = e;
      _setState(EmailAuthState.error);
      onError?.call(e);
    }
  }
}

/// Represents the state of the email authentication flow.
enum EmailAuthState {
  /// Initial idle state of each screen.
  idle,

  /// Loading state while processing any request.
  loading,

  /// A request ended with error. The error can be retrieved from the controller.
  error,

  /// Verification code was sent to the user. Should navigate to verification screen.
  verificationPending,

  /// Password reset was sent to the user. Should navigate to password reset verification screen.
  passwordResetPending,

  /// Authentication was successful, either by login, registration, or password reset.
  authenticated,
}

extension on EmailFlowScreen {
  bool get hasVerificationCode =>
      this == EmailFlowScreen.verification ||
      this == EmailFlowScreen.passwordReset;
}

/// Internal protocol between a development server and its local CLI runner.
///
/// These events are transient VM service events, not public endpoint responses
/// or replayable runner history.
library;

/// VM service event carrying a local development email verification code.
const developmentAuthNotificationEvent = 'ext.serverpod.developmentAuth';

/// Per-process capability supplied by the runner, never project configuration.
const developmentNotificationTokenEnv =
    'SERVERPOD_DEVELOPMENT_NOTIFICATION_TOKEN';

/// A verification code eligible for local desktop delivery.
class DevelopmentAuthNotification {
  /// Creates a notification. Receivers must validate untrusted event payloads
  /// with [tryFromJson] before displaying them.
  const DevelopmentAuthNotification({
    required this.token,
    required this.appName,
    required this.email,
    required this.code,
    required this.purpose,
  });

  /// Capability belonging to the current server process.
  final String token;

  /// Project display name.
  final String appName;

  /// Recipient, to distinguish concurrent sign-in attempts.
  final String email;

  /// The normal, short-lived verification code.
  final String code;

  /// Registration, Password reset, or Login.
  final String purpose;

  /// Encodes the transient VM event.
  Map<String, Object?> toJson() => {
    'token': token,
    'appName': appName,
    'email': email,
    'code': code,
    'purpose': purpose,
  };

  /// Rejects malformed or oversized events without throwing.
  static DevelopmentAuthNotification? tryFromJson(Map<String, Object?> json) {
    final token = json['token'];
    final appName = json['appName'];
    final email = json['email'];
    final code = json['code'];
    final purpose = json['purpose'];
    if (token is! String ||
        !isValidToken(token) ||
        appName is! String ||
        !_isText(appName, 64) ||
        email is! String ||
        !_isText(email, 254) ||
        code is! String ||
        !_isText(code, 16) ||
        !RegExp(r'^[a-zA-Z0-9]{1,16}$').hasMatch(code) ||
        purpose is! String ||
        !const ['Registration', 'Password reset', 'Login'].contains(purpose)) {
      return null;
    }
    return DevelopmentAuthNotification(
      token: token,
      appName: appName,
      email: email,
      code: code,
      purpose: purpose,
    );
  }

  /// Whether [token] has the runner's capability format.
  static bool isValidToken(String token) =>
      token.length == 64 && RegExp(r'^[a-f0-9]{64}$').hasMatch(token);

  static bool _isText(String value, int maxLength) =>
      value.trim().isNotEmpty &&
      value.length <= maxLength &&
      !RegExp(r'[\x00-\x1f\x7f]').hasMatch(value);
}

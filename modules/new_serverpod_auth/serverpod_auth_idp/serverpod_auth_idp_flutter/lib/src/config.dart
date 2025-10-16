/// Configuration for the authentication identity provider UI.
class AuthIdpConfig {
  /// The text to display for terms and conditions.
  final String termsText;

  /// The text to display for privacy policy.
  final String privacyText;

  /// Creates a new authentication configuration.
  const AuthIdpConfig({
    required this.termsText,
    required this.privacyText,
  });
}

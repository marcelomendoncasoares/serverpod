// Export utilities to create authentication headers.
export 'package:serverpod_serialization/src/auth_encoding.dart'
    show wrapAsBasicAuthHeaderValue, wrapAsBearerAuthHeaderValue;

/// Provides the authentication key for the client.
abstract interface class ClientAuthKeyProvider {
  /// A valid authentication header value. Should be used for all requests.
  Future<String?> get authHeaderValue;
}

/// Provides the authentication key for the client, with a method to refresh it.
abstract interface class RefresherClientAuthKeyProvider
    implements ClientAuthKeyProvider {
  /// Refreshes the authentication key. If the refresh is successful, should
  /// return true to retry requests that failed due to authentication errors.
  /// Be aware that the refresh endpoint must be annotated with @unauthenticated
  /// to avoid a deadlock on the [authHeaderValue] getter on refresh call.
  Future<bool> refreshAuthKey();
}

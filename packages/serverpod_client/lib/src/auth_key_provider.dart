// Export utilities to create authentication headers.
export 'package:serverpod_serialization/src/auth_encoding.dart'
    show wrapAsBasicAuthHeaderValue, wrapAsBearerAuthHeaderValue;

/// Provides the authentication key for the client.
abstract interface class ClientAuthKeyProvider {
  /// A valid authentication header value. Should be used for all requests.
  Future<String?> get authHeaderValue;
}

// MAYBE: Expose Basic and Bearer header wrap classes here? Then the refresher
// class below uses the Bearer one. This makes 1-1 replacement for the key
// manager previous classes - and is also something users will need anyway.

/// Provides the authentication key for the client, with a method to refresh it.
abstract class RefresherClientAuthKeyProvider implements ClientAuthKeyProvider {
  /// Authentication header value getter that must be implemented. The refresh
  /// logic is handled automatically in the public [authHeaderValue] getter.
  Future<String?> get _authHeaderValue;

  @override
  Future<String?> get authHeaderValue async {
    // TODO: In the beginning of the getter, check validity and refresh if it is
    // about to expire. Either way, before refreshing, check again if it's still
    // about to expire to avoid racing conditions when multiple endpoints try to
    // refresh and one has already refreshed. Then skip refresh and return true.

    // TODO: Use Completer to implement a lock under the future of the getter to
    // avoid multiple concurrent refresh attempts.
    return await _authHeaderValue;
  }

  /// Refreshes the authentication key. If the refresh is successful, should
  /// return true to retry requests that failed due to authentication errors.
  /// Be aware that the refresh endpoint must be annotated with @unauthenticated
  /// to avoid a deadlock on the [authHeaderValue] getter on refresh call.
  Future<bool> refreshAuthKey();
}

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

/// Provides the authentication key for the client, with a method to refresh it
/// and a lock to prevent concurrent refresh calls.
abstract class MutexRefresherClientAuthKeyProvider
    implements RefresherClientAuthKeyProvider {
  /// Authentication header value getter that must be implemented. This getter
  /// must get the header value directly from the source, without any locking.
  /// The [authHeaderValue] getter will handle refreshing the key if needed,
  /// with a lock to avoid concurrent refresh attempts.
  Future<String?> get notMutexLockedAuthHeaderValue;

  /// Returns true if the key should be refreshed. Should signal if the key is
  /// about to expire to automatically refresh before requests failing with 401.
  /// After a successful refresh, should return false until the key is about to
  /// expire again.
  Future<bool> get shouldRefreshKey;

  /// Performs the actual refresh logic. This method should be implemented by
  /// subclasses to handle the specific refresh mechanism (e.g., calling the
  /// refresh endpoint). This method is called by [refreshAuthKey] with proper
  /// locking in place. Be aware that the refresh endpoint must be annotated
  /// with @unauthenticated to avoid a deadlock on the [authHeaderValue] getter.
  Future<bool> performRefresh();

  /// Shared future that serves as a lock to prevent concurrent refresh calls.
  Future<bool>? _pendingRefresh;

  @override
  Future<String?> get authHeaderValue async {
    await refreshAuthKey();
    return notMutexLockedAuthHeaderValue;
  }

  /// Refreshes the authentication key with locking to prevent concurrent calls.
  /// If [force] is false, refresh will only be performed if [shouldRefreshKey]
  /// returns true.
  @override
  Future<bool> refreshAuthKey({bool force = false}) async {
    final shouldRefresh = force ? true : await shouldRefreshKey;
    if (!shouldRefresh) return false;

    final pendingRefresh = _pendingRefresh;
    if (pendingRefresh != null) return pendingRefresh;

    final refreshFuture = performRefresh();
    _pendingRefresh = refreshFuture;

    try {
      return await refreshFuture;
    } finally {
      _pendingRefresh = null;
    }
  }
}

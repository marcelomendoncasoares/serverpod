import 'package:clock/clock.dart';
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';

/// The [JwtAuthKeyProvider] keeps track of and manages the signed-in state of
/// the user for JWT-based authentication. This is the default authentication
/// method for the client.
class JwtAuthKeyProvider extends MutexRefresherClientAuthKeyProvider {
  /// The function to get the authentication info of the user.
  final Future<AuthSuccess?> Function() getAuthInfo;

  /// The function to refresh the authentication info of the user.
  final Future<bool> Function() refreshAuthInfo;

  /// Tolerance to add to the token expiration time before refreshing.
  final Duration refreshJwtTokenBefore;

  /// Creates a new [JwtAuthKeyProvider].
  JwtAuthKeyProvider({
    required this.getAuthInfo,
    required this.refreshAuthInfo,
    this.refreshJwtTokenBefore = const Duration(seconds: 30),
  });

  @override
  Future<String?> get notMutexLockedAuthHeaderValue async {
    final currentAuth = await getAuthInfo();
    if (currentAuth == null) return null;
    return wrapAsBearerAuthHeaderValue(currentAuth.token);
  }

  @override
  Future<bool> get shouldRefreshKey async {
    final currentExpiresAt = (await getAuthInfo())?.tokenExpiresAt;
    return currentExpiresAt?.isExpired(refreshJwtTokenBefore) ?? false;
  }

  @override
  Future<bool> performRefresh() async => refreshAuthInfo();
}

extension on DateTime {
  // Same logic as inside the JWT token handler.
  bool isExpired(Duration tolerance) =>
      isBefore(clock.now().toUtc().subtract(tolerance));
}

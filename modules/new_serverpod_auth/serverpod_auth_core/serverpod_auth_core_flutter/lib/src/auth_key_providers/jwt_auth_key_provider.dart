import 'package:clock/clock.dart';
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';

/// The [JwtAuthKeyProvider] keeps track of and manages the signed-in state of
/// the user for JWT-based authentication. This is the default authentication
/// method for the client.
class JwtAuthKeyProvider extends MutexRefresherClientAuthKeyProvider {
  /// Creates a new [JwtAuthKeyProvider].
  JwtAuthKeyProvider({
    /// The function to get the authentication info of the user.
    required Future<AuthSuccess?> Function() getAuthInfo,

    /// The function to refresh the authentication info of the user.
    required Future<bool> Function() refreshAuthInfo,

    /// Tolerance to add to the token expiration time before refreshing.
    Duration refreshJwtTokenBefore = const Duration(seconds: 30),
  }) : super(
          _JwtAuthKeyProviderDelegate(
            getAuthInfo: getAuthInfo,
            refreshAuthInfo: refreshAuthInfo,
            refreshJwtTokenBefore: refreshJwtTokenBefore,
          ),
        );
}

class _JwtAuthKeyProviderDelegate implements RefresherClientAuthKeyProvider {
  final Future<AuthSuccess?> Function() getAuthInfo;
  final Future<bool> Function() refreshAuthInfo;
  final Duration refreshJwtTokenBefore;

  _JwtAuthKeyProviderDelegate({
    required this.getAuthInfo,
    required this.refreshAuthInfo,
    required this.refreshJwtTokenBefore,
  });

  @override
  Future<String?> get authHeaderValue async {
    final currentAuth = await getAuthInfo();
    if (currentAuth == null) return null;
    return wrapAsBearerAuthHeaderValue(currentAuth.token);
  }

  // TODO: Add a control to only refresh once for a given key if the refresh
  // fails. This will prevent further request from continuously try refresh
  // when the refresh key is invalid. For this to have a good effect, we might
  // first change the bool return of refreshAuthKey to an enum, so we can
  // distinguish between a failed refresh due to network error and a failed
  // refresh due to invalid refresh key.

  /// Only performs a refresh if the token has a valid expiration time and is
  /// about to expire within the configured tolerance. Otherwise, returns false.
  @override
  Future<bool> refreshAuthKey() async {
    final currentExpiresAt = (await getAuthInfo())?.tokenExpiresAt;
    if (currentExpiresAt == null) return false;
    if (!currentExpiresAt.isExpiring(refreshJwtTokenBefore)) return false;
    return refreshAuthInfo();
  }
}

extension on DateTime {
  // Check if the token is about to expire, within the given before duration.
  bool isExpiring(Duration before) =>
      clock.now().toUtc().add(before).isAfter(this);
}

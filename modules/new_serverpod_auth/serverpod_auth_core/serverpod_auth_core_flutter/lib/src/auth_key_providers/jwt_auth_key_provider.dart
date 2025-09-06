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
    required Future<RefreshAuthKeyResult> Function() refreshAuthInfo,

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
  final Future<RefreshAuthKeyResult> Function() refreshAuthInfo;
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

  /// Only performs a refresh if the token has a valid expiration time and is
  /// about to expire within the configured tolerance. Otherwise, returns skipped.
  @override
  Future<RefreshAuthKeyResult> refreshAuthKey() async {
    final currentExpiresAt = (await getAuthInfo())?.tokenExpiresAt;
    if (currentExpiresAt?.isExpiring(refreshJwtTokenBefore) != true) {
      return RefreshAuthKeyResult.skipped;
    }
    return refreshAuthInfo();
  }
}

extension on DateTime {
  // Check if the token is about to expire, within the given before duration.
  bool isExpiring(Duration before) =>
      clock.now().toUtc().add(before).isAfter(this);
}

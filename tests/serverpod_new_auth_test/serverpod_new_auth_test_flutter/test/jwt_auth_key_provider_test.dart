import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';
import 'package:serverpod_new_auth_test_client/serverpod_new_auth_test_client.dart';

void main() {
  late JwtAuthKeyProvider provider;
  late AuthSuccess? storedAuthInfo;
  late TestEndpointRefreshJwtToken refreshEndpoint;
  late AuthSuccess jwtAuthSuccess;
  late RefreshAuthKeyResult result;

  setUp(() async {
    final client = Client('http://localhost:8080/');
    refreshEndpoint = TestEndpointRefreshJwtToken(client);

    provider = JwtAuthKeyProvider(
      getAuthInfo: () async => storedAuthInfo,
      onRefreshAuthInfo: (authSuccess) async {
        storedAuthInfo = authSuccess;
      },
      refreshEndpoint: refreshEndpoint,
      refreshJwtTokenBefore: const Duration(seconds: 30),
    );

    final testUserId = await client.sessionTest.createTestUser();
    jwtAuthSuccess = await client.sessionTest.createJwt(testUserId);

    // Need to wait a second to ensure the next JWT token has a different
    // expiry date. Otherwise it would look equal.
    await Future.delayed(const Duration(milliseconds: 1010));
  });

  group('Given a JwtAuthKeyProvider with no auth info available', () {
    setUp(() {
      storedAuthInfo = null;
    });

    test('when getting auth header value then it returns null.', () async {
      final result = await provider.authHeaderValue;

      expect(result, isNull);
    });

    group('when refreshing auth key', () {
      setUp(() async {
        result = await provider.refreshAuthKey();
      });

      test('then it does not call refresh function.', () async {
        expect(refreshEndpoint.callCount, 0);
      });

      test('then it returns skipped.', () async {
        expect(result, RefreshAuthKeyResult.skipped);
      });

      test('then it does not update auth info.', () async {
        expect(storedAuthInfo, isNull);
      });
    });
  });

  test(
      'Given a JwtAuthKeyProvider with valid auth info available '
      'when getting auth header value '
      'then it returns Bearer token format.', () async {
    storedAuthInfo = jwtAuthSuccess;

    final result = await provider.authHeaderValue;

    expect(result, 'Bearer ${jwtAuthSuccess.token}');
  });

  group(
      'Given a JwtAuthKeyProvider with auth info that has no expiration time '
      'when refreshing auth key ', () {
    setUp(() async {
      storedAuthInfo = jwtAuthSuccess.copyWith()..tokenExpiresAt = null;
      result = await provider.refreshAuthKey();
    });

    test('then it does not call refresh function.', () async {
      expect(refreshEndpoint.callCount, 0);
    });

    test('then it returns skipped as it does not expire.', () async {
      expect(result, RefreshAuthKeyResult.skipped);
    });

    test('then it does not update auth info.', () async {
      expect(storedAuthInfo?.token, jwtAuthSuccess.token);
    });
  });

  group(
      'Given a JwtAuthKeyProvider with auth info that has future expiration time '
      'when refreshing auth key ', () {
    setUp(() async {
      storedAuthInfo = jwtAuthSuccess.copyWith(
        tokenExpiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
      );
      result = await provider.refreshAuthKey();
    });

    test('then it does not call refresh function.', () async {
      expect(refreshEndpoint.callCount, 0);
    });

    test('then it returns skipped as it is not about to expire.', () async {
      expect(result, RefreshAuthKeyResult.skipped);
    });

    test('then it does not update auth info.', () async {
      expect(storedAuthInfo?.token, jwtAuthSuccess.token);
    });
  });

  group(
      'Given a JwtAuthKeyProvider with auth info that is about to expire '
      'when underlying refresh function returns success', () {
    setUp(() async {
      storedAuthInfo = jwtAuthSuccess.copyWith(
        tokenExpiresAt: DateTime.now().toUtc().add(const Duration(seconds: 15)),
      );

      result = await provider.refreshAuthKey();
    });

    test('then it only calls refresh function once.', () async {
      expect(refreshEndpoint.callCount, 1);
    });

    test('then refreshAuthKey returns success.', () async {
      expect(result, RefreshAuthKeyResult.success);
    });

    test('then it rotates the refresh token.', () async {
      expect(storedAuthInfo?.refreshToken, isNotNull);
      expect(storedAuthInfo?.refreshToken, isNot(jwtAuthSuccess.refreshToken));
    });

    test('then it updates auth info.', () async {
      expect(storedAuthInfo?.token, isNotNull);
      expect(storedAuthInfo?.token, isNot(jwtAuthSuccess.token));
    });
  });

  group(
      'Given a JwtAuthKeyProvider with auth info that has a past expiration time '
      'when refreshing auth key', () {
    setUp(() async {
      storedAuthInfo = jwtAuthSuccess.copyWith(
        tokenExpiresAt:
            DateTime.now().toUtc().subtract(const Duration(seconds: 15)),
      );

      result = await provider.refreshAuthKey();
    });

    test('then it calls the refresh function.', () async {
      expect(refreshEndpoint.callCount, 1);
    });

    test('then refreshAuthKey returns success.', () async {
      expect(result, RefreshAuthKeyResult.success);
    });

    test('then it rotates the refresh token.', () async {
      expect(storedAuthInfo?.refreshToken, isNotNull);
      expect(storedAuthInfo?.refreshToken, isNot(jwtAuthSuccess.refreshToken));
    });

    test('then it updates auth info.', () async {
      expect(storedAuthInfo?.token, isNotNull);
      expect(storedAuthInfo?.token, isNot(jwtAuthSuccess.token));
    });
  });
}

// TODO: Add tests for the refresh endpoint exceptions.

class TestEndpointRefreshJwtToken extends EndpointRefreshJwtTokens {
  TestEndpointRefreshJwtToken(super.caller);

  int callCount = 0;

  @override
  Future<AuthSuccess> refreshAccessToken({required String refreshToken}) async {
    callCount++;
    return super.refreshAccessToken(refreshToken: refreshToken);
  }
}

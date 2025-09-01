import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';

void main() {
  late JwtAuthKeyProvider provider;
  late AuthSuccess? getAuthInfoReturn;
  late bool refreshResult;
  late int refreshCallCount;

  setUp(() {
    refreshCallCount = 0;

    provider = JwtAuthKeyProvider(
      getAuthInfo: () async => getAuthInfoReturn,
      refreshAuthInfo: () async {
        refreshCallCount++;
        return refreshResult;
      },
      refreshJwtTokenBefore: const Duration(seconds: 30),
    );
  });

  group('Given a JwtAuthKeyProvider with no auth info available', () {
    setUp(() {
      getAuthInfoReturn = null;
    });

    test('when getting auth header value then it returns null.', () async {
      final result = await provider.authHeaderValue;

      expect(result, isNull);
    });

    group('when refreshing auth key', () {
      late bool result;

      setUp(() async {
        result = await provider.refreshAuthKey();
      });

      test('then it does not call refresh function.', () async {
        expect(refreshCallCount, 0);
      });

      test('then it returns false.', () async {
        expect(result, isFalse);
      });
    });
  });

  test(
      'Given a JwtAuthKeyProvider with valid auth info available '
      'when getting auth header value '
      'then it returns Bearer token format.', () async {
    getAuthInfoReturn = _createAuthSuccess(tokenExpiresAt: null);

    final result = await provider.authHeaderValue;

    expect(result, 'Bearer test-jwt-token');
  });

  group(
      'Given a JwtAuthKeyProvider with auth info that has no expiration time '
      'when refreshing auth key ', () {
    late bool result;

    setUp(() async {
      getAuthInfoReturn = _createAuthSuccess(tokenExpiresAt: null);
      result = await provider.refreshAuthKey();
    });

    test('then it does not call refresh function.', () async {
      expect(refreshCallCount, 0);
    });

    test('then it returns false as it does not expire.', () async {
      expect(result, isFalse);
    });
  });

  group(
      'Given a JwtAuthKeyProvider with auth info that has future expiration time '
      'when refreshing auth key ', () {
    late bool result;

    setUp(() async {
      getAuthInfoReturn = _createAuthSuccess(
        tokenExpiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
      );
      result = await provider.refreshAuthKey();
    });

    test('then it does not call refresh function.', () async {
      expect(refreshCallCount, 0);
    });

    test('then it returns false as it is not about to expire.', () async {
      expect(result, isFalse);
    });
  });

  group('Given a JwtAuthKeyProvider with auth info that is about to expire',
      () {
    late bool result;

    setUp(() {
      getAuthInfoReturn = _createAuthSuccess(
        tokenExpiresAt: DateTime.now().toUtc().add(const Duration(seconds: 15)),
      );
    });

    group('when underlying refresh function returns false', () {
      setUp(() async {
        refreshResult = false;
        result = await provider.refreshAuthKey();
      });

      test('then it only calls refresh function once.', () async {
        expect(refreshCallCount, 1);
      });

      test('then refreshAuthKey also returns false.', () async {
        expect(result, isFalse);
      });
    });

    group('when underlying refresh function returns true', () {
      setUp(() async {
        refreshResult = true;
        result = await provider.refreshAuthKey();
      });

      test('then it only calls refresh function once.', () async {
        expect(refreshCallCount, 1);
      });

      test('then refreshAuthKey also returns true.', () async {
        expect(result, isTrue);
      });
    });
  });

  test(
      'Given a JwtAuthKeyProvider with auth info that has a past expiration time '
      'when refreshing auth key '
      'then it calls the refresh function.', () async {
    getAuthInfoReturn = _createAuthSuccess(
      tokenExpiresAt:
          DateTime.now().toUtc().subtract(const Duration(seconds: 15)),
    );

    await provider.refreshAuthKey();

    expect(refreshCallCount, 1);
  });
}

AuthSuccess _createAuthSuccess({required DateTime? tokenExpiresAt}) {
  return AuthSuccess(
    authStrategy: AuthStrategy.jwt,
    token: 'test-jwt-token',
    tokenExpiresAt: tokenExpiresAt,
    authUserId: UuidValue.fromString('550e8400-e29b-41d4-a716-446655440000'),
    scopeNames: {'test'},
  );
}

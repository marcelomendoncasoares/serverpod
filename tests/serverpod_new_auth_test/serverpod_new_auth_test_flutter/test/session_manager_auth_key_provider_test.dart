import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';
import 'package:serverpod_new_auth_test_client/serverpod_new_auth_test_client.dart';

import 'utils/test_storage.dart';

void main() {
  late Client client;

  setUp(() {
    client = Client('http://localhost:8080/')
      ..authSessionManager = ClientAuthSessionManager(storage: TestStorage());
  });

  group('Given a ClientAuthSessionManager with no auth info available', () {
    test('when getting auth key provider delegate then it returns null.', () {
      final delegate = client.auth.authKeyProviderDelegate;

      expect(delegate, isNull);
    });

    test('when getting auth header value then it returns null.', () async {
      final result = await client.auth.authHeaderValue;

      expect(result, isNull);
    });

    test('when refreshing auth key then it returns false.', () async {
      final result = await client.auth.refreshAuthKey();

      expect(result, isFalse);
    });
  });

  group('Given a ClientAuthSessionManager with JWT auth info available', () {
    setUp(() async {
      await client.auth.updateSignedInUser(_jwtAuthSuccess);
    });

    test(
        'when getting auth key provider delegate '
        'then it returns JwtAuthKeyProvider.', () async {
      final delegate = client.auth.authKeyProviderDelegate;

      expect(delegate, isA<JwtAuthKeyProvider>());
    });

    test(
        'when getting auth key provider delegate multiple times '
        'then the same JwtAuthKeyProvider instance is returned.', () async {
      final delegate1 = client.auth.authKeyProviderDelegate;
      final delegate2 = client.auth.authKeyProviderDelegate;

      expect(identical(delegate1, delegate2), isTrue);
    });

    test(
        'when getting auth header value '
        'then it returns Bearer token from JWT provider.', () async {
      final result = await client.auth.authHeaderValue;

      expect(result, 'Bearer jwt-token');
    });

    test(
        'when refreshing auth key '
        'then it delegates to JWT provider and returns true.', () async {
      final result = await client.auth.refreshAuthKey();

      expect(result, isTrue);
    });
  });

  group('Given a ClientAuthSessionManager with session auth info available', () {
    setUp(() async {
      await client.auth.updateSignedInUser(_sessionAuthSuccess);
    });

    test(
        'when getting auth key provider delegate '
        'then it returns SasAuthKeyProvider.', () async {
      final delegate = client.auth.authKeyProviderDelegate;

      expect(delegate, isA<SasAuthKeyProvider>());
    });

    test(
        'when getting auth key provider delegate multiple times '
        'then the same SasAuthKeyProvider instance is returned.', () async {
      final delegate1 = client.auth.authKeyProviderDelegate;
      final delegate2 = client.auth.authKeyProviderDelegate;

      expect(identical(delegate1, delegate2), isTrue);
    });

    test(
        'when getting auth header value '
        'then it returns Bearer token from session provider.', () async {
      final result = await client.auth.authHeaderValue;

      expect(result, 'Bearer session-token');
    });

    test(
        'when refreshing auth key '
        'then it returns false as session provider does not support refresh.',
        () async {
      final result = await client.auth.refreshAuthKey();

      expect(result, isFalse);
    });
  });

  group('Given auth strategy changes between JWT and session', () {
    test(
        'when getting auth key provider delegate '
        'then each auth strategy gets its own provider instance.', () async {
      await client.auth.updateSignedInUser(_jwtAuthSuccess);
      final jwtDelegate = client.auth.authKeyProviderDelegate;

      await client.auth.updateSignedInUser(_sessionAuthSuccess);
      final sessionDelegate = client.auth.authKeyProviderDelegate;

      expect(jwtDelegate, isA<JwtAuthKeyProvider>());
      expect(sessionDelegate, isA<SasAuthKeyProvider>());
    });

    test(
        'when getting auth key provider delegate multiple times '
        'then the same provider instance for each auth strategy is returned.',
        () async {
      await client.auth.updateSignedInUser(_jwtAuthSuccess);
      final jwtDelegate = client.auth.authKeyProviderDelegate;

      await client.auth.updateSignedInUser(_sessionAuthSuccess);
      final sessionDelegate = client.auth.authKeyProviderDelegate;

      await client.auth.updateSignedInUser(_jwtAuthSuccess);
      final jwtDelegate2 = client.auth.authKeyProviderDelegate;

      await client.auth.updateSignedInUser(_sessionAuthSuccess);
      final sessionDelegate2 = client.auth.authKeyProviderDelegate;

      expect(identical(jwtDelegate, jwtDelegate2), isTrue);
      expect(identical(sessionDelegate, sessionDelegate2), isTrue);
    });
  });

  group('Given a ClientAuthSessionManager with custom provider delegates', () {
    final customJwtProvider = JwtAuthKeyProvider(
      getAuthInfo: () async => _jwtAuthSuccess,
      refreshAuthInfo: () async => true,
    );

    final customSessionProvider = SasAuthKeyProvider(
      getAuthInfo: () async => _sessionAuthSuccess,
    );

    setUp(() {
      client.authSessionManager = ClientAuthSessionManager(
        storage: TestStorage(),
        authKeyProviderDelegates: {
          AuthStrategy.jwt: customJwtProvider,
          AuthStrategy.session: customSessionProvider,
        },
      );
    });

    test(
        'when getting auth key provider delegate for JWT auth info '
        'then it returns the custom provider instance.', () async {
      await client.auth.updateSignedInUser(_jwtAuthSuccess);
      final delegate = client.auth.authKeyProviderDelegate;

      expect(identical(delegate, customJwtProvider), isTrue);
    });

    test(
        'when getting auth key provider delegate for session auth info '
        'then it returns the custom provider instance.', () async {
      await client.auth.updateSignedInUser(_sessionAuthSuccess);
      final delegate = client.auth.authKeyProviderDelegate;

      expect(identical(delegate, customSessionProvider), isTrue);
    });
  });
}

final _jwtAuthSuccess = AuthSuccess(
  authStrategy: AuthStrategy.jwt,
  token: 'jwt-token',
  tokenExpiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
  authUserId: UuidValue.fromString('550e8400-e29b-41d4-a716-446655440000'),
  scopeNames: {'test'},
);

final _sessionAuthSuccess = AuthSuccess(
  authStrategy: AuthStrategy.session,
  token: 'session-token',
  authUserId: UuidValue.fromString('550e8400-e29b-41d4-a716-446655440000'),
  scopeNames: {'test'},
);

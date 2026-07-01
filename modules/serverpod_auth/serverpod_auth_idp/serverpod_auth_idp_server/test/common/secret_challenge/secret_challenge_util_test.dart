import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import '../../test_tags.dart';
import '../../test_tools/serverpod_test_tools.dart';

const _verificationCode = '123456';

void main() {
  withServerpod(
    'Given SecretChallengeUtil, ',
    rollbackDatabase: RollbackDatabase.disabled,
    testGroupTagsOverride: TestTags.concurrencyOneTestTags,
    (final sessionBuilder, final endpoints) {
      late Session session;
      late Argon2HashUtil hashUtil;
      late SecretChallengeUtil<_TestChallengeRequest> challengeUtil;
      late Map<String, _TestChallengeRequest> requests;
      late List<UuidValue> expiredRequestIds;
      late _FakeRateLimitedRequestAttemptUtil<UuidValue>
      verificationRateLimiter;
      late _FakeRateLimitedRequestAttemptUtil<UuidValue> completionRateLimiter;

      setUp(() async {
        session = sessionBuilder.build();
        hashUtil = _createTestHashUtil();
        requests = {};
        expiredRequestIds = [];
        verificationRateLimiter = _FakeRateLimitedRequestAttemptUtil();
        completionRateLimiter = _FakeRateLimitedRequestAttemptUtil();

        challengeUtil = SecretChallengeUtil<_TestChallengeRequest>(
          hashUtil: hashUtil,
          verificationConfig: SecretChallengeVerificationConfig(
            getRequest:
                (
                  final session,
                  final requestId, {
                  required final Transaction? transaction,
                }) async {
                  return requests[requestId.uuid];
                },
            isAlreadyUsed: (final request) => request.isAlreadyUsed,
            getChallenge: (final request) => request.verificationChallenge,
            isExpired: (final request) => request.expiresAt.isBefore(
              DateTime.now(),
            ),
            onExpired: (final session, final request) async {
              expiredRequestIds.add(request.id);
            },
            linkCompletionToken:
                (
                  final session,
                  final request,
                  final completionChallenge, {
                  required final Transaction? transaction,
                }) async {
                  request.completionChallenge = completionChallenge;
                },
            rateLimiter: verificationRateLimiter,
          ),
          completionConfig: SecretChallengeCompletionConfig(
            getRequest:
                (
                  final session,
                  final requestId, {
                  required final Transaction? transaction,
                }) async {
                  return requests[requestId.uuid];
                },
            getCompletionChallenge: (final request) {
              return request.completionChallenge;
            },
            isExpired: (final request) => request.expiresAt.isBefore(
              DateTime.now(),
            ),
            onExpired: (final session, final request) async {
              expiredRequestIds.add(request.id);
            },
            rateLimiter: completionRateLimiter,
          ),
        );

        await _deleteSecretChallenges(session);
      });

      tearDown(() async {
        await _deleteSecretChallenges(session);
      });

      Future<_TestChallengeRequest> createRequest({
        final String verificationCode = _verificationCode,
        final Duration lifetime = const Duration(hours: 1),
        final bool isAlreadyUsed = false,
      }) async {
        final verificationChallenge = await session.db.transaction(
          (final transaction) => challengeUtil.createChallenge(
            session,
            verificationCode: verificationCode,
            transaction: transaction,
          ),
        );
        final request = _TestChallengeRequest(
          id: const Uuid().v4obj(),
          verificationChallenge: verificationChallenge,
          expiresAt: DateTime.now().add(lifetime),
          isAlreadyUsed: isAlreadyUsed,
        );

        requests[request.id.uuid] = request;

        return request;
      }

      test(
        'when creating a challenge, '
        'then it stores a hash that validates the verification code.',
        () async {
          final challenge = await session.db.transaction(
            (final transaction) => challengeUtil.createChallenge(
              session,
              verificationCode: _verificationCode,
              transaction: transaction,
            ),
          );

          final verificationCodeMatchesHash = await hashUtil
              .validateHashFromString(
                secret: _verificationCode,
                hashString: challenge.challengeCodeHash,
              );

          expect(challenge.id, isNotNull);
          expect(challenge.challengeCodeHash, isNot(_verificationCode));
          expect(verificationCodeMatchesHash, isTrue);
        },
      );

      test(
        'when verifying a request and completing it with the returned token, '
        'then the request is returned.',
        () async {
          final request = await createRequest();

          final completionToken = await session.db.transaction(
            (final transaction) => challengeUtil.verifyChallenge(
              session,
              requestId: request.id,
              verificationCode: _verificationCode,
              transaction: transaction,
            ),
          );

          final result = session.db.transaction(
            (final transaction) => challengeUtil.completeChallenge(
              session,
              completionToken: completionToken,
              transaction: transaction,
            ),
          );

          expect(request.completionChallenge, isNotNull);
          await expectLater(result, completion(same(request)));
        },
      );

      test(
        'when verifying a request with an invalid verification code, '
        'then it throws an invalid verification code exception.',
        () async {
          final request = await createRequest();

          final result = session.db.transaction(
            (final transaction) => challengeUtil.verifyChallenge(
              session,
              requestId: request.id,
              verificationCode: 'invalid-code',
              transaction: transaction,
            ),
          );

          await expectLater(
            result,
            throwsA(isA<ChallengeInvalidVerificationCodeException>()),
          );
          expect(request.completionChallenge, isNull);
        },
      );

      test(
        'when verifying an expired request with a valid verification code, '
        'then it records the expiration and throws an expired exception.',
        () async {
          final request = await createRequest(
            lifetime: const Duration(minutes: -1),
          );

          final result = session.db.transaction(
            (final transaction) => challengeUtil.verifyChallenge(
              session,
              requestId: request.id,
              verificationCode: _verificationCode,
              transaction: transaction,
            ),
          );

          await expectLater(
            result,
            throwsA(isA<ChallengeExpiredException>()),
          );
          expect(expiredRequestIds, [request.id]);
          expect(request.completionChallenge, isNull);
        },
      );

      test(
        'when verifying an already used request, '
        'then it throws an already used exception.',
        () async {
          final request = await createRequest(isAlreadyUsed: true);

          final result = session.db.transaction(
            (final transaction) => challengeUtil.verifyChallenge(
              session,
              requestId: request.id,
              verificationCode: _verificationCode,
              transaction: transaction,
            ),
          );

          await expectLater(
            result,
            throwsA(isA<ChallengeAlreadyUsedException>()),
          );
        },
      );

      test(
        'when verifying an unknown request, '
        'then it throws a request not found exception.',
        () async {
          final result = session.db.transaction(
            (final transaction) => challengeUtil.verifyChallenge(
              session,
              requestId: const Uuid().v4obj(),
              verificationCode: _verificationCode,
              transaction: transaction,
            ),
          );

          await expectLater(
            result,
            throwsA(isA<ChallengeRequestNotFoundException>()),
          );
        },
      );

      test(
        'when verifying a request after the rate limit is exceeded, '
        'then it throws a rate limit exception.',
        () async {
          final request = await createRequest();
          verificationRateLimiter.hasTooManyAttemptsResult = true;

          final result = session.db.transaction(
            (final transaction) => challengeUtil.verifyChallenge(
              session,
              requestId: request.id,
              verificationCode: _verificationCode,
              transaction: transaction,
            ),
          );

          await expectLater(
            result,
            throwsA(isA<ChallengeRateLimitExceededException>()),
          );
          expect(verificationRateLimiter.nonces, [request.id]);
        },
      );

      test(
        'when completing a request with an invalid token, '
        'then it throws an invalid completion token exception.',
        () async {
          final result = session.db.transaction(
            (final transaction) => challengeUtil.completeChallenge(
              session,
              completionToken: 'not-base64',
              transaction: transaction,
            ),
          );

          await expectLater(
            result,
            throwsA(isA<ChallengeInvalidCompletionTokenException>()),
          );
        },
      );

      test(
        'when completing a request before it has been verified, '
        'then it throws a not verified exception.',
        () async {
          final request = await createRequest();

          final result = session.db.transaction(
            (final transaction) => challengeUtil.completeChallenge(
              session,
              completionToken: _completionTokenFor(
                request.id,
                verificationCode: 'unlinked-token',
              ),
              transaction: transaction,
            ),
          );

          await expectLater(
            result,
            throwsA(isA<ChallengeNotVerifiedException>()),
          );
        },
      );

      test(
        'when completing a verified request with a different token, '
        'then it throws an invalid verification code exception.',
        () async {
          final request = await createRequest();

          await session.db.transaction(
            (final transaction) => challengeUtil.verifyChallenge(
              session,
              requestId: request.id,
              verificationCode: _verificationCode,
              transaction: transaction,
            ),
          );

          final result = session.db.transaction(
            (final transaction) => challengeUtil.completeChallenge(
              session,
              completionToken: _completionTokenFor(
                request.id,
                verificationCode: 'different-token',
              ),
              transaction: transaction,
            ),
          );

          await expectLater(
            result,
            throwsA(isA<ChallengeInvalidVerificationCodeException>()),
          );
        },
      );

      test(
        'when completing an expired verified request, '
        'then it records the expiration and throws an expired exception.',
        () async {
          final request = await createRequest();

          final completionToken = await session.db.transaction(
            (final transaction) => challengeUtil.verifyChallenge(
              session,
              requestId: request.id,
              verificationCode: _verificationCode,
              transaction: transaction,
            ),
          );
          request.expiresAt = DateTime.now().subtract(
            const Duration(minutes: 1),
          );

          final result = session.db.transaction(
            (final transaction) => challengeUtil.completeChallenge(
              session,
              completionToken: completionToken,
              transaction: transaction,
            ),
          );

          await expectLater(
            result,
            throwsA(isA<ChallengeExpiredException>()),
          );
          expect(expiredRequestIds, [request.id]);
        },
      );

      test(
        'when completing a request after the rate limit is exceeded, '
        'then it throws a rate limit exception.',
        () async {
          final request = await createRequest();

          final completionToken = await session.db.transaction(
            (final transaction) => challengeUtil.verifyChallenge(
              session,
              requestId: request.id,
              verificationCode: _verificationCode,
              transaction: transaction,
            ),
          );
          completionRateLimiter.hasTooManyAttemptsResult = true;

          final result = session.db.transaction(
            (final transaction) => challengeUtil.completeChallenge(
              session,
              completionToken: completionToken,
              transaction: transaction,
            ),
          );

          await expectLater(
            result,
            throwsA(isA<ChallengeRateLimitExceededException>()),
          );
          expect(completionRateLimiter.nonces, [request.id]);
        },
      );
    },
  );
}

Argon2HashUtil _createTestHashUtil() {
  return Argon2HashUtil(
    hashPepper: 'test-pepper',
    hashSaltLength: 8,
    parameters: Argon2HashParameters(
      memory: 32,
      iterations: 1,
      lanes: 1,
      desiredKeyLength: 16,
    ),
  );
}

Future<void> _deleteSecretChallenges(final Session session) async {
  await SecretChallenge.db.deleteWhere(
    session,
    where: (final _) => Constant.bool(true),
  );
}

String _completionTokenFor(
  final UuidValue requestId, {
  required final String verificationCode,
}) {
  return base64Encode(utf8.encode('$requestId:$verificationCode'));
}

final class _TestChallengeRequest {
  _TestChallengeRequest({
    required this.id,
    required this.verificationChallenge,
    required this.expiresAt,
    required this.isAlreadyUsed,
  });

  final UuidValue id;
  final SecretChallenge verificationChallenge;
  DateTime expiresAt;
  final bool isAlreadyUsed;
  SecretChallenge? completionChallenge;
}

final class _FakeRateLimitedRequestAttemptUtil<T>
    extends RateLimitedRequestAttemptUtil<T> {
  _FakeRateLimitedRequestAttemptUtil()
    : super(
        RateLimitedRequestAttemptConfig<T>(
          domain: 'secret_challenge_util_test',
          source: 'fake',
          maxAttempts: 1,
          nonceToString: (final nonce) => nonce.toString(),
          nonceFromString: (final nonce) {
            throw UnsupportedError(
              'The fake rate limiter never decodes nonce.',
            );
          },
        ),
      );

  bool hasTooManyAttemptsResult = false;
  final List<T> nonces = [];

  @override
  Future<bool> hasTooManyAttempts(
    final Session session, {
    required final T nonce,
    final Map<String, String>? extraData,
  }) async {
    nonces.add(nonce);

    return hasTooManyAttemptsResult;
  }

  @override
  Future<void> recordAttempt(
    final Session session, {
    required final T nonce,
    final Map<String, String>? extraData,
  }) async {}

  @override
  Future<int> countAttempts(
    final Session session, {
    required final T nonce,
  }) async {
    return nonces.where((final recordedNonce) => recordedNonce == nonce).length;
  }

  @override
  Future<void> deleteAttempts(
    final Session session, {
    required final T nonce,
    final Duration? olderThan,
  }) async {}
}

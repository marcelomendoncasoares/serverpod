import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import '../../test_tags.dart';
import '../../test_tools/serverpod_test_tools.dart';

const _testDomain = 'rate_limit_util_test';

void main() {
  withServerpod(
    'Given DatabaseRateLimitedRequestAttemptUtil, ',
    rollbackDatabase: RollbackDatabase.disabled,
    testGroupTagsOverride: TestTags.concurrencyOneTestTags,
    (final sessionBuilder, final endpoints) {
      late Session session;
      late DatabaseRateLimitedRequestAttemptUtil<String> rateLimitUtil;
      late List<String> rateLimitExceededNonces;

      setUp(() async {
        session = sessionBuilder.build();
        rateLimitExceededNonces = [];
        rateLimitUtil = DatabaseRateLimitedRequestAttemptUtil<String>(
          RateLimitedRequestAttemptConfig<String>(
            domain: _testDomain,
            source: 'verification',
            defaultExtraData: const {
              'client': 'mobile',
              'shared': 'default',
            },
            maxAttempts: 2,
            timeframe: const Duration(hours: 1),
            onRateLimitExceeded: (final session, final nonce) async {
              rateLimitExceededNonces.add(nonce);
            },
          ),
        );

        await _deleteRateLimitAttempts(session);
      });

      tearDown(() async {
        await _deleteRateLimitAttempts(session);
      });

      test(
        'when recording an attempt with extra data, '
        'then it stores the attempt with merged metadata.',
        () async {
          await rateLimitUtil.recordAttempt(
            session,
            nonce: 'request-a',
            extraData: const {
              'requestId': '123',
              'shared': 'request',
            },
          );

          final attempts = await _findAttempts(
            session,
            source: 'verification',
            nonce: 'request-a',
          );

          expect(attempts, hasLength(1));
          expect(attempts.single.domain, _testDomain);
          expect(attempts.single.source, 'verification');
          expect(attempts.single.nonce, 'request-a');
          expect(attempts.single.extraData, {
            'client': 'mobile',
            'shared': 'request',
            'requestId': '123',
          });
        },
      );

      test(
        'when checking attempts up to the configured maximum, '
        'then it allows the maximum attempts and rate limits the following attempt.',
        () async {
          final firstAttemptLimited = await rateLimitUtil.hasTooManyAttempts(
            session,
            nonce: 'request-b',
          );
          final secondAttemptLimited = await rateLimitUtil.hasTooManyAttempts(
            session,
            nonce: 'request-b',
          );
          final thirdAttemptLimited = await rateLimitUtil.hasTooManyAttempts(
            session,
            nonce: 'request-b',
          );

          final attemptCount = await rateLimitUtil.countAttempts(
            session,
            nonce: 'request-b',
          );

          expect(firstAttemptLimited, isFalse);
          expect(secondAttemptLimited, isFalse);
          expect(thirdAttemptLimited, isTrue);
          expect(rateLimitExceededNonces, ['request-b']);
          expect(attemptCount, 2);
        },
      );

      test(
        'when a caller transaction rolls back after checking the rate limit, '
        'then the recorded attempt remains counted.',
        () async {
          final result = session.db.transaction((final transaction) async {
            await rateLimitUtil.hasTooManyAttempts(
              session,
              nonce: 'request-c',
            );

            throw _ExpectedRollbackException();
          });

          await expectLater(
            result,
            throwsA(isA<_ExpectedRollbackException>()),
          );

          final attemptCount = await rateLimitUtil.countAttempts(
            session,
            nonce: 'request-c',
          );

          expect(attemptCount, 1);
        },
      );

      test(
        'when counting attempts with a timeframe, '
        'then it only counts attempts inside the timeframe.',
        () async {
          final now = DateTime.utc(2026, 1, 1, 12);

          await withClock(
            Clock.fixed(now.subtract(const Duration(hours: 2))),
            () => rateLimitUtil.recordAttempt(
              session,
              nonce: 'request-d',
            ),
          );

          await withClock(Clock.fixed(now), () async {
            await rateLimitUtil.recordAttempt(
              session,
              nonce: 'request-d',
            );

            final attemptCount = await rateLimitUtil.countAttempts(
              session,
              nonce: 'request-d',
            );

            expect(attemptCount, 1);
          });
        },
      );

      test(
        'when deleting attempts for one nonce older than a duration, '
        'then it keeps newer attempts and attempts for other nonces.',
        () async {
          final now = DateTime.utc(2026, 1, 1, 12);

          await withClock(
            Clock.fixed(now.subtract(const Duration(hours: 2))),
            () async {
              await rateLimitUtil.recordAttempt(
                session,
                nonce: 'request-e',
              );
              await rateLimitUtil.recordAttempt(
                session,
                nonce: 'other-request',
              );
            },
          );

          await withClock(Clock.fixed(now), () async {
            await rateLimitUtil.recordAttempt(
              session,
              nonce: 'request-e',
            );

            final deletedAttempts = await rateLimitUtil.deleteAttempts(
              session,
              nonce: 'request-e',
              olderThan: const Duration(hours: 1),
            );

            expect(deletedAttempts, 1);
          });

          final targetAttempts = await _findAttempts(
            session,
            source: 'verification',
            nonce: 'request-e',
          );
          final otherAttempts = await _findAttempts(
            session,
            source: 'verification',
            nonce: 'other-request',
          );

          expect(targetAttempts, hasLength(1));
          expect(otherAttempts, hasLength(1));
        },
      );

      test(
        'when recording an attempt with a typed UUID nonce, '
        'then it counts the attempt by the typed nonce.',
        () async {
          final uuidNonce = const Uuid().v4obj();
          final uuidRateLimitUtil =
              DatabaseRateLimitedRequestAttemptUtil<UuidValue>(
                RateLimitedRequestAttemptConfig<UuidValue>(
                  domain: _testDomain,
                  source: 'uuid_nonce',
                  maxAttempts: 2,
                ),
              );

          await uuidRateLimitUtil.recordAttempt(session, nonce: uuidNonce);

          final attemptCount = await uuidRateLimitUtil.countAttempts(
            session,
            nonce: uuidNonce,
          );
          final attempts = await _findAttempts(
            session,
            source: 'uuid_nonce',
          );

          expect(attemptCount, 1);
          expect(attempts, hasLength(1));
        },
      );
    },
  );
}

Future<void> _deleteRateLimitAttempts(final Session session) async {
  await RateLimitedRequestAttempt.db.deleteWhere(
    session,
    where: (final t) => t.domain.equals(_testDomain),
  );
}

Future<List<RateLimitedRequestAttempt>> _findAttempts(
  final Session session, {
  required final String source,
  final String? nonce,
}) async {
  return RateLimitedRequestAttempt.db.find(
    session,
    where: (final t) {
      var expression = t.domain.equals(_testDomain) & t.source.equals(source);

      if (nonce != null) {
        expression &= t.nonce.equals(nonce);
      }

      return expression;
    },
    orderBy: (final t) => t.attemptedAt,
  );
}

final class _ExpectedRollbackException implements Exception {}

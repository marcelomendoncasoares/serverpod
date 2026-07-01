import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import '../../test_tags.dart';
import '../../test_tools/serverpod_test_tools.dart';

const _testDomain = 'rate_limit_util_test';

void main() {
  withServerpod(
    'DatabaseRateLimitedRequestAttemptUtil',
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

      group('Given default metadata and request metadata for an attempt, ', () {
        late Map<String, String> requestMetadata;

        setUp(() {
          rateLimitUtil = DatabaseRateLimitedRequestAttemptUtil<String>(
            RateLimitedRequestAttemptConfig<String>(
              domain: _testDomain,
              source: 'verification',
              defaultExtraData: const {
                'client': 'mobile',
                'shared': 'default',
              },
              maxAttempts: 2,
            ),
          );
          requestMetadata = const {
            'requestId': '123',
            'shared': 'request',
          };
        });

        test(
          'when recording the attempt, '
          'then it stores the attempt with merged metadata.',
          () async {
            await rateLimitUtil.recordAttempt(
              session,
              nonce: 'request-a',
              extraData: requestMetadata,
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
      });

      group(
        'Given a request with no previous attempts and a two-attempt limit, ',
        () {
          late String requestNonce;

          setUp(() async {
            requestNonce = 'request-b';
            rateLimitUtil = DatabaseRateLimitedRequestAttemptUtil<String>(
              RateLimitedRequestAttemptConfig<String>(
                domain: _testDomain,
                source: 'verification',
                maxAttempts: 2,
                onRateLimitExceeded: (final session, final nonce) async {
                  rateLimitExceededNonces.add(nonce);
                },
              ),
            );
            await rateLimitUtil.deleteAttempts(
              session,
              nonce: requestNonce,
              olderThan: const Duration(microseconds: 0),
            );
          });

          test(
            'when checking the rate limit three times, '
            'then it allows two attempts and rate limits the third attempt.',
            () async {
              final firstAttemptLimited = await rateLimitUtil
                  .hasTooManyAttempts(
                    session,
                    nonce: requestNonce,
                  );
              final secondAttemptLimited = await rateLimitUtil
                  .hasTooManyAttempts(
                    session,
                    nonce: requestNonce,
                  );
              final thirdAttemptLimited = await rateLimitUtil
                  .hasTooManyAttempts(
                    session,
                    nonce: requestNonce,
                  );

              final attemptCount = await rateLimitUtil.countAttempts(
                session,
                nonce: requestNonce,
              );

              expect(firstAttemptLimited, isFalse);
              expect(secondAttemptLimited, isFalse);
              expect(thirdAttemptLimited, isTrue);
              expect(rateLimitExceededNonces, [requestNonce]);
              expect(attemptCount, 2);
            },
          );
        },
      );

      group(
        'Given a rate limit check happened inside a rolled-back caller transaction, ',
        () {
          setUp(() async {
            try {
              await session.db.transaction((final transaction) async {
                await rateLimitUtil.hasTooManyAttempts(
                  session,
                  nonce: 'request-c',
                );

                throw _ExpectedRollbackException();
              });
            } on _ExpectedRollbackException {
              // Expected test setup rollback.
            }
          });

          test(
            'when counting attempts for the request, '
            'then the recorded attempt remains counted.',
            () async {
              final attemptCount = await rateLimitUtil.countAttempts(
                session,
                nonce: 'request-c',
              );

              expect(attemptCount, 1);
            },
          );
        },
      );

      group(
        'Given a request has one attempt outside the timeframe and one inside it, ',
        () {
          late DateTime now;

          setUp(() async {
            rateLimitUtil = DatabaseRateLimitedRequestAttemptUtil<String>(
              RateLimitedRequestAttemptConfig<String>(
                domain: _testDomain,
                source: 'verification',
                timeframe: const Duration(hours: 1),
              ),
            );
            now = DateTime.utc(2026, 1, 1, 12);

            await withClock(
              Clock.fixed(now.subtract(const Duration(hours: 2))),
              () => rateLimitUtil.recordAttempt(
                session,
                nonce: 'request-d',
              ),
            );

            await withClock(
              Clock.fixed(now),
              () => rateLimitUtil.recordAttempt(
                session,
                nonce: 'request-d',
              ),
            );
          });

          test(
            'when counting attempts for the request, '
            'then it only counts attempts inside the timeframe.',
            () async {
              await withClock(Clock.fixed(now), () async {
                final attemptCount = await rateLimitUtil.countAttempts(
                  session,
                  nonce: 'request-d',
                );

                expect(attemptCount, 1);
              });
            },
          );
        },
      );

      group(
        'Given a request has old and new attempts and another request has an old attempt, ',
        () {
          late DateTime now;

          setUp(() async {
            now = DateTime.utc(2026, 1, 1, 12);

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

            await withClock(
              Clock.fixed(now),
              () => rateLimitUtil.recordAttempt(
                session,
                nonce: 'request-e',
              ),
            );
          });

          test(
            'when deleting attempts for the request older than a duration, '
            'then it keeps newer attempts and attempts for other requests.',
            () async {
              await withClock(Clock.fixed(now), () async {
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
        },
      );

      group('Given a rate limiter using UUID request identifiers, ', () {
        late UuidValue uuidNonce;
        late DatabaseRateLimitedRequestAttemptUtil<UuidValue> uuidRateLimitUtil;

        setUp(() {
          uuidNonce = const Uuid().v4obj();
          uuidRateLimitUtil = DatabaseRateLimitedRequestAttemptUtil<UuidValue>(
            RateLimitedRequestAttemptConfig<UuidValue>(
              domain: _testDomain,
              source: 'uuid_nonce',
              maxAttempts: 2,
            ),
          );
        });

        test(
          'when recording an attempt for a UUID request identifier, '
          'then it counts the attempt by the typed identifier.',
          () async {
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
      });
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

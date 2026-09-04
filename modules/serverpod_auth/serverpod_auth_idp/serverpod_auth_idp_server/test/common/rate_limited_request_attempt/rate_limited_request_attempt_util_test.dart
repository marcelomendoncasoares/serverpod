import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import '../../test_tools/serverpod_test_tools.dart';

const _testDomain = 'rate_limit_util_test';
const _otherDomain = 'rate_limit_util_test_other_domain';
const _testSource = 'verification';
const _otherSource = 'other_source';

void main() {
  test(
    'Given no maxAttempts and no timeframe, '
    'when creating a rate limiting configuration, '
    'then it throws an assertion error.',
    () {
      expect(
        () => RateLimitedRequestAttemptConfig<String>(
          domain: _testDomain,
          source: _testSource,
        ),
        throwsA(isA<AssertionError>()),
      );
    },
  );

  test(
    'Given a rate limiting configuration for string nonces, '
    'when encoding a nonce, '
    'then it returns the nonce unchanged.',
    () {
      final config = RateLimitedRequestAttemptConfig<String>(
        domain: _testDomain,
        source: _testSource,
        maxAttempts: 1,
      );

      expect(config.nonceToString('request'), 'request');
    },
  );

  test(
    'Given a rate limiting configuration for UUID nonces, '
    'when encoding a nonce, '
    'then it returns the identifier as a JSON encoded string.',
    () {
      final config = RateLimitedRequestAttemptConfig<UuidValue>(
        domain: _testDomain,
        source: _testSource,
        maxAttempts: 1,
      );
      final requestId = const Uuid().v4obj();

      expect(config.nonceToString(requestId), '"${requestId.uuid}"');
    },
  );

  test(
    'Given a rate limiting configuration with a custom nonce encoder, '
    'when encoding a nonce, '
    'then it returns the value produced by the custom encoder.',
    () {
      final config = RateLimitedRequestAttemptConfig<UuidValue>(
        domain: _testDomain,
        source: _testSource,
        maxAttempts: 1,
        nonceToString: (final nonce) => nonce.uuid,
      );
      final requestId = const Uuid().v4obj();

      expect(config.nonceToString(requestId), requestId.uuid);
    },
  );

  withServerpod(
    'DatabaseRateLimitedRequestAttemptUtil',
    rollbackDatabase: RollbackDatabase.disabled,
    (final sessionBuilder, final endpoints) {
      late Session session;
      late List<String> rateLimitExceededNonces;

      Future<void> recordRateLimitExceeded(
        final Session session,
        final String nonce,
      ) async {
        rateLimitExceededNonces.add(nonce);
      }

      DatabaseRateLimitedRequestAttemptUtil<String> buildRateLimitUtil({
        final String domain = _testDomain,
        final String source = _testSource,
        final Map<String, String>? defaultExtraData,
        final int? maxAttempts,
        final Duration? timeframe,
        final Future<void> Function(Session session, String nonce)?
        onRateLimitExceeded,
      }) {
        return DatabaseRateLimitedRequestAttemptUtil<String>(
          RateLimitedRequestAttemptConfig<String>(
            domain: domain,
            source: source,
            defaultExtraData: defaultExtraData,
            maxAttempts: maxAttempts,
            timeframe: timeframe,
            onRateLimitExceeded: onRateLimitExceeded,
          ),
        );
      }

      setUp(() async {
        session = sessionBuilder.build();
        rateLimitExceededNonces = [];

        await _deleteTestAttempts(session);
      });

      tearDown(() async {
        await _deleteTestAttempts(session);
      });

      group('Given a rate limiter that allows two attempts, ', () {
        late DatabaseRateLimitedRequestAttemptUtil<String> rateLimitUtil;

        setUp(() {
          rateLimitUtil = buildRateLimitUtil(
            maxAttempts: 2,
            onRateLimitExceeded: recordRateLimitExceeded,
          );
        });

        group('when checking the rate limit three times for one request, ', () {
          late List<bool> rateLimited;

          setUp(() async {
            rateLimited = [
              for (var attempt = 0; attempt < 3; attempt++)
                await rateLimitUtil.hasTooManyAttempts(
                  session,
                  nonce: 'request',
                ),
            ];
          });

          test(
            'then it allows the first two checks and rate limits the third.',
            () {
              expect(rateLimited, [false, false, true]);
            },
          );

          test('then it only records the two allowed attempts.', () async {
            final attemptCount = await rateLimitUtil.countAttempts(
              session,
              nonce: 'request',
            );

            expect(attemptCount, 2);
          });

          test('then it reports the request to the rate limit callback.', () {
            expect(rateLimitExceededNonces, ['request']);
          });
        });

        group(
          'when six concurrent sessions check the rate limit for one request, ',
          () {
            late List<bool> rateLimited;

            setUp(() async {
              rateLimited = await Future.wait([
                for (var attempt = 0; attempt < 6; attempt++)
                  rateLimitUtil.hasTooManyAttempts(
                    sessionBuilder.build(),
                    nonce: 'request',
                  ),
              ]);
            });

            test('then it allows exactly two of the checks.', () {
              expect(
                rateLimited.where((final limited) => !limited),
                hasLength(2),
              );
            });

            test('then it records exactly two attempts.', () async {
              final attemptCount = await rateLimitUtil.countAttempts(
                session,
                nonce: 'request',
              );

              expect(attemptCount, 2);
            });
          },
        );
      });

      group(
        'Given a rate limit check happened inside a rolled-back caller '
        'transaction, ',
        () {
          late DatabaseRateLimitedRequestAttemptUtil<String> rateLimitUtil;

          setUp(() async {
            rateLimitUtil = buildRateLimitUtil(maxAttempts: 2);

            try {
              await session.db.transaction((final transaction) async {
                await rateLimitUtil.hasTooManyAttempts(
                  session,
                  nonce: 'request',
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
                nonce: 'request',
              );

              expect(attemptCount, 1);
            },
          );
        },
      );

      test(
        'Given a rate limiter that allows one attempt and has no rate limit '
        'callback, '
        'when checking the rate limit twice for one request, '
        'then the second check reports the request as rate limited.',
        () async {
          final rateLimitUtil = buildRateLimitUtil(maxAttempts: 1);

          await rateLimitUtil.hasTooManyAttempts(session, nonce: 'request');
          final rateLimited = await rateLimitUtil.hasTooManyAttempts(
            session,
            nonce: 'request',
          );

          expect(rateLimited, isTrue);
        },
      );

      group(
        'Given a rate limiter with default extra data for every attempt, ',
        () {
          late DatabaseRateLimitedRequestAttemptUtil<String> rateLimitUtil;

          setUp(() {
            rateLimitUtil = buildRateLimitUtil(
              maxAttempts: 2,
              defaultExtraData: const {
                'client': 'mobile',
                'shared': 'default',
              },
            );
          });

          test(
            'when recording an attempt with request extra data, '
            'then it stores the attempt with the request data merged over the '
            'default data.',
            () async {
              await rateLimitUtil.recordAttempt(
                session,
                nonce: 'request',
                extraData: const {
                  'requestId': '123',
                  'shared': 'request',
                },
              );

              final attempts = await _findAttempts(session, nonce: 'request');

              expect(attempts, hasLength(1));
              expect(attempts.single.domain, _testDomain);
              expect(attempts.single.source, _testSource);
              expect(attempts.single.nonce, 'request');
              expect(attempts.single.extraData, {
                'client': 'mobile',
                'shared': 'request',
                'requestId': '123',
              });
            },
          );
        },
      );

      test(
        'Given a rate limiter without default extra data, '
        'when recording an attempt without extra data, '
        'then it stores the attempt with no extra data.',
        () async {
          final rateLimitUtil = buildRateLimitUtil(maxAttempts: 2);

          await rateLimitUtil.recordAttempt(session, nonce: 'request');

          final attempts = await _findAttempts(session, nonce: 'request');

          expect(attempts, hasLength(1));
          expect(attempts.single.extraData, isNull);
        },
      );

      group('Given a rate limiter for UUID request identifiers, ', () {
        late UuidValue requestId;
        late DatabaseRateLimitedRequestAttemptUtil<UuidValue> rateLimitUtil;

        setUp(() {
          requestId = const Uuid().v4obj();
          rateLimitUtil = DatabaseRateLimitedRequestAttemptUtil<UuidValue>(
            RateLimitedRequestAttemptConfig<UuidValue>(
              domain: _testDomain,
              source: _testSource,
              maxAttempts: 2,
            ),
          );
        });

        test(
          'when recording an attempt, '
          'then it stores the identifier as a JSON encoded nonce.',
          () async {
            await rateLimitUtil.recordAttempt(session, nonce: requestId);

            final attempts = await _findAttempts(session);

            expect(attempts, hasLength(1));
            expect(attempts.single.nonce, '"${requestId.uuid}"');
          },
        );

        test(
          'when counting attempts after recording one, '
          'then it counts the attempt by the typed identifier.',
          () async {
            await rateLimitUtil.recordAttempt(session, nonce: requestId);

            final attemptCount = await rateLimitUtil.countAttempts(
              session,
              nonce: requestId,
            );

            expect(attemptCount, 1);
          },
        );
      });

      group(
        'Given a rate limiter with a one-hour timeframe, '
        'and a request with an attempt two hours ago and an attempt now, ',
        () {
          late DateTime now;
          late DatabaseRateLimitedRequestAttemptUtil<String> rateLimitUtil;

          setUp(() async {
            now = DateTime.utc(2026, 1, 1, 12);
            rateLimitUtil = buildRateLimitUtil(
              timeframe: const Duration(hours: 1),
            );

            await withClock(
              Clock.fixed(now.subtract(const Duration(hours: 2))),
              () => rateLimitUtil.recordAttempt(session, nonce: 'request'),
            );
            await withClock(
              Clock.fixed(now),
              () => rateLimitUtil.recordAttempt(session, nonce: 'request'),
            );
          });

          test(
            'when counting attempts for the request, '
            'then it only counts the attempt inside the timeframe.',
            () async {
              await withClock(Clock.fixed(now), () async {
                final attemptCount = await rateLimitUtil.countAttempts(
                  session,
                  nonce: 'request',
                );

                expect(attemptCount, 1);
              });
            },
          );

          test(
            'when deleting attempts for the request without an explicit '
            'duration, '
            'then it only deletes the attempt older than the timeframe.',
            () async {
              await withClock(Clock.fixed(now), () async {
                final deletedAttempts = await rateLimitUtil.deleteAttempts(
                  session,
                  nonce: 'request',
                );

                expect(deletedAttempts, 1);
              });

              final attempts = await _findAttempts(session, nonce: 'request');

              expect(attempts, hasLength(1));
            },
          );
        },
      );

      group(
        'Given a request with an attempt two hours ago and an attempt now, '
        'and another request with an attempt two hours ago, ',
        () {
          late DateTime now;
          late DatabaseRateLimitedRequestAttemptUtil<String> rateLimitUtil;

          setUp(() async {
            now = DateTime.utc(2026, 1, 1, 12);
            rateLimitUtil = buildRateLimitUtil(maxAttempts: 2);

            await withClock(
              Clock.fixed(now.subtract(const Duration(hours: 2))),
              () async {
                await rateLimitUtil.recordAttempt(session, nonce: 'request');
                await rateLimitUtil.recordAttempt(
                  session,
                  nonce: 'other-request',
                );
              },
            );
            await withClock(
              Clock.fixed(now),
              () => rateLimitUtil.recordAttempt(session, nonce: 'request'),
            );
          });

          test(
            'when deleting attempts for the request older than one hour, '
            'then it keeps the newer attempt and the other request attempt.',
            () async {
              await withClock(Clock.fixed(now), () async {
                final deletedAttempts = await rateLimitUtil.deleteAttempts(
                  session,
                  nonce: 'request',
                  olderThan: const Duration(hours: 1),
                );

                expect(deletedAttempts, 1);
              });

              final attempts = await _findAttempts(session, nonce: 'request');
              final otherAttempts = await _findAttempts(
                session,
                nonce: 'other-request',
              );

              expect(attempts, hasLength(1));
              expect(otherAttempts, hasLength(1));
            },
          );

          test(
            'when deleting attempts older than one hour without a nonce, '
            'then it deletes the old attempt of every request.',
            () async {
              await withClock(Clock.fixed(now), () async {
                final deletedAttempts = await rateLimitUtil.deleteAttempts(
                  session,
                  olderThan: const Duration(hours: 1),
                );

                expect(deletedAttempts, 2);
              });

              final attempts = await _findAttempts(session);

              expect(attempts, hasLength(1));
              expect(attempts.single.nonce, 'request');
            },
          );
        },
      );

      group(
        'Given a rate limiter that allows two attempts within one hour, '
        'and a request that used both attempts two hours ago, ',
        () {
          late DateTime now;
          late DatabaseRateLimitedRequestAttemptUtil<String> rateLimitUtil;

          setUp(() async {
            now = DateTime.utc(2026, 1, 1, 12);
            rateLimitUtil = buildRateLimitUtil(
              maxAttempts: 2,
              timeframe: const Duration(hours: 1),
              onRateLimitExceeded: recordRateLimitExceeded,
            );

            await withClock(
              Clock.fixed(now.subtract(const Duration(hours: 2))),
              () async {
                await rateLimitUtil.recordAttempt(session, nonce: 'request');
                await rateLimitUtil.recordAttempt(session, nonce: 'request');
              },
            );
          });

          test(
            'when checking the rate limit now, '
            'then it allows the attempt.',
            () async {
              await withClock(Clock.fixed(now), () async {
                final rateLimited = await rateLimitUtil.hasTooManyAttempts(
                  session,
                  nonce: 'request',
                );

                expect(rateLimited, isFalse);
                expect(rateLimitExceededNonces, isEmpty);
              });
            },
          );
        },
      );

      group('Given a rate limiter with only a one-hour timeframe, ', () {
        late DatabaseRateLimitedRequestAttemptUtil<String> rateLimitUtil;

        setUp(() {
          rateLimitUtil = buildRateLimitUtil(
            timeframe: const Duration(hours: 1),
            onRateLimitExceeded: recordRateLimitExceeded,
          );
        });

        group(
          'when checking the rate limit three times for one request with extra '
          'data, ',
          () {
            late List<bool> rateLimited;

            setUp(() async {
              rateLimited = [
                for (var attempt = 0; attempt < 3; attempt++)
                  await rateLimitUtil.hasTooManyAttempts(
                    session,
                    nonce: 'request',
                    extraData: const {'requestId': '123'},
                  ),
              ];
            });

            test('then it never rate limits the request.', () {
              expect(rateLimited, [false, false, false]);
              expect(rateLimitExceededNonces, isEmpty);
            });

            test(
              'then it records every attempt with the extra data.',
              () async {
                final attempts = await _findAttempts(session, nonce: 'request');

                expect(attempts, hasLength(3));
                expect(
                  attempts.map((final attempt) => attempt.extraData),
                  everyElement({'requestId': '123'}),
                );
              },
            );
          },
        );
      });

      group('Given a request with an attempt under two sources, ', () {
        late DateTime now;
        late DatabaseRateLimitedRequestAttemptUtil<String> rateLimitUtil;

        setUp(() async {
          now = DateTime.utc(2026, 1, 1, 12);
          rateLimitUtil = buildRateLimitUtil(maxAttempts: 2);
          final otherSourceUtil = buildRateLimitUtil(
            source: _otherSource,
            maxAttempts: 2,
          );

          await withClock(
            Clock.fixed(now.subtract(const Duration(minutes: 1))),
            () async {
              await rateLimitUtil.recordAttempt(session, nonce: 'request');
              await otherSourceUtil.recordAttempt(session, nonce: 'request');
            },
          );
        });

        test(
          'when counting attempts for the request, '
          'then it does not count the attempt from the other source.',
          () async {
            final attemptCount = await rateLimitUtil.countAttempts(
              session,
              nonce: 'request',
            );

            expect(attemptCount, 1);
          },
        );

        test(
          'when deleting attempts for the request, '
          'then it keeps the attempt from the other source.',
          () async {
            await withClock(Clock.fixed(now), () async {
              final deletedAttempts = await rateLimitUtil.deleteAttempts(
                session,
                nonce: 'request',
              );

              expect(deletedAttempts, 1);
            });

            final attempts = await _findAttempts(session, nonce: 'request');
            final otherSourceAttempts = await _findAttempts(
              session,
              source: _otherSource,
              nonce: 'request',
            );

            expect(attempts, isEmpty);
            expect(otherSourceAttempts, hasLength(1));
          },
        );
      });

      group('Given a request with an attempt under two domains, ', () {
        late DateTime now;
        late DatabaseRateLimitedRequestAttemptUtil<String> rateLimitUtil;

        setUp(() async {
          now = DateTime.utc(2026, 1, 1, 12);
          rateLimitUtil = buildRateLimitUtil(maxAttempts: 2);
          final otherDomainUtil = buildRateLimitUtil(
            domain: _otherDomain,
            maxAttempts: 2,
          );

          await withClock(
            Clock.fixed(now.subtract(const Duration(minutes: 1))),
            () async {
              await rateLimitUtil.recordAttempt(session, nonce: 'request');
              await otherDomainUtil.recordAttempt(session, nonce: 'request');
            },
          );
        });

        test(
          'when counting attempts for the request, '
          'then it does not count the attempt from the other domain.',
          () async {
            final attemptCount = await rateLimitUtil.countAttempts(
              session,
              nonce: 'request',
            );

            expect(attemptCount, 1);
          },
        );

        test(
          'when deleting attempts for the request, '
          'then it keeps the attempt from the other domain.',
          () async {
            await withClock(Clock.fixed(now), () async {
              final deletedAttempts = await rateLimitUtil.deleteAttempts(
                session,
                nonce: 'request',
              );

              expect(deletedAttempts, 1);
            });

            final attempts = await _findAttempts(session, nonce: 'request');
            final otherDomainAttempts = await _findAttempts(
              session,
              domain: _otherDomain,
              nonce: 'request',
            );

            expect(attempts, isEmpty);
            expect(otherDomainAttempts, hasLength(1));
          },
        );
      });
    },
  );
}

Future<void> _deleteTestAttempts(final Session session) async {
  await RateLimitedRequestAttempt.db.deleteWhere(
    session,
    where: (final t) =>
        t.domain.equals(_testDomain) | t.domain.equals(_otherDomain),
  );
}

Future<List<RateLimitedRequestAttempt>> _findAttempts(
  final Session session, {
  final String domain = _testDomain,
  final String source = _testSource,
  final String? nonce,
}) async {
  return RateLimitedRequestAttempt.db.find(
    session,
    where: (final t) {
      var expression = t.domain.equals(domain) & t.source.equals(source);

      if (nonce != null) {
        expression &= t.nonce.equals(nonce);
      }

      return expression;
    },
    orderBy: (final t) => t.attemptedAt,
  );
}

final class _ExpectedRollbackException implements Exception {}

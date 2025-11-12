import 'package:clock/clock.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/auth_user.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:test/test.dart';

import '../../test_tags.dart';
import '../../test_tools/serverpod_test_tools.dart';
import '../test_utils/email_idp_test_fixture.dart';

void main() {
  withServerpod(
    'Given an existing email account with scopes',
    rollbackDatabase: RollbackDatabase.disabled,
    testGroupTagsOverride: TestTags.concurrencyOneTestTags,
    (final sessionBuilder, final endpoints) {
      late Session session;
      late EmailIDPTestFixture fixture;
      const email = 'test@serverpod.dev';
      const password = 'Password123!';

      setUp(() async {
        session = sessionBuilder.build();
        fixture = EmailIDPTestFixture();

        final authUser = await fixture.authUsers.create(session);

        await fixture.authUsers.update(
          session,
          authUserId: authUser.id,
          scopes: {const Scope('test-scope'), const Scope('admin')},
        );

        await fixture.createEmailAccount(
          session,
          authUserId: authUser.id,
          email: email,
          password: EmailAccountPassword.fromString(password),
        );
      });

      tearDown(() async {
        await fixture.tearDown(session);
      });

      test(
          'when login is called with correct credentials then it returns auth session token',
          () async {
        final result = fixture.emailIDP.login(
          session,
          email: email,
          password: password,
        );

        await expectLater(result, completion(isA<AuthSuccess>()));
      });

      test(
          'when login is called with invalid credentials then it throws EmailAccountLoginException with invalidCredentials',
          () async {
        final result = fixture.emailIDP.login(
          session,
          email: email,
          password: 'WrongPassword123!',
        );

        await expectLater(
          result,
          throwsA(
            isA<EmailAccountLoginException>().having(
              (final e) => e.reason,
              'reason',
              EmailAccountLoginExceptionReason.invalidCredentials,
            ),
          ),
        );
      });

      test(
          'when login is called, then the returned AuthSuccess contains the users scopes',
          () async {
        final result = await fixture.emailIDP.login(
          session,
          email: email,
          password: password,
        );

        expect(result.scopeNames, contains('test-scope'));
        expect(result.scopeNames, contains('admin'));
        expect(result.scopeNames, hasLength(2));
      });
    },
  );

  withServerpod(
    'Given blocked auth user with email account',
    rollbackDatabase: RollbackDatabase.disabled,
    testGroupTagsOverride: TestTags.concurrencyOneTestTags,
    (final sessionBuilder, final endpoints) {
      late Session session;
      late EmailIDPTestFixture fixture;
      const email = 'test@serverpod.dev';
      const password = 'Password123!';

      setUp(() async {
        session = sessionBuilder.build();
        fixture = EmailIDPTestFixture();

        final authUser = await fixture.authUsers.create(session);
        await fixture.authUsers.update(
          session,
          authUserId: authUser.id,
          blocked: true,
        );

        await fixture.createEmailAccount(
          session,
          authUserId: authUser.id,
          email: email,
          password: EmailAccountPassword.fromString(password),
        );
      });

      tearDown(() async {
        await fixture.tearDown(session);
      });

      test(
          'when login is called with correct credentials then it throws AuthUserBlockedException',
          () async {
        final result = fixture.emailIDP.login(
          session,
          email: email,
          password: password,
        );

        await expectLater(
          result,
          throwsA(isA<AuthUserBlockedException>()),
        );
      });
    },
  );

  withServerpod(
    'Given email account with invalid logins matching rate limit',
    rollbackDatabase: RollbackDatabase.disabled,
    testGroupTagsOverride: TestTags.concurrencyOneTestTags,
    (final sessionBuilder, final endpoints) {
      late Session session;
      late EmailIDPTestFixture fixture;
      const email = 'test@serverpod.dev';
      const password = 'Password123!';
      const maxLoginAttempts = RateLimit(
        maxAttempts: 1,
        timeframe: Duration(hours: 1),
      );

      setUp(() async {
        session = sessionBuilder.build();

        fixture = EmailIDPTestFixture(
          config: const EmailIDPConfig(
            secretHashPepper: 'pepper',
            failedLoginRateLimit: maxLoginAttempts,
          ),
        );

        final authUser = await fixture.authUsers.create(session);

        await fixture.createEmailAccount(
          session,
          authUserId: authUser.id,
          email: email,
          password: EmailAccountPassword.fromString(password),
        );

        // Make initial failed login attempt to hit the rate limit
        try {
          await fixture.emailIDP.login(
            session,
            email: email,
            password: 'WrongPassword123!',
          );
        } on EmailAccountLoginException {
          // Expected
        }
      });

      tearDown(() async {
        await fixture.tearDown(session);
      });

      test(
          'when login is called with valid credentials then it throws EmailAccountLoginException with reason "tooManyAttempts"',
          () async {
        final result = fixture.emailIDP.login(
          session,
          email: email,
          password: password,
        );

        await expectLater(
          result,
          throwsA(
            isA<EmailAccountLoginException>().having(
              (final e) => e.reason,
              'reason',
              EmailAccountLoginExceptionReason.tooManyAttempts,
            ),
          ),
        );
      });

      test(
          'when login is called with invalid credentials then it throws EmailAccountLoginException with reason "tooManyAttempts"',
          () async {
        final result = fixture.emailIDP.login(
          session,
          email: email,
          password: '$password-invalid',
        );

        await expectLater(
          result,
          throwsA(
            isA<EmailAccountLoginException>().having(
              (final e) => e.reason,
              'reason',
              EmailAccountLoginExceptionReason.tooManyAttempts,
            ),
          ),
        );
      });
    },
  );

  withServerpod(
    'Given no email account',
    rollbackDatabase: RollbackDatabase.disabled,
    testGroupTagsOverride: TestTags.concurrencyOneTestTags,
    (final sessionBuilder, final endpoints) {
      late Session session;
      late EmailIDPTestFixture fixture;

      setUp(() async {
        session = sessionBuilder.build();
        fixture = EmailIDPTestFixture();
      });

      tearDown(() async {
        await fixture.tearDown(session);
      });

      test(
          'when login is called then it throws EmailAccountLoginException with invalidCredentials',
          () async {
        final result = fixture.emailIDP.login(
          session,
          email: 'nonexistent@serverpod.dev',
          password: 'Password123!',
        );

        await expectLater(
          result,
          throwsA(
            isA<EmailAccountLoginException>().having(
              (final e) => e.reason,
              'reason',
              EmailAccountLoginExceptionReason.invalidCredentials,
            ),
          ),
        );
      });
    },
  );

  withServerpod(
    'Given maximum allowed invalid login attempts for non-existent email account',
    rollbackDatabase: RollbackDatabase.disabled,
    testGroupTagsOverride: TestTags.concurrencyOneTestTags,
    (final sessionBuilder, final endpoints) {
      late Session session;
      late EmailIDPTestFixture fixture;
      const maxLoginAttempts = RateLimit(
        maxAttempts: 1,
        timeframe: Duration(hours: 1),
      );
      const email = 'nonexistent@serverpod.dev';

      setUp(() async {
        session = sessionBuilder.build();
        fixture = EmailIDPTestFixture(
          config: const EmailIDPConfig(
            secretHashPepper: 'pepper',
            failedLoginRateLimit: maxLoginAttempts,
          ),
        );

        // Make initial failed login attempt to hit the rate limit
        try {
          await fixture.emailIDP.login(
            session,
            email: email,
            password: 'WrongPassword123!',
          );
        } on EmailAccountLoginException {
          // Expected
        }
      });

      tearDown(() async {
        await fixture.tearDown(session);
      });

      test(
          'when login is called then it throws EmailAccountLoginException with reason "tooManyAttempts"',
          () async {
        final result = fixture.emailIDP.login(
          session,
          email: email,
          password: 'Password123!',
        );

        await expectLater(
          result,
          throwsA(
            isA<EmailAccountLoginException>().having(
              (final e) => e.reason,
              'reason',
              EmailAccountLoginExceptionReason.tooManyAttempts,
            ),
          ),
        );
      });
    },
  );

  withServerpod(
    'Given email account with password expiration configured',
    rollbackDatabase: RollbackDatabase.disabled,
    testGroupTagsOverride: TestTags.concurrencyOneTestTags,
    (final sessionBuilder, final endpoints) {
      late Session session;
      late EmailIDPTestFixture fixture;
      const email = 'test@serverpod.dev';
      const password = 'Password123!';
      const passwordExpirationDuration = Duration(days: 90);

      setUp(() async {
        session = sessionBuilder.build();
        fixture = EmailIDPTestFixture(
          config: const EmailIDPConfig(
            secretHashPepper: 'pepper',
            passwordExpirationDuration: passwordExpirationDuration,
          ),
        );

        final authUser = await fixture.authUsers.create(session);

        await fixture.createEmailAccount(
          session,
          authUserId: authUser.id,
          email: email,
          password: EmailAccountPassword.fromString(password),
        );
      });

      tearDown(() async {
        await fixture.tearDown(session);
      });

      test(
          'when login is called with expired password then it throws EmailAccountLoginException with passwordExpired',
          () async {
        // Set passwordSetAt to a time before the expiration duration
        final account = await EmailAccount.db.findFirstRow(
          session,
          where: (final t) => t.email.equals(email),
        );
        expect(account, isNotNull);

        final expiredPasswordSetAt = clock.now().subtract(
              passwordExpirationDuration + const Duration(days: 1),
            );

        await EmailAccount.db.updateRow(
          session,
          account!.copyWith(passwordSetAt: expiredPasswordSetAt),
        );

        final result = fixture.emailIDP.login(
          session,
          email: email,
          password: password,
        );

        await expectLater(
          result,
          throwsA(
            isA<EmailAccountLoginException>().having(
              (final e) => e.reason,
              'reason',
              EmailAccountLoginExceptionReason.passwordExpired,
            ),
          ),
        );
      });

      test(
          'when login is called with non-expired password then it returns auth session token',
          () async {
        // Set passwordSetAt to a recent time within the expiration duration
        final account = await EmailAccount.db.findFirstRow(
          session,
          where: (final t) => t.email.equals(email),
        );
        expect(account, isNotNull);

        final recentPasswordSetAt = clock.now().subtract(
              const Duration(days: 30),
            );

        await EmailAccount.db.updateRow(
          session,
          account!.copyWith(passwordSetAt: recentPasswordSetAt),
        );

        final result = fixture.emailIDP.login(
          session,
          email: email,
          password: password,
        );

        await expectLater(result, completion(isA<AuthSuccess>()));
      });

      test(
          'when login is called with password set exactly at expiration time then it throws EmailAccountLoginException with passwordExpired',
          () async {
        // Set passwordSetAt to exactly the expiration duration ago
        final account = await EmailAccount.db.findFirstRow(
          session,
          where: (final t) => t.email.equals(email),
        );
        expect(account, isNotNull);

        final exactlyExpiredPasswordSetAt = clock.now().subtract(
              passwordExpirationDuration,
            );

        await EmailAccount.db.updateRow(
          session,
          account!.copyWith(passwordSetAt: exactlyExpiredPasswordSetAt),
        );

        // Advance time by 1 second to make it expired
        await withClock(
          Clock.fixed(clock.now().add(const Duration(seconds: 1))),
          () async {
            final result = fixture.emailIDP.login(
              session,
              email: email,
              password: password,
            );

            await expectLater(
              result,
              throwsA(
                isA<EmailAccountLoginException>().having(
                  (final e) => e.reason,
                  'reason',
                  EmailAccountLoginExceptionReason.passwordExpired,
                ),
              ),
            );
          },
        );
      });
    },
  );

  withServerpod(
    'Given email account with password expiration disabled',
    rollbackDatabase: RollbackDatabase.disabled,
    testGroupTagsOverride: TestTags.concurrencyOneTestTags,
    (final sessionBuilder, final endpoints) {
      late Session session;
      late EmailIDPTestFixture fixture;
      const email = 'test@serverpod.dev';
      const password = 'Password123!';

      setUp(() async {
        session = sessionBuilder.build();
        fixture = EmailIDPTestFixture(
          config: const EmailIDPConfig(
            secretHashPepper: 'pepper',
            passwordExpirationDuration: null,
          ),
        );

        final authUser = await fixture.authUsers.create(session);

        // Set passwordSetAt to a very old date
        final oldPasswordSetAt = DateTime(2020, 1, 1);

        await withClock(Clock.fixed(oldPasswordSetAt), () async {
          await fixture.createEmailAccount(
            session,
            authUserId: authUser.id,
            email: email,
            password: EmailAccountPassword.fromString(password),
          );
        });
      });

      tearDown(() async {
        await fixture.tearDown(session);
      });

      test(
          'when login is called with old password then it returns auth session token',
          () async {
        final result = fixture.emailIDP.login(
          session,
          email: email,
          password: password,
        );

        await expectLater(result, completion(isA<AuthSuccess>()));
      });
    },
  );

  withServerpod(
    'Given email account with passwordSetAt set to null',
    rollbackDatabase: RollbackDatabase.disabled,
    testGroupTagsOverride: TestTags.concurrencyOneTestTags,
    (final sessionBuilder, final endpoints) {
      late Session session;
      late EmailIDPTestFixture fixture;
      const email = 'test@serverpod.dev';
      const password = 'Password123!';
      const passwordExpirationDuration = Duration(days: 90);

      setUp(() async {
        session = sessionBuilder.build();
        fixture = EmailIDPTestFixture(
          config: const EmailIDPConfig(
            secretHashPepper: 'pepper',
            passwordExpirationDuration: passwordExpirationDuration,
          ),
        );

        final authUser = await fixture.authUsers.create(session);

        await withClock(
            Clock.fixed(clock.now().subtract(const Duration(days: 365))),
            () async {
          await fixture.createEmailAccount(
            session,
            authUserId: authUser.id,
            email: email,
            password: EmailAccountPassword.fromString(password),
          );
        });
      });

      tearDown(() async {
        await fixture.tearDown(session);
      });

      test('when login is called then it returns auth session token', () async {
        final result = fixture.emailIDP.login(
          session,
          email: email,
          password: password,
        );

        await expectLater(result, completion(isA<AuthSuccess>()));
      });
    },
  );
}

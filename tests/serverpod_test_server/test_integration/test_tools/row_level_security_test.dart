import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test_server/src/generated/protocol.dart';
import 'package:serverpod_test_server/test_util/test_tags.dart';
import 'package:test/test.dart';

import 'serverpod_test_tools.dart';

void main() {
  // Two authenticated users. `userIdentifier` is always a UUID, matched against
  // the `ownerId` column by the generated row security policy.
  const userA = '11111111-1111-4111-8111-111111111111';
  const userB = '22222222-2222-4222-8222-222222222222';

  // The integration tests connect as a superuser, which bypasses row-level
  // security entirely. To prove the policy actually filters rows we drop to a
  // dedicated non-superuser role for the duration of a transaction (mirroring a
  // normal request role, while seeding happens as the bypassing superuser).
  const rlsRole = 'rls_integration_test_role';

  /// Reads all [SecuredRecord]s for [session]'s authenticated user, with the
  /// query running under the restricted [rlsRole] so the policy is enforced.
  Future<List<SecuredRecord>> findAsRestrictedRole(Session session) {
    return session.transactionForUser((transaction) async {
      await session.db.unsafeQuery(
        'SET LOCAL ROLE $rlsRole',
        transaction: transaction,
      );
      return SecuredRecord.db.find(session, transaction: transaction);
    });
  }

  withServerpod(
    'Given a table secured with row-level security',
    (sessionBuilder, endpoints) {
      var session = sessionBuilder.build();

      var sessionA = sessionBuilder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              userA,
              {},
            ),
          )
          .build();
      var sessionB = sessionBuilder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              userB,
              {},
            ),
          )
          .build();
      var unauthenticatedSession = sessionBuilder
          .copyWith(authentication: AuthenticationOverride.unauthenticated())
          .build();

      setUpAll(() async {
        await session.db.unsafeQuery('''
DO \$\$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$rlsRole') THEN
    CREATE ROLE $rlsRole;
  END IF;
END \$\$;
''');
        await session.db.unsafeQuery(
          'GRANT SELECT, INSERT, UPDATE, DELETE ON "secured_record" '
          'TO $rlsRole;',
        );
      });

      tearDown(() async {
        // Runs as the superuser, so this clears rows for all owners.
        await session.db.unsafeQuery('DELETE FROM "secured_record";');
      });

      test('when inspecting the table '
          'then row level security is enabled and forced.', () async {
        var result = await session.db.unsafeQuery(
          'SELECT relrowsecurity, relforcerowsecurity '
          'FROM pg_class WHERE relname = \'secured_record\';',
        );
        var row = result.first.toColumnMap();
        expect(row['relrowsecurity'], isTrue);
        expect(row['relforcerowsecurity'], isTrue);
      });

      test('when inspecting the policies '
          'then the ownership policy exists.', () async {
        var result = await session.db.unsafeQuery(
          'SELECT polname FROM pg_policy '
          'JOIN pg_class ON pg_class.oid = pg_policy.polrelid '
          'WHERE relname = \'secured_record\';',
        );
        var names = result.map((r) => r.toColumnMap()['polname']).toList();
        expect(names, contains('secured_record_ownerId_rls'));
      });

      test('when running transactionForUser '
          'then serverpod.user_id is set to the authenticated user.', () async {
        var value = await sessionA.transactionForUser((transaction) async {
          var result = await sessionA.db.unsafeQuery(
            'SELECT current_setting(\'serverpod.user_id\', true) AS uid',
            transaction: transaction,
          );
          return result.first.toColumnMap()['uid'];
        });

        expect(value, userA);
      });

      test('when calling transactionForUser without authentication '
          'then a StateError is thrown.', () async {
        expect(
          () => unauthenticatedSession.transactionForUser((_) async {}),
          throwsA(isA<StateError>()),
        );
      });

      test('when two users own different rows '
          'then each user only sees their own rows.', () async {
        // Seed as the superuser (row security bypassed) so both users get rows.
        await SecuredRecord.db.insert(session, [
          SecuredRecord(ownerId: UuidValue.fromString(userA), name: 'a-1'),
          SecuredRecord(ownerId: UuidValue.fromString(userA), name: 'a-2'),
          SecuredRecord(ownerId: UuidValue.fromString(userB), name: 'b-1'),
        ]);

        var visibleToA = await findAsRestrictedRole(sessionA);
        var visibleToB = await findAsRestrictedRole(sessionB);

        expect(visibleToA.map((r) => r.name), unorderedEquals(['a-1', 'a-2']));
        expect(
          visibleToA.every((r) => r.ownerId == UuidValue.fromString(userA)),
          isTrue,
        );
        expect(visibleToB.map((r) => r.name), ['b-1']);
      });

      test('when a user has no rows '
          'then nothing is visible even though other rows exist.', () async {
        await SecuredRecord.db.insert(session, [
          SecuredRecord(ownerId: UuidValue.fromString(userB), name: 'b-1'),
        ]);

        var visibleToA = await findAsRestrictedRole(sessionA);

        expect(visibleToA, isEmpty);
      });
    },
    rollbackDatabase: RollbackDatabase.disabled,
    testGroupTagsOverride: [TestTags.concurrencyOneTestTag],
  );
}

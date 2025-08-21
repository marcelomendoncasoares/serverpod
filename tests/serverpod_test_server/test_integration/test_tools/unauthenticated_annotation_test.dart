import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test_client/serverpod_test_client.dart';
import 'package:serverpod_test_server/test_util/config.dart';
import 'package:serverpod_test_server/test_util/test_key_manager.dart';
import 'package:serverpod_test_server/test_util/test_serverpod.dart';
import 'package:test/test.dart';

void main() {
  group('Given endpoint with @unauthenticated annotations and a signed in user',
      () {
    late Serverpod server;
    late Client client;
    late AuthenticationKeyManager authKeyManager;

    setUpAll(() async {
      server = IntegrationTestServer.create();
      await server.start();

      authKeyManager = TestAuthKeyManager();
      client = Client(
        serverUrl,
        authenticationKeyManager: authKeyManager,
      );

      // Clean up any existing users
      await client.authentication.removeAllUsers();

      // Authenticate the client with a test user
      var response = await client.authentication.authenticate(
        'test@foo.bar',
        'password',
        [Scope('user').name!],
      );

      expect(response.success, isTrue, reason: 'Failed to authenticate.');
      await authKeyManager.put('${response.keyId}:${response.key}');

      var signedIn = await client.modules.auth.status.isSignedIn();
      expect(signedIn, isTrue, reason: 'Client should be authenticated');
    });

    tearDownAll(() async {
      await authKeyManager.remove();
      await client.authentication.signOut();
      await server.shutdown(exitProcess: false);
      client.close();
    });

    group('when the endpoint class is annotated as @unauthenticated', () {
      test('then calling a method returns user not signed in',
          () async {
        final signedIn = await client.unauthenticated.unauthenticatedMethod();

        expect(signedIn, isFalse);
      });

      test(
          'then calling an annotated streaming method returns user not signed in',
          () async {
        final signedIn =
            await client.unauthenticated.unauthenticatedStream().first;

        expect(signedIn, isFalse);
      });
    });

    group('when only some methods are annotated as @unauthenticated', () {
      test('then calling an annotated method returns user not signed in',
          () async {
        final signedIn =
            await client.partiallyUnauthenticated.unauthenticatedMethod();

        expect(signedIn, isFalse);
      });

      test(
          'then calling an annotated streaming method returns user not signed in',
          () async {
        final signedIn =
            await client.partiallyUnauthenticated.unauthenticatedStream().first;

        expect(signedIn, isFalse);
      });

      test('then calling a non-annotated method returns user signed in',
          () async {
        final signedIn =
            await client.partiallyUnauthenticated.authenticatedMethod();

        expect(signedIn, isTrue);
      });

      test(
          'then calling a non-annotated streaming method returns user signed in',
          () async {
        final signedIn =
            await client.partiallyUnauthenticated.authenticatedStream().first;

        expect(signedIn, isTrue);
      });
    });
  });
}

import 'dart:async';

import 'package:serverpod_client/serverpod_client.dart';
import 'package:test/test.dart';

void main() {
  late TestMutexRefresherAuthKeyProvider provider;

  setUp(() {
    provider = TestMutexRefresherAuthKeyProvider();
  });

  group(
      'Given a request for authHeaderValue on a mutex protected auth key provider',
      () {
    test(
      'when shouldRefreshKey is false, '
      'then returns notMutexLockedAuthHeaderValue without refresh.',
      () async {
        provider.setAuthKey('initial-token');
        provider.setShouldRefreshKey(false);

        final result = await provider.authHeaderValue;

        expect(result, 'initial-token');
        expect(provider.performRefreshCallCount, 0);
      },
    );

    test(
      'when shouldRefreshKey is true, '
      'then performs refresh and returns updated value.',
      () async {
        provider.setAuthKey('initial-token');
        provider.setShouldRefreshKey(true);
        provider.setRefreshResult(true);

        final result = await provider.authHeaderValue;

        expect(result, 'refreshed-token-1');
        expect(provider.performRefreshCallCount, 1);
      },
    );

    test(
      'when shouldRefreshKey is true and refresh fails, '
      'then returns original notMutexLockedAuthHeaderValue.',
      () async {
        provider.setAuthKey('initial-token');
        provider.setShouldRefreshKey(true);
        provider.setRefreshResult(false);

        final result = await provider.authHeaderValue;

        expect(result, 'initial-token');
        expect(provider.performRefreshCallCount, 1);
      },
    );
  });

  group('Given a call to refreshAuthKey on a mutex protected auth key provider',
      () {
    test(
      'when force is false and shouldRefreshKey is false, '
      'then returns false without calling performRefresh.',
      () async {
        provider.setShouldRefreshKey(false);

        final result = await provider.refreshAuthKey(force: false);

        expect(result, false);
        expect(provider.performRefreshCallCount, 0);
        expect(await provider.notMutexLockedAuthHeaderValue, isNull);
      },
    );

    test(
      'when force is true, '
      'then calls performRefresh regardless of shouldRefreshKey.',
      () async {
        provider.setShouldRefreshKey(false);
        provider.setRefreshResult(true);

        final result = await provider.refreshAuthKey(force: true);

        expect(result, true);
        expect(provider.performRefreshCallCount, 1);
        expect(
            await provider.notMutexLockedAuthHeaderValue, 'refreshed-token-1');
      },
    );

    test(
      'when shouldRefreshKey is true, '
      'then calls performRefresh and returns its result.',
      () async {
        provider.setShouldRefreshKey(true);
        provider.setRefreshResult(true);

        final result = await provider.refreshAuthKey();

        expect(result, true);
        expect(provider.performRefreshCallCount, 1);
        expect(
            await provider.notMutexLockedAuthHeaderValue, 'refreshed-token-1');
      },
    );

    test(
      'when shouldRefreshKey is true and performRefresh returns false, '
      'then returns false.',
      () async {
        provider.setShouldRefreshKey(true);
        provider.setRefreshResult(false);

        final result = await provider.refreshAuthKey();

        expect(result, false);
        expect(provider.performRefreshCallCount, 1);
        expect(await provider.notMutexLockedAuthHeaderValue, isNull);
      },
    );
  });

  group(
      'Given concurrent calls to refreshAuthKey on a mutex protected auth key provider',
      () {
    test(
      'when multiple refreshAuthKey calls are made concurrently, '
      'then only one call performs refresh due to locking.',
      () async {
        provider.setShouldRefreshKey(true);
        provider.setRefreshResult(true);
        provider.setRefreshDelay(const Duration(milliseconds: 50));

        final futures = List.generate(3, (_) => provider.refreshAuthKey());
        final results = await Future.wait(futures);

        expect(results, everyElement(true));
        expect(provider.performRefreshCallCount, 1);
      },
    );

    test(
      'when multiple authHeaderValue calls are made concurrently, '
      'then only one call performs refresh due to locking.',
      () async {
        provider.setAuthKey('initial-token');
        provider.setShouldRefreshKey(true);
        provider.setRefreshResult(true);
        provider.setRefreshDelay(const Duration(milliseconds: 50));

        final futures = List.generate(3, (_) => provider.authHeaderValue);
        final results = await Future.wait(futures);

        expect(results, everyElement('refreshed-token-1'));
        expect(provider.performRefreshCallCount, 1);
      },
    );

    test(
      'when refresh is already in progress and new call is made, '
      'then waits for existing refresh to complete and no new refresh is started.',
      () async {
        provider.setShouldRefreshKey(true);
        provider.setRefreshResult(true);
        provider.setRefreshDelay(const Duration(milliseconds: 200));

        final firstRefresh = provider.refreshAuthKey();
        await Future.delayed(const Duration(milliseconds: 50));

        final secondRefresh = provider.refreshAuthKey();
        final results = await Future.wait([firstRefresh, secondRefresh]);

        expect(results, [true, true]);
        expect(provider.performRefreshCallCount, 1);
      },
    );

    test(
      'when multiple refreshAuthKey calls are made concurrently and refresh fails, '
      'then all calls return false and no new refresh is started.',
      () async {
        provider.setShouldRefreshKey(true);
        provider.setRefreshResult(false);
        provider.setRefreshDelay(const Duration(milliseconds: 50));

        final futures = List.generate(3, (_) => provider.refreshAuthKey());
        final results = await Future.wait(futures);

        expect(results, everyElement(false));
        expect(provider.performRefreshCallCount, 1);
      },
    );
  });

  group(
      'Given failed refresh operations on a mutex protected auth key provider',
      () {
    test(
      'when performRefresh throws an exception, '
      'then refreshAuthKey rethrows the exception.',
      () async {
        provider.setShouldRefreshKey(true);
        provider.setRefreshException(Exception('Refresh failed'));

        await expectLater(provider.refreshAuthKey(), throwsA(isA<Exception>()));
        expect(provider.performRefreshCallCount, 1);
      },
    );

    test(
      'when performRefresh throws an exception, '
      'then authHeaderValue rethrows the exception.',
      () async {
        provider.setAuthKey('initial-token');
        provider.setShouldRefreshKey(true);
        provider.setRefreshException(Exception('Refresh failed'));

        await expectLater(provider.authHeaderValue, throwsA(isA<Exception>()));
        expect(provider.performRefreshCallCount, 1);
      },
    );

    test(
      'when performRefresh throws exception during concurrent calls, '
      'then all calls receive the same exception.',
      () async {
        provider.setShouldRefreshKey(true);
        provider.setRefreshException(Exception('Refresh failed'));
        provider.setRefreshDelay(const Duration(milliseconds: 50));

        final futures = List.generate(3, (_) => provider.refreshAuthKey());
        for (final future in futures) {
          await expectLater(future, throwsA(isA<Exception>()));
        }
        expect(provider.performRefreshCallCount, 1);
      },
    );

    test(
      'when refresh fails and then succeeds, '
      'then subsequent calls work correctly.',
      () async {
        provider.setShouldRefreshKey(true);
        provider.setRefreshException(Exception('First refresh failed'));

        await expectLater(provider.refreshAuthKey(), throwsA(isA<Exception>()));

        provider.setShouldRefreshKey(true);
        provider.setRefreshResult(true);
        provider.setRefreshException(null);

        final result = await provider.refreshAuthKey();
        expect(result, true);
        expect(provider.performRefreshCallCount, 2);
      },
    );
  });
}

/// Test implementation of MutexRefresherClientAuthKeyProvider for unit testing.
class TestMutexRefresherAuthKeyProvider
    extends MutexRefresherClientAuthKeyProvider {
  String? _authKey;
  bool _shouldRefreshKey = false;
  bool _refreshResult = true;
  Exception? _refreshException;
  Duration _refreshDelay = Duration.zero;
  int performRefreshCallCount = 0;

  void setAuthKey(String? key) => _authKey = key;
  void setShouldRefreshKey(bool should) => _shouldRefreshKey = should;
  void setRefreshResult(bool result) => _refreshResult = result;
  void setRefreshException(Exception? exc) => _refreshException = exc;
  void setRefreshDelay(Duration delay) => _refreshDelay = delay;

  @override
  Future<String?> get notMutexLockedAuthHeaderValue async => _authKey;

  @override
  Future<bool> get shouldRefreshKey async => _shouldRefreshKey;

  @override
  Future<bool> performRefresh() async {
    performRefreshCallCount++;
    if (_refreshDelay > Duration.zero) await Future.delayed(_refreshDelay);
    if (_refreshException != null) throw _refreshException!;
    if (_refreshResult) _authKey = 'refreshed-token-$performRefreshCallCount';
    _shouldRefreshKey = false;
    return _refreshResult;
  }
}

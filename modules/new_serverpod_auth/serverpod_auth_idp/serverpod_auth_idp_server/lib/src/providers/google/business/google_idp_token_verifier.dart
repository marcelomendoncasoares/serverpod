import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:http/http.dart' as http;
import 'package:jose/jose.dart';

/// Utility class for verifying Google ID tokens.
///
/// This implementation follows the pattern from Google's official
/// google-auth-library-python, specifically the `verify_oauth2_token` method.
/// For reference, see:
/// https://github.com/googleapis/google-auth-library-python/blob/main/google/oauth2/id_token.py
class GoogleIdTokenVerifier {
  /// The URL that provides public certificates for verifying ID tokens issued
  /// by Google's OAuth 2.0 authorization server.
  static const String _certsUrl = 'https://www.googleapis.com/oauth2/v3/certs';

  /// Valid Google issuers for OAuth 2.0 tokens.
  static const List<String> _googleIssuers = [
    'accounts.google.com',
    'https://accounts.google.com',
  ];

  /// How long before the cache should be updated again.
  static const _cacheExpirationInterval = Duration(hours: 1);

  /// Interval between failed cache update attempts.
  static const _cacheUpdateFailedInterval = Duration(minutes: 10);

  /// Maximum number of failed attempts to update the cache before giving up.
  static const _cacheUpdateMaxFailedAttempts = 5;

  /// Cached key set for Google ID tokens.
  static _CachedKeySet _cachedKeySet = _CachedKeySet(null);

  /// Mutex lock to prevent concurrent cache updates.
  static Future<void>? _ongoingCacheUpdate;

  /// Verifies an ID Token issued by Google's OAuth 2.0 authorization server.
  ///
  /// 1. Decodes and verifies the JWT signature
  /// 2. Validates standard claims (exp, iat, aud, sub)
  /// 3. Validates the issuer is from Google
  ///
  /// The [audience] parameter represent the client ID of the application that
  /// the ID token is intended for. If null then the audience is not verified.
  /// Can throw [GoogleIdTokenValidationServerException] in case of any validation
  /// failures.
  static Future<Map<String, dynamic>> verifyOAuth2Token(
    final String idToken, {
    final String? audience,
    final int clockSkewInSeconds = 0,
  }) async {
    final idInfo = await _verifyToken(
      idToken,
      audience: audience,
      clockSkewInSeconds: clockSkewInSeconds,
    );

    final issuer = idInfo['iss'] as String?;
    if (issuer == null || !_googleIssuers.contains(issuer)) {
      throw GoogleIdTokenValidationServerException('Invalid issuer');
    }

    return idInfo;
  }

  /// Internal method to verify token signature and basic claims.
  static Future<Map<String, dynamic>> _verifyToken(
    final String idToken, {
    final String? audience,
    final int clockSkewInSeconds = 0,
  }) async {
    final keyStore = await _getKeyStore();
    final jwt = await JsonWebToken.decodeAndVerify(
      idToken,
      keyStore,
    );

    _validateClaims(
      jwt.claims,
      audience: audience,
      clockSkewInSeconds: clockSkewInSeconds,
    );
    return jwt.claims.toJson();
  }

  /// Fetches Google's public certificates for JWT verification.
  ///
  /// Certificates are cached for 1 hour to reduce network requests. If the
  /// request fails, the cache update is postponed for 10 minutes up to 5 times.
  /// If the request fails 5 times, throws [GoogleIdTokenValidationServerException].
  static Future<JsonWebKeyStore> _getKeyStore() async {
    if (!_cachedKeySet.shouldUpdate) {
      return _cachedKeySet.toKeyStore();
    }

    final ongoingCacheUpdate = _ongoingCacheUpdate;
    if (ongoingCacheUpdate != null) {
      await ongoingCacheUpdate;
      return _cachedKeySet.toKeyStore();
    }

    _ongoingCacheUpdate = _updateCachedKeySet();
    await _ongoingCacheUpdate;
    _ongoingCacheUpdate = null;
    return _cachedKeySet.toKeyStore();
  }

  static Future<void> _updateCachedKeySet() async {
    final response = await http.get(Uri.parse(_certsUrl));
    if (response.statusCode != 200) {
      if (_cachedKeySet.postponeExpiration()) return;
      throw GoogleIdTokenValidationServerException(
          'Failed to fetch certificates');
    }

    final newCachedKeySet = JsonWebKeySet.fromJson(jsonDecode(response.body));
    _cachedKeySet = _CachedKeySet(newCachedKeySet);
  }

  static void _validateClaims(
    final JsonWebTokenClaims claims, {
    final String? audience,
    final int clockSkewInSeconds = 0,
  }) {
    final now = const Clock().now();
    final clockSkew = Duration(seconds: clockSkewInSeconds);

    if (claims.expiry == null || claims.expiry!.add(clockSkew).isBefore(now)) {
      throw GoogleIdTokenValidationServerException('Token expired');
    }

    if (claims.issuedAt == null ||
        claims.issuedAt!.subtract(clockSkew).isAfter(now)) {
      throw GoogleIdTokenValidationServerException('Invalid issued at time');
    }

    if (audience != null && !(claims.audience?.contains(audience) ?? false)) {
      throw GoogleIdTokenValidationServerException('Audience does not match');
    }

    if (claims.subject == null || claims.subject!.isEmpty) {
      throw GoogleIdTokenValidationServerException('Missing subject');
    }
  }
}

/// Cached key set for Google ID tokens.
///
/// Controls the logic for updating the cache, checking if it should be updated,
/// and providing a [JsonWebKeyStore] for verification.
class _CachedKeySet {
  final JsonWebKeySet? _keySet;
  DateTime expiry;
  int failedAttempts = 0;

  _CachedKeySet(this._keySet) : expiry = _newExpiry();

  static DateTime _newExpiry({final bool postpone = false}) {
    final interval = postpone
        ? GoogleIdTokenVerifier._cacheUpdateFailedInterval
        : GoogleIdTokenVerifier._cacheExpirationInterval;
    return DateTime.now().add(interval);
  }

  bool get shouldUpdate =>
      _keySet == null ||
      _keySet.keys.isEmpty ||
      expiry.isBefore(DateTime.now());

  bool postponeExpiration() {
    if (failedAttempts >= GoogleIdTokenVerifier._cacheUpdateMaxFailedAttempts) {
      return false;
    }
    expiry = _newExpiry(postpone: true);
    failedAttempts++;
    return true;
  }

  JsonWebKeyStore toKeyStore() {
    final keys = _keySet?.keys;
    if (keys == null) {
      throw StateError('No JsonWebKeySet available');
    }

    final keyStore = JsonWebKeyStore();
    for (final key in keys) {
      keyStore.addKey(key);
    }
    return keyStore;
  }
}

/// Exception thrown when the Google ID token validation fails.
class GoogleIdTokenValidationServerException implements Exception {
  /// The exception message that was thrown.
  final String message;

  /// Creates a new instance.
  GoogleIdTokenValidationServerException(this.message);
}

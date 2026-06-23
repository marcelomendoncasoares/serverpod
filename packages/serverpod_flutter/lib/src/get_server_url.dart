import 'dart:convert';

import 'package:flutter/services.dart';

import 'localhost.dart';

Future<String?> _readApiUrlFromAsset(String assetPath) async {
  try {
    final data = await rootBundle.loadString(assetPath);
    final config = jsonDecode(data) as Map<String, dynamic>;
    return config['apiUrl'] as String?;
  } catch (_) {
    return null;
  }
}

/// Gets the Server URL from the current environment.
///
/// If the `SERVER_URL` compilation environment declaration is set, it will be
/// used as the API server URL. Otherwise, it will be loaded from the web app's
/// `assets/config_override.json` (when present) or `assets/config.json` file.
///
/// When the web app is hosted on the server, the `assets/config.json` file is
/// fetched from the server, allowing the server to change the API URL at
/// runtime. This ensures the app always uses the correct API URL, no matter
/// which environment it is running in.
Future<String> getServerUrl() async {
  const serverUrlFromEnv = String.fromEnvironment('SERVER_URL');
  if (serverUrlFromEnv.isNotEmpty) {
    return serverUrlFromEnv;
  }

  final overrideUrl = await _readApiUrlFromAsset('assets/config_override.json');
  if (overrideUrl != null && overrideUrl.isNotEmpty) {
    return overrideUrl;
  }

  final configUrl = await _readApiUrlFromAsset('assets/config.json');
  if (configUrl != null && configUrl.isNotEmpty) {
    return configUrl;
  }

  return 'http://$localhost:8080/';
}

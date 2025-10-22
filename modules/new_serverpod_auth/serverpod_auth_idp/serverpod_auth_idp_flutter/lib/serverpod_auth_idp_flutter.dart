/// Provides authentication UI widgets for Serverpod applications.
///
/// This library allows developers to integrate authentication flows with various
/// identity providers (email, Google, Apple) into their Flutter apps. It works
/// with the Serverpod auth system and provides ready-to-use UI components.
library;

// Convenience export of the core auth package.
export 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';

export 'src/config.dart';
export 'src/theme.dart';
export 'src/email/email_auth_controller.dart';
export 'src/email/email_sign_in_widget.dart';
export 'src/google/google_auth_controller.dart';
export 'src/google/google_sign_in_service.dart';
export 'src/google/google_sign_in_widget.dart';
export 'src/onboarding/auth_onboarding_widget.dart';

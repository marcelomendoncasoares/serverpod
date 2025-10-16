import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

/// Theme for the authentication identity provider UI.
@immutable
class AuthIdpTheme extends ThemeExtension<AuthIdpTheme> {
  final PinTheme defaultPinTheme;
  final PinTheme focusedPinTheme;
  final PinTheme errorPinTheme;

  const AuthIdpTheme({
    required this.defaultPinTheme,
    required this.focusedPinTheme,
    required this.errorPinTheme,
  });

  factory AuthIdpTheme.defaultTheme({
    PinTheme? defaultPinTheme,
    PinTheme? focusedPinTheme,
    PinTheme? errorPinTheme,
  }) {
    defaultPinTheme = defaultPinTheme ??
        PinTheme(
          width: 56,
          height: 60,
          decoration: BoxDecoration(
            color: Color.fromRGBO(222, 231, 240, .57),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.transparent),
          ),
        );

    focusedPinTheme = focusedPinTheme ??
        defaultPinTheme.copyWith(
          height: 68,
          decoration: defaultPinTheme.decoration!.copyWith(
            border: Border.all(color: Colors.black, width: 1),
          ),
        );

    errorPinTheme = errorPinTheme ??
        defaultPinTheme.copyWith(
          decoration: BoxDecoration(
            color: Color.fromRGBO(238, 74, 104, 1),
            borderRadius: BorderRadius.circular(8),
          ),
        );

    return AuthIdpTheme(
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      errorPinTheme: errorPinTheme,
    );
  }

  @override
  AuthIdpTheme copyWith({
    PinTheme? defaultPinTheme,
    PinTheme? focusedPinTheme,
    PinTheme? errorPinTheme,
  }) {
    return AuthIdpTheme(
      defaultPinTheme: defaultPinTheme ?? this.defaultPinTheme,
      focusedPinTheme: focusedPinTheme ?? this.focusedPinTheme,
      errorPinTheme: errorPinTheme ?? this.errorPinTheme,
    );
  }

  @override
  AuthIdpTheme lerp(ThemeExtension<AuthIdpTheme>? other, double t) {
    if (other is! AuthIdpTheme) return this;
    return t < 0.5 ? this : other;
  }
}

extension IdpTheme on ThemeData {
  /// Use the [AuthIdpTheme] extension on [ThemeData] to access the theme.
  ///
  /// ```dart
  /// Theme.of(context).idpTheme
  /// ```
  AuthIdpTheme get idpTheme =>
      extension<AuthIdpTheme>() ?? AuthIdpTheme.defaultTheme();
}

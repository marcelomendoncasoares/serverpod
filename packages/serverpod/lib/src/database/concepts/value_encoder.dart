/// Interface for value encoders.
abstract interface class ValueEncoder {
  /// Converts an object to a string.
  String convert(
    Object? input, {
    bool escapeStrings = true,
    bool hasDefaults = false,
  });

  /// Tries to convert an object to a string.
  /// Returns `null` if the conversion fails.
  String? tryConvert(Object? input, {bool escapeStrings = false});
}

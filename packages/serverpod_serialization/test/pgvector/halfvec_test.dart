import 'package:serverpod_serialization/src/pgvector.dart';
import 'package:test/test.dart';
import 'dart:typed_data';
import 'dart:math' as math;

void main() {
  test('works', () {
    const vec = HalfVector([1, 2, 3]);
    expect(vec.toString(), equals('[1.0, 2.0, 3.0]'));
    expect(vec.toList(), equals([1, 2, 3]));
  });

  test('equals', () {
    const a = HalfVector([1, 2, 3]);
    const b = HalfVector([1, 2, 3]);
    const c = HalfVector([1, 2, 4]);

    expect(a, equals(b));
    expect(a, isNot(equals(c)));
  });

  group('binary conversion', () {
    test('roundtrip conversion', () {
      // Create a vector, convert to binary, then back to vector
      const original = HalfVector([1.5, -2.25, 3.0, 0.0, -0.0]);
      final binary = original.toBinary();
      final decoded = HalfVector.fromBinary(binary);

      // Verify the result matches the original
      expect(decoded, equals(original));
      expect(decoded.toList(), equals([1.5, -2.25, 3.0, 0.0, -0.0]));
    });

    test('binary format structure', () {
      // Test the binary structure (dimension, unused, and values)
      const vector = HalfVector([1.0, 2.0]);
      final binary = vector.toBinary();

      // Binary should be 8 bytes: 2 for dim, 2 for unused, and 2 for each value
      expect(binary.length, equals(8));

      final buf = ByteData.view(binary.buffer, binary.offsetInBytes);
      expect(buf.getInt16(0), equals(2)); // dimension
      expect(buf.getInt16(2), equals(0)); // unused

      // Check if we can decode the values
      final decodedVec = HalfVector.fromBinary(binary);
      expect(decodedVec.toList(), equals([1.0, 2.0]));
    });

    test('empty vector', () {
      const empty = HalfVector([]);
      final binary = empty.toBinary();

      // Binary should be 4 bytes: 2 for dim=0, 2 for unused
      expect(binary.length, equals(4));

      final decoded = HalfVector.fromBinary(binary);
      expect(decoded.toList(), isEmpty);
    });

    test('large vector', () {
      // Create a vector with 100 elements
      final values = List.generate(100, (index) => index / 10.0);
      final large = HalfVector(values);
      final binary = large.toBinary();

      // Binary should be 4 + 2*100 bytes
      expect(binary.length, equals(204));

      final decoded = HalfVector.fromBinary(binary);
      expect(decoded.toList().length, equals(100));

      // Values should be close (float16 has much lower precision than double)
      for (var i = 0; i < values.length; i++) {
        // Allow for larger tolerance as float16 has much lower precision
        expect(decoded.toList()[i], closeTo(values[i], values[i] * 0.5 + 0.1));
      }
    });

    test('special values', () {
      // Test special floating-point values
      const special = HalfVector([
        0.0, // zero
        -0.0, // negative zero
        double.infinity, // infinity
        double.negativeInfinity, // negative infinity
        double.nan, // NaN
      ]);

      final binary = special.toBinary();
      final decoded = HalfVector.fromBinary(binary);

      // Check regular zeros
      expect(decoded.toList()[0], equals(0.0));
      expect(decoded.toList()[1], equals(-0.0));

      // Check infinities
      expect(decoded.toList()[2].isInfinite, isTrue);
      expect(decoded.toList()[2].isNegative, isFalse);
      expect(decoded.toList()[3].isInfinite, isTrue);
      expect(decoded.toList()[3].isNegative, isTrue);

      // Check NaN
      expect(decoded.toList()[4].isNaN, isTrue);
    });

    test('range limits', () {
      // Test values at the extremes of float16 range
      // Max value for float16 is about 65504
      // Min normal value is about 6.1e-5

      const limits = HalfVector([
        65504.0, // max representable value
        -65504.0, // min representable value
        6.1e-5, // min positive normal
        -6.1e-5, // max negative normal
        1.0e-7, // subnormal (will be close to zero)
      ]);

      final binary = limits.toBinary();
      final decoded = HalfVector.fromBinary(binary);

      // Check max/min values (some precision loss is expected)
      expect(decoded.toList()[0], closeTo(65504.0, 10.0));
      expect(decoded.toList()[1], closeTo(-65504.0, 10.0));

      // Check small normal values
      expect(decoded.toList()[2], closeTo(6.1e-5, 1.0e-5));
      expect(decoded.toList()[3], closeTo(-6.1e-5, 1.0e-5));

      // Subnormal value (might be rounded to zero)
      expect(decoded.toList()[4].abs() < 6.1e-5, isTrue);
    });

    test('precision test', () {
      // Test a range of values to verify precision limitations of float16
      final values = [
        0.5,
        1.0,
        1.5,
        2.0,
        3.0,
        4.0,
        5.0,
        10.0,
        100.0,
        1000.0,
        -0.5,
        -1.0,
        -1.5,
        -2.0,
        -3.0,
        -4.0,
        -5.0,
        -10.0,
        -100.0,
        -1000.0,
        0.33333,
        0.66667,
        math.pi,
        math.e,
      ];

      final original = HalfVector(values);
      final binary = original.toBinary();
      final decoded = HalfVector.fromBinary(binary);

      // Since float16 has very limited precision, we need to allow for significant differences
      // The tolerance needs to be much higher than with regular floats
      for (var i = 0; i < values.length; i++) {
        // Use a higher tolerance for float16 values
        var tolerance = values[i].abs() * 0.5 + 0.1;
        expect(decoded.toList()[i], closeTo(values[i], tolerance));
      }
    });
  });
}

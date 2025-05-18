import 'dart:typed_data';
import 'dart:math' as math;
import 'utils.dart';

class HalfVector {
  final List<double> _vec;

  const HalfVector(this._vec);

  factory HalfVector.fromBinary(Uint8List bytes) {
    var buf = new ByteData.view(bytes.buffer, bytes.offsetInBytes);
    var dim = buf.getInt16(0);

    var unused = buf.getInt16(2);
    if (unused != 0) {
      throw FormatException('expected unused to be 0');
    }

    var vec = <double>[];
    for (var i = 0; i < dim; i++) {
      // Read half-precision float (16-bit) and convert to double
      int halfFloat = buf.getUint16(4 + i * 2);
      vec.add(_halfToFloat(halfFloat));
    }

    return HalfVector(vec);
  }

  Uint8List toBinary() {
    var dim = _vec.length;
    var bytes = new Uint8List(4 + 2 * dim); // 2 bytes per float16 value
    var buf = new ByteData.view(bytes.buffer, bytes.offsetInBytes);

    buf.setInt16(0, dim);
    buf.setInt16(2, 0);

    for (var i = 0; i < dim; i++) {
      // Convert double to half-precision float (16-bit)
      int halfFloat = _floatToHalf(_vec[i]);
      buf.setUint16(4 + i * 2, halfFloat);
    }

    return bytes;
  }

  // Convert half-precision float (16-bit) to double
  static double _halfToFloat(int half) {
    // Extract sign, exponent, and mantissa
    final sign = (half >> 15) & 0x1;
    final exponent = (half >> 10) & 0x1F;
    final mantissa = half & 0x3FF;

    // Special cases
    if (exponent == 0) {
      if (mantissa == 0) return sign == 0 ? 0.0 : -0.0;
      // Denormalized half
      final value = mantissa * 5.960464477539063e-8; // 2^-24
      return sign == 0 ? value : -value;
    } else if (exponent == 31) {
      if (mantissa == 0)
        return sign == 0 ? double.infinity : double.negativeInfinity;
      return double.nan;
    }

    // Normalized number - fixed the bit shifting operation
    double value = (1.0 + mantissa / 1024.0);
    if (exponent < 15) {
      value = value / (1 << (15 - exponent));
    } else {
      value = value * (1 << (exponent - 15));
    }
    return sign == 0 ? value : -value;
  }

  // Convert double to half-precision float (16-bit)
  static int _floatToHalf(double value) {
    // Handle special cases
    if (value.isNaN) return 0x7FFF;
    if (value.isInfinite) return value.isNegative ? 0xFC00 : 0x7C00;
    if (value == 0) return value.isNegative ? 0x8000 : 0x0000;

    // Extract components from float
    final sign = value < 0 ? 1 : 0;
    value = value.abs();

    // Handle values too small for half float
    if (value < 6.103515625e-5) {
      // 2^-14
      // Return subnormal value
      int mantissa = (value / 5.960464477539063e-8).round();
      if (mantissa > 1023) mantissa = 1023; // Cap at max subnormal value
      return (sign << 15) | mantissa;
    }

    // Handle values too large for half float
    if (value > 65504.0) {
      // max representable value
      return (sign << 15) | 0x7C00;
    }

    int exponent;
    double mantissa;

    if (value >= 1.0) {
      // Normalized values
      exponent = (math.log(value) / math.log(2)).floor();
      mantissa = value / (1 << exponent) - 1.0;
    } else {
      // Find the exponent
      exponent = -1;
      double temp = value;
      while (temp < 1.0) {
        temp *= 2.0;
        exponent--;
      }
      mantissa = temp - 1.0;
    }

    final halfExponent = exponent + 15;
    final halfMantissa = (mantissa * 1024.0 + 0.5).floor();

    return (sign << 15) |
        ((halfExponent & 0x1F) << 10) |
        (halfMantissa & 0x3FF);
  }

  List<double> toList() {
    return _vec;
  }

  @override
  String toString() {
    return _vec.toString();
  }

  @override
  bool operator ==(Object other) =>
      other is HalfVector && listEquals(other._vec, _vec);

  @override
  int get hashCode => _vec.hashCode;
}

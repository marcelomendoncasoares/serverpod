import 'package:serverpod_serialization/serverpod_serialization.dart';

class CustomClass implements SerializableModel {
  final String value;

  CustomClass(this.value);

  @override
  String toJson() => value;

  factory CustomClass.fromJson(dynamic data) {
    return CustomClass(data);
  }

  CustomClass copyWith() => this;
}

class IntCustomClass implements SerializableModel {
  final int value;

  IntCustomClass(this.value);

  @override
  int toJson() => value;

  factory IntCustomClass.fromJson(dynamic data) {
    return IntCustomClass(data as int);
  }

  IntCustomClass copyWith() => this;
}

class DoubleCustomClass implements SerializableModel {
  final double value;

  DoubleCustomClass(this.value);

  @override
  double toJson() => value;

  factory DoubleCustomClass.fromJson(dynamic data) {
    return DoubleCustomClass((data as num).toDouble());
  }

  DoubleCustomClass copyWith() => this;
}

class BoolCustomClass implements SerializableModel {
  final bool value;

  BoolCustomClass(this.value);

  @override
  bool toJson() => value;

  factory BoolCustomClass.fromJson(dynamic data) {
    return BoolCustomClass(data as bool);
  }

  BoolCustomClass copyWith() => this;
}

class DateTimeCustomClass implements SerializableModel {
  final DateTime value;

  DateTimeCustomClass(this.value);

  @override
  DateTime toJson() => value;

  factory DateTimeCustomClass.fromJson(dynamic data) {
    return DateTimeCustomClass(DateTimeJsonExtension.fromJson(data));
  }

  DateTimeCustomClass copyWith() => this;
}

class CustomClass2 {
  final String value;

  const CustomClass2(this.value);

  factory CustomClass2.fromJson(dynamic data) {
    return CustomClass2(data['text']);
  }

  dynamic toJson() => {'text': value};

  CustomClass2 copyWith() => this;
}

class CustomClassWithoutProtocolSerialization {
  final String? serverSideValue;
  final String? value;

  CustomClassWithoutProtocolSerialization({this.serverSideValue, this.value});

  Map<String, dynamic> toJson() => {
    'serverSideValue': serverSideValue,
    'value': value,
  };

  CustomClassWithoutProtocolSerialization copyWith() => this;

  factory CustomClassWithoutProtocolSerialization.fromJson(
    Map<String, dynamic> data,
  ) {
    return CustomClassWithoutProtocolSerialization(
      serverSideValue: data['serverSideValue'] as String?,
      value: data['value'] as String?,
    );
  }
}

class CustomClassWithProtocolSerialization implements ProtocolSerialization {
  final String? serverSideValue;
  final String? value;

  CustomClassWithProtocolSerialization({this.serverSideValue, this.value});

  Map<String, dynamic> toJson() => {
    'serverSideValue': serverSideValue,
    'value': value,
  };

  @override
  Map<String, dynamic> toJsonForProtocol() => {'value': value};

  CustomClassWithProtocolSerialization copyWith() => this;

  factory CustomClassWithProtocolSerialization.fromJson(
    Map<String, dynamic> data,
  ) {
    return CustomClassWithProtocolSerialization(
      serverSideValue: data['serverSideValue'] as String?,
      value: data['value'] as String?,
    );
  }
}

/// Custom class that does not implement ProtocolSerialization but has the
/// "toJsonForProtocol" method.
class CustomClassWithProtocolSerializationMethod {
  final String? serverSideValue;
  final String? value;

  CustomClassWithProtocolSerializationMethod({
    this.serverSideValue,
    this.value,
  });

  Map<String, dynamic> toJson() => {
    'serverSideValue': serverSideValue,
    'value': value,
  };

  Map<String, dynamic> toJsonForProtocol() => {'value': value};

  CustomClassWithProtocolSerializationMethod copyWith() => this;

  factory CustomClassWithProtocolSerializationMethod.fromJson(
    Map<String, dynamic> data,
  ) {
    return CustomClassWithProtocolSerializationMethod(
      serverSideValue: data['serverSideValue'] as String?,
      value: data['value'] as String?,
    );
  }
}

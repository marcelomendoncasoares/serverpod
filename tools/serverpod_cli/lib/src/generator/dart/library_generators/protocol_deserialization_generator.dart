import 'package:code_builder/code_builder.dart';

/// Generates immutable type declarations and ordered module fallback.
class ProtocolDeserializationGenerator {
  final String runtimeUrl;

  ProtocolDeserializationGenerator({required this.runtimeUrl});

  Reference provider({String? databaseRuntimeUrl}) {
    if (databaseRuntimeUrl != null) {
      return refer(
        'DatabaseProtocolDeserializationProvider',
        databaseRuntimeUrl,
      );
    }
    return refer('ProtocolDeserializationProvider', runtimeUrl);
  }

  Field metadata({
    required Iterable<Expression> types,
    required List<Expression> modules,
  }) {
    return Field(
      (f) => f
        ..annotations.add(refer('override'))
        ..name = 'deserializationMetadata'
        ..late = true
        ..modifier = FieldModifier.final$
        ..type = refer('ProtocolDeserialization', runtimeUrl)
        ..assignment = refer('ProtocolDeserialization', runtimeUrl).newInstance(
          [],
          {
            'types': literalList(types.toList(), refer('Type')),
            'modules': literalList(modules),
          },
        ).code,
    );
  }

  Code moduleFallback() {
    return Code.scope(
      (a) =>
          '''
      final modules = dataClassName == null
          ? deserializationMetadata.modulesForType(t)
          : deserializationMetadata.modules;
      for (final module in modules) {
        try {
          return module.deserialize<T>(data, t);
        } on ${a(refer('DeserializationTypeNotFoundException', runtimeUrl))} catch (_) {}
      }
      ''',
    );
  }
}

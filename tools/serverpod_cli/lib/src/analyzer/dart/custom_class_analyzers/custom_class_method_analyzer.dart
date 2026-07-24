import 'package:analyzer/dart/element/element.dart';
import 'package:serverpod_cli/src/analyzer/code_analysis_collector.dart';
import 'package:serverpod_cli/src/analyzer/dart/element_extensions.dart';
import 'package:serverpod_cli/src/generator/types.dart';

import '../../../util/type_validators.dart';

class CustomClassMethodValidationResult {
  final List<SourceSpanSeverityException> errors;
  final TypeDefinition? serializationType;

  const CustomClassMethodValidationResult({
    required this.errors,
    this.serializationType,
  });
}

class _ToJsonValidationResult {
  final SourceSpanSeverityException? error;
  final TypeDefinition? serializationType;

  const _ToJsonValidationResult({this.error, this.serializationType});
}

abstract class CustomClassMethodAnalyzer {
  /// Validates that the [InterfaceElement] Class implements the
  /// required methods for a Serverpod custom class.
  static CustomClassMethodValidationResult validate(
    InterfaceElement element,
    TypeDefinition extraClass,
    LibraryElement library,
  ) {
    final toJsonResult = _validateToJson(element, extraClass, library);
    final fromJsonError = _validateFromJson(element, extraClass);

    final errors = <SourceSpanSeverityException>[
      ?toJsonResult.error,
      ?fromJsonError,
    ];

    return CustomClassMethodValidationResult(
      errors: errors,
      serializationType: toJsonResult.serializationType,
    );
  }

  static _ToJsonValidationResult _validateToJson(
    InterfaceElement element,
    TypeDefinition extraClass,
    LibraryElement library,
  ) {
    final toJson = element.lookUpMethod(name: 'toJson', library: library);

    if (toJson == null) {
      return _ToJsonValidationResult(
        error: SourceSpanSeverityException(
          'Custom class "${extraClass.className}" is missing a "toJson()" method.',
          element.span,
          severity: SourceSpanSeverity.error,
        ),
      );
    }

    if (toJson.isStatic) {
      return _ToJsonValidationResult(
        error: SourceSpanSeverityException(
          'The "toJson()" method in "${extraClass.className}" must be an instance method.',
          toJson.span,
          severity: SourceSpanSeverity.error,
        ),
      );
    }

    final returnType = toJson.returnType;

    if (returnType.isDartAsyncFuture || returnType.isDartAsyncStream) {
      return _ToJsonValidationResult(
        error: SourceSpanSeverityException(
          'The "toJson()" method in "${extraClass.className}" must be synchronous.',
          toJson.span,
          severity: SourceSpanSeverity.error,
        ),
      );
    }

    final TypeDefinition typeDefinition;
    try {
      typeDefinition = TypeDefinition.fromDartType(returnType);
    } on FromDartTypeClassNameException catch (e) {
      return _ToJsonValidationResult(
        error: SourceSpanSeverityException(
          'The type "${e.type}" is not a supported "toJson()" return type.',
          toJson.span,
          severity: SourceSpanSeverity.error,
        ),
      );
    }

    if (typeDefinition.isVoidType) {
      return _ToJsonValidationResult(
        error: SourceSpanSeverityException(
          'The "toJson()" method in "${extraClass.className}" cannot return void.',
          toJson.span,
          severity: SourceSpanSeverity.error,
        ),
      );
    }

    if (!TypeValidators.isValidType(
      typeDefinition,
      const TypeValidationOptions(
        allowSerializableGenerics: true,
      ),
    )) {
      return _ToJsonValidationResult(
        error: SourceSpanSeverityException(
          'The type "${typeDefinition.className}" is not a supported '
          '"toJson()" return type.',
          toJson.span,
          severity: SourceSpanSeverity.error,
        ),
      );
    }

    return _ToJsonValidationResult(serializationType: typeDefinition);
  }

  static SourceSpanSeverityException? _validateFromJson(
    InterfaceElement element,
    TypeDefinition extraClass,
  ) {
    final fromJson =
        element.getNamedConstructor('fromJson') ??
        (element.getMethod('fromJson')?.isStatic == true
            ? element.getMethod('fromJson')
            : null);

    if (fromJson == null) {
      return SourceSpanSeverityException(
        'Custom class "${extraClass.className}" is missing a "fromJson" constructor or static method.',
        element.span,
        severity: SourceSpanSeverity.error,
      );
    }

    return null;
  }
}

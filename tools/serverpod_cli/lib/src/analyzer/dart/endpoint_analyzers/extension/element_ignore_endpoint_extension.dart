import 'package:analyzer/dart/element/element.dart';
import 'package:serverpod_shared/annotations.dart';

extension ElementAnnotationExtensions on Element {
  bool get markedAsIgnored {
    return metadata
        .hasAnnotationOfType(ServerpodAnnotationClassNames.doNotGenerate);
  }
}

extension on List<ElementAnnotation> {
  bool hasAnnotationOfType(String typeName) {
    return any((annotation) {
      var constant = annotation.computeConstantValue();
      var type = constant?.type;
      var currentTypeName = type?.element?.name;
      return currentTypeName == typeName;
    });
  }
}

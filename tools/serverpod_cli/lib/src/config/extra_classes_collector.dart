import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/physical_file_system.dart';

/// Custom visitor to collect all class types from a library.
class ClassTypeCollector {
  final List<String> classNames = [];
  final String libraryPath;

  ClassTypeCollector(this.libraryPath);

  void visitElements(Element element) {
    // Skip private elements and elements with no name.
    if (element.name?.startsWith('_') ?? true) {
      return;
    }

    if (element is ClassElement ||
        element is EnumElement ||
        element is MixinElement) {
      classNames.add('$libraryPath:${element.name}');
    }

    for (final child in element.children) {
      visitElements(child);
    }
  }
}

/// Function to discover all types from a library.
Future<List<String>> discoverTypesFromLibrary(String libraryPath) async {
  try {
    // Convert package path to file path if needed
    String filePath = resolveLibraryPath(libraryPath);

    // Create analysis context
    var resourceProvider = PhysicalResourceProvider.INSTANCE;
    var collection = AnalysisContextCollection(
      includedPaths: [filePath],
      resourceProvider: resourceProvider,
    );

    var context = collection.contextFor(filePath);
    var result = await context.currentSession.getResolvedLibrary(filePath);

    if (result is ResolvedLibraryResult) {
      var collector = ClassTypeCollector(libraryPath);
      for (var unit in result.units) {
        collector.visitElements(unit.libraryElement);
      }
      return collector.classNames;
    }

    return [];
  } catch (e) {
    // Log error and return empty list
    print('Warning: Could not analyze library $libraryPath: $e');
    return [];
  }
}

/// Helper function to resolve library path.
String resolveLibraryPath(String libraryPath) {
  if (libraryPath.startsWith('package:')) {
    // Convert package: URI to file path
    // This would need to be implemented based on your project structure
    // and pub dependencies resolution
    return resolvePackageUri(libraryPath);
  } else if (libraryPath.startsWith('dart:')) {
    // Handle dart: core libraries - you might want to skip these
    // or handle them differently
    throw UnsupportedError('Cannot discover types from dart: libraries');
  } else {
    // Assume it's a relative file path
    return libraryPath;
  }
}

/// Package URI resolution helper.
String resolvePackageUri(String packageUri) {
  // Implementation depends on your project setup
  // You would typically:
  // 1. Parse the package name from the URI
  // 2. Look up the package in .dart_tool/package_config.json
  // 3. Resolve to the actual file path

  // Simplified example:
  if (packageUri.startsWith('package:')) {
    var parts = packageUri.substring(8).split('/');
    var packageName = parts[0];
    var relativePath = parts.sublist(1).join('/');

    // This is a simplified resolution - you'd need proper package config parsing
    return 'path/to/packages/$packageName/$relativePath';
  }

  return packageUri;
}

import '../../serverpod_database.dart';

/// Restrictions on the database definition for the current dialect.
class DatabaseDefinitionRestrictions {
  /// Creates a new [DatabaseDefinitionRestrictions] for the current dialect.
  const DatabaseDefinitionRestrictions({
    this.supportedIndexTypes,
    this.supportsRowLevelSecurity = true,
  });

  /// List of supported index types for the current dialect.
  ///
  /// If null, all index types are supported (default).
  final List<String>? supportedIndexTypes;

  /// Whether the dialect supports row-level security policies.
  ///
  /// Defaults to true. When false, row security policies are stripped from the
  /// generated SQL (with a warning), as the dialect cannot enforce them.
  final bool supportsRowLevelSecurity;
}

/// Extensions on [DatabaseDefinitionRestrictions] to adapt the database
/// definition for the current dialect.
extension DatabaseDefinitionRestrictionsEx on DatabaseDefinition {
  /// Gets the database definition for the current dialect.
  ///
  /// Pass a [logWarnings] function to log warnings about unsupported elements
  /// on SQL generation.
  DatabaseDefinition forDialect(
    DatabaseDialect dialect, {
    required Function(String)? logWarnings,
  }) => copyWith(
    tables: tables.forDialect(dialect, logWarnings: logWarnings),
  );
}

/// Extensions on [TableDefinition] to adapt the table definition for the
/// current dialect.
extension TableDefinitionRestrictionsEx on List<TableDefinition> {
  /// Gets the table definition for the current dialect.
  ///
  /// Pass a [logWarnings] function to log warnings about unsupported indexes.
  /// This should only be used when calling [forDialect] from a context where
  /// migration SQL is being generated.
  List<TableDefinition> forDialect(
    DatabaseDialect dialect, {
    Function(String)? logWarnings,
  }) {
    final provider = DatabaseProvider.forDialect(dialect);
    final restrictions = provider.definitionRestrictions;
    final supportedIndexTypes = restrictions.supportedIndexTypes;

    var tables = this;

    // Strip row-level security policies on dialects that cannot enforce them.
    if (!restrictions.supportsRowLevelSecurity) {
      final securedTables = tables
          .where((t) => t.rowSecurityPolicies?.isNotEmpty ?? false)
          .toList();

      if (securedTables.isNotEmpty) {
        logWarnings?.call(
          'Row-level security is not supported by the database dialect '
          '"${dialect.name}" and will not be enforced for the following '
          'tables:\n'
          '${securedTables.map((t) => '  • ${t.name}').join('\n')}\n',
        );

        tables = [
          for (var t in tables)
            (t.rowSecurityPolicies?.isNotEmpty ?? false)
                ? t.copyWith(rowSecurityPolicies: null)
                : t,
        ];
      }
    }

    if (supportedIndexTypes == null) {
      return tables;
    }

    final unsupportedIndexes = tables
        .map(
          (t) => t.indexes
              .where((i) => !supportedIndexTypes.contains(i.type))
              .toList(),
        )
        .expand((t) => t)
        .toList();

    if (unsupportedIndexes.isEmpty) return tables;

    logWarnings?.call(
      'The following indexes will be skipped due to unsupported types by the '
      'database dialect "${dialect.name}":\n'
      '${unsupportedIndexes.map((i) => '  • ${i.indexName} (${i.type})').join('\n')}\n',
    );

    return [
      for (var t in tables)
        t.copyWith(
          indexes: t.indexes
              .where((i) => supportedIndexTypes.contains(i.type))
              .toList(),
        ),
    ];
  }
}

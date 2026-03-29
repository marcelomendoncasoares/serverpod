import '../../serverpod_database.dart';

/// Restrictions on the database definition for the current dialect.
class DatabaseDefinitionRestrictions {
  /// Creates a new [DatabaseDefinitionRestrictions] for the current dialect.
  const DatabaseDefinitionRestrictions({this.supportedIndexTypes});

  /// List of supported index types for the current dialect.
  ///
  /// If null, all index types are supported (default).
  final List<String>? supportedIndexTypes;
}

/// Extensions on [DatabaseDefinitionRestrictions] to adapt the database
/// definition for the current dialect.
extension DatabaseDefinitionRestrictionsEx on DatabaseDefinition {
  /// Gets the database definition for the current dialect.
  DatabaseDefinition forDialect(DatabaseDialect dialect) => copyWith(
    tables: tables.forDialect(dialect),
  );
}

/// Extensions on [TableDefinition] to adapt the table definition for the
/// current dialect.
extension TableDefinitionRestrictionsEx on List<TableDefinition> {
  /// Gets the table definition for the current dialect.
  List<TableDefinition> forDialect(DatabaseDialect dialect) {
    final provider = DatabaseProvider.forDialect(dialect);
    final restrictions = provider.definitionRestrictions;
    final supportedIndexTypes = restrictions.supportedIndexTypes;

    if (supportedIndexTypes == null) {
      return this;
    }

    return [
      for (var t in this)
        t.copyWith(
          indexes: t.indexes
              .where((i) => supportedIndexTypes.contains(i.type))
              .toList(),
        ),
    ];
  }
}

/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import '../../../providers/email/models/email_account.dart' as _i2;
import 'package:serverpod_auth_idp_server/src/generated/protocol.dart' as _i3;

/// Password history entry for an email account.
///
/// This model stores previously used passwords to prevent users from reusing
/// them when resetting their password.
abstract class EmailAccountPasswordHistory
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  EmailAccountPasswordHistory._({
    this.id,
    required this.emailAccountId,
    this.emailAccount,
    required this.passwordHash,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory EmailAccountPasswordHistory({
    _i1.UuidValue? id,
    required _i1.UuidValue emailAccountId,
    _i2.EmailAccount? emailAccount,
    required String passwordHash,
    DateTime? createdAt,
  }) = _EmailAccountPasswordHistoryImpl;

  factory EmailAccountPasswordHistory.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return EmailAccountPasswordHistory(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      emailAccountId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['emailAccountId'],
      ),
      emailAccount: jsonSerialization['emailAccount'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.EmailAccount>(
              jsonSerialization['emailAccount'],
            ),
      passwordHash: jsonSerialization['passwordHash'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = EmailAccountPasswordHistoryTable();

  static const db = EmailAccountPasswordHistoryRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue emailAccountId;

  /// Email account this password history entry belongs to
  _i2.EmailAccount? emailAccount;

  /// The hashed password that was previously used.
  ///
  /// Stored in PHC format: $argon2id$v=19$m={memory},t={iterations},p={lanes}${base64Salt}$${base64Hash}
  String passwordHash;

  /// The time when this password was set.
  DateTime createdAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [EmailAccountPasswordHistory]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EmailAccountPasswordHistory copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? emailAccountId,
    _i2.EmailAccount? emailAccount,
    String? passwordHash,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_auth_idp.EmailAccountPasswordHistory',
      if (id != null) 'id': id?.toJson(),
      'emailAccountId': emailAccountId.toJson(),
      if (emailAccount != null) 'emailAccount': emailAccount?.toJson(),
      'passwordHash': passwordHash,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static EmailAccountPasswordHistoryInclude include({
    _i2.EmailAccountInclude? emailAccount,
  }) {
    return EmailAccountPasswordHistoryInclude._(emailAccount: emailAccount);
  }

  static EmailAccountPasswordHistoryIncludeList includeList({
    _i1.WhereExpressionBuilder<EmailAccountPasswordHistoryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EmailAccountPasswordHistoryTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<EmailAccountPasswordHistoryTable>? orderByList,
    EmailAccountPasswordHistoryInclude? include,
  }) {
    return EmailAccountPasswordHistoryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EmailAccountPasswordHistory.t),
      orderDescending: // ignore: deprecated_member_use_from_same_package
          orderDescending,
      orderByList: orderByList?.call(EmailAccountPasswordHistory.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EmailAccountPasswordHistoryImpl extends EmailAccountPasswordHistory {
  _EmailAccountPasswordHistoryImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue emailAccountId,
    _i2.EmailAccount? emailAccount,
    required String passwordHash,
    DateTime? createdAt,
  }) : super._(
         id: id,
         emailAccountId: emailAccountId,
         emailAccount: emailAccount,
         passwordHash: passwordHash,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [EmailAccountPasswordHistory]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EmailAccountPasswordHistory copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? emailAccountId,
    Object? emailAccount = _Undefined,
    String? passwordHash,
    DateTime? createdAt,
  }) {
    return EmailAccountPasswordHistory(
      id: id is _i1.UuidValue? ? id : this.id,
      emailAccountId: emailAccountId ?? this.emailAccountId,
      emailAccount: emailAccount is _i2.EmailAccount?
          ? emailAccount
          : this.emailAccount?.copyWith(),
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class EmailAccountPasswordHistoryUpdateTable
    extends _i1.UpdateTable<EmailAccountPasswordHistoryTable> {
  EmailAccountPasswordHistoryUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> emailAccountId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.emailAccountId,
    value,
  );

  _i1.ColumnValue<String, String> passwordHash(String value) => _i1.ColumnValue(
    table.passwordHash,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class EmailAccountPasswordHistoryTable extends _i1.Table<_i1.UuidValue?> {
  EmailAccountPasswordHistoryTable({super.tableRelation})
    : super(tableName: 'serverpod_auth_idp_email_account_password_history') {
    updateTable = EmailAccountPasswordHistoryUpdateTable(this);
    emailAccountId = _i1.ColumnUuid(
      'emailAccountId',
      this,
    );
    passwordHash = _i1.ColumnString(
      'passwordHash',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final EmailAccountPasswordHistoryUpdateTable updateTable;

  late final _i1.ColumnUuid emailAccountId;

  /// Email account this password history entry belongs to
  _i2.EmailAccountTable? _emailAccount;

  /// The hashed password that was previously used.
  ///
  /// Stored in PHC format: $argon2id$v=19$m={memory},t={iterations},p={lanes}${base64Salt}$${base64Hash}
  late final _i1.ColumnString passwordHash;

  /// The time when this password was set.
  late final _i1.ColumnDateTime createdAt;

  _i2.EmailAccountTable get emailAccount {
    if (_emailAccount != null) return _emailAccount!;
    _emailAccount = _i1.createRelationTable(
      relationFieldName: 'emailAccount',
      field: EmailAccountPasswordHistory.t.emailAccountId,
      foreignField: _i2.EmailAccount.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.EmailAccountTable(tableRelation: foreignTableRelation),
    );
    return _emailAccount!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    emailAccountId,
    passwordHash,
    createdAt,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'emailAccount') {
      return emailAccount;
    }
    return null;
  }
}

class EmailAccountPasswordHistoryInclude extends _i1.IncludeObject {
  EmailAccountPasswordHistoryInclude._({
    _i2.EmailAccountInclude? emailAccount,
  }) {
    _emailAccount = emailAccount;
  }

  _i2.EmailAccountInclude? _emailAccount;

  @override
  Map<String, _i1.Include?> get includes => {'emailAccount': _emailAccount};

  @override
  _i1.Table<_i1.UuidValue?> get table => EmailAccountPasswordHistory.t;
}

class EmailAccountPasswordHistoryIncludeList extends _i1.IncludeList {
  EmailAccountPasswordHistoryIncludeList._({
    _i1.WhereExpressionBuilder<EmailAccountPasswordHistoryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(EmailAccountPasswordHistory.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => EmailAccountPasswordHistory.t;
}

class EmailAccountPasswordHistoryRepository {
  const EmailAccountPasswordHistoryRepository._();

  final attachRow = const EmailAccountPasswordHistoryAttachRowRepository._();

  /// Returns a list of [EmailAccountPasswordHistory]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<EmailAccountPasswordHistory>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EmailAccountPasswordHistoryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EmailAccountPasswordHistoryTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<EmailAccountPasswordHistoryTable>? orderByList,
    _i1.Transaction? transaction,
    EmailAccountPasswordHistoryInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<EmailAccountPasswordHistory>(
      where: where?.call(EmailAccountPasswordHistory.t),
      orderBy: orderBy?.call(EmailAccountPasswordHistory.t),
      orderByList: orderByList?.call(EmailAccountPasswordHistory.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [EmailAccountPasswordHistory] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<EmailAccountPasswordHistory?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EmailAccountPasswordHistoryTable>? where,
    int? offset,
    _i1.OrderByBuilder<EmailAccountPasswordHistoryTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<EmailAccountPasswordHistoryTable>? orderByList,
    _i1.Transaction? transaction,
    EmailAccountPasswordHistoryInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<EmailAccountPasswordHistory>(
      where: where?.call(EmailAccountPasswordHistory.t),
      orderBy: orderBy?.call(EmailAccountPasswordHistory.t),
      orderByList: orderByList?.call(EmailAccountPasswordHistory.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [EmailAccountPasswordHistory] by its [id] or null if no such row exists.
  Future<EmailAccountPasswordHistory?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    EmailAccountPasswordHistoryInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<EmailAccountPasswordHistory>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [EmailAccountPasswordHistory]s in the list and returns the inserted rows.
  ///
  /// The returned [EmailAccountPasswordHistory]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<EmailAccountPasswordHistory>> insert(
    _i1.DatabaseSession session,
    List<EmailAccountPasswordHistory> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<EmailAccountPasswordHistory>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [EmailAccountPasswordHistory] and returns the inserted row.
  ///
  /// The returned [EmailAccountPasswordHistory] will have its `id` field set.
  Future<EmailAccountPasswordHistory> insertRow(
    _i1.DatabaseSession session,
    EmailAccountPasswordHistory row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<EmailAccountPasswordHistory>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [EmailAccountPasswordHistory]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [EmailAccountPasswordHistory]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  Future<List<EmailAccountPasswordHistory>> upsert(
    _i1.DatabaseSession session,
    List<EmailAccountPasswordHistory> rows, {
    required _i1.ColumnSelections<EmailAccountPasswordHistoryTable>
    conflictColumns,
    _i1.ColumnSelections<EmailAccountPasswordHistoryTable>? updateColumns,
    _i1.WhereExpressionBuilder<EmailAccountPasswordHistoryTable>? updateWhere,
    _i1.Transaction? transaction,
  }) async {
    return session.db.upsert<EmailAccountPasswordHistory>(
      rows,
      conflictColumns: conflictColumns(EmailAccountPasswordHistory.t),
      updateColumns: updateColumns?.call(EmailAccountPasswordHistory.t),
      updateWhere: updateWhere?.call(EmailAccountPasswordHistory.t),
      transaction: transaction,
    );
  }

  /// Upserts a single [EmailAccountPasswordHistory] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [EmailAccountPasswordHistory] will have its `id` field set.
  Future<EmailAccountPasswordHistory?> upsertRow(
    _i1.DatabaseSession session,
    EmailAccountPasswordHistory row, {
    required _i1.ColumnSelections<EmailAccountPasswordHistoryTable>
    conflictColumns,
    _i1.ColumnSelections<EmailAccountPasswordHistoryTable>? updateColumns,
    _i1.WhereExpressionBuilder<EmailAccountPasswordHistoryTable>? updateWhere,
    _i1.Transaction? transaction,
  }) async {
    return session.db.upsertRow<EmailAccountPasswordHistory>(
      row,
      conflictColumns: conflictColumns(EmailAccountPasswordHistory.t),
      updateColumns: updateColumns?.call(EmailAccountPasswordHistory.t),
      updateWhere: updateWhere?.call(EmailAccountPasswordHistory.t),
      transaction: transaction,
    );
  }

  /// Updates all [EmailAccountPasswordHistory]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<EmailAccountPasswordHistory>> update(
    _i1.DatabaseSession session,
    List<EmailAccountPasswordHistory> rows, {
    _i1.ColumnSelections<EmailAccountPasswordHistoryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<EmailAccountPasswordHistory>(
      rows,
      columns: columns?.call(EmailAccountPasswordHistory.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EmailAccountPasswordHistory]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<EmailAccountPasswordHistory> updateRow(
    _i1.DatabaseSession session,
    EmailAccountPasswordHistory row, {
    _i1.ColumnSelections<EmailAccountPasswordHistoryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<EmailAccountPasswordHistory>(
      row,
      columns: columns?.call(EmailAccountPasswordHistory.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EmailAccountPasswordHistory] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<EmailAccountPasswordHistory?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<EmailAccountPasswordHistoryUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<EmailAccountPasswordHistory>(
      id,
      columnValues: columnValues(EmailAccountPasswordHistory.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [EmailAccountPasswordHistory]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<EmailAccountPasswordHistory>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<EmailAccountPasswordHistoryUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<EmailAccountPasswordHistoryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EmailAccountPasswordHistoryTable>? orderBy,
    _i1.OrderByListBuilder<EmailAccountPasswordHistoryTable>? orderByList,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<EmailAccountPasswordHistory>(
      columnValues: columnValues(EmailAccountPasswordHistory.t.updateTable),
      where: where(EmailAccountPasswordHistory.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EmailAccountPasswordHistory.t),
      orderByList: orderByList?.call(EmailAccountPasswordHistory.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [EmailAccountPasswordHistory]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<EmailAccountPasswordHistory>> delete(
    _i1.DatabaseSession session,
    List<EmailAccountPasswordHistory> rows, {
    _i1.OrderByBuilder<EmailAccountPasswordHistoryTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<EmailAccountPasswordHistoryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<EmailAccountPasswordHistory>(
      rows,
      orderBy: orderBy?.call(EmailAccountPasswordHistory.t),
      orderByList: orderByList?.call(EmailAccountPasswordHistory.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes a single [EmailAccountPasswordHistory].
  Future<EmailAccountPasswordHistory> deleteRow(
    _i1.DatabaseSession session,
    EmailAccountPasswordHistory row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<EmailAccountPasswordHistory>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  Future<List<EmailAccountPasswordHistory>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<EmailAccountPasswordHistoryTable> where,
    _i1.OrderByBuilder<EmailAccountPasswordHistoryTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<EmailAccountPasswordHistoryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<EmailAccountPasswordHistory>(
      where: where(EmailAccountPasswordHistory.t),
      orderBy: orderBy?.call(EmailAccountPasswordHistory.t),
      orderByList: orderByList?.call(EmailAccountPasswordHistory.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EmailAccountPasswordHistoryTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<EmailAccountPasswordHistory>(
      where: where?.call(EmailAccountPasswordHistory.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [EmailAccountPasswordHistory] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<EmailAccountPasswordHistoryTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<EmailAccountPasswordHistory>(
      where: where(EmailAccountPasswordHistory.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class EmailAccountPasswordHistoryAttachRowRepository {
  const EmailAccountPasswordHistoryAttachRowRepository._();

  /// Creates a relation between the given [EmailAccountPasswordHistory] and [EmailAccount]
  /// by setting the [EmailAccountPasswordHistory]'s foreign key `emailAccountId` to refer to the [EmailAccount].
  Future<void> emailAccount(
    _i1.DatabaseSession session,
    EmailAccountPasswordHistory emailAccountPasswordHistory,
    _i2.EmailAccount emailAccount, {
    _i1.Transaction? transaction,
  }) async {
    if (emailAccountPasswordHistory.id == null) {
      throw ArgumentError.notNull('emailAccountPasswordHistory.id');
    }
    if (emailAccount.id == null) {
      throw ArgumentError.notNull('emailAccount.id');
    }

    var $emailAccountPasswordHistory = emailAccountPasswordHistory.copyWith(
      emailAccountId: emailAccount.id,
    );
    await session.db.updateRow<EmailAccountPasswordHistory>(
      $emailAccountPasswordHistory,
      columns: [EmailAccountPasswordHistory.t.emailAccountId],
      transaction: transaction,
    );
  }
}

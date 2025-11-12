/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import '../../../../providers/email/models/email_account.dart' as _i2;
import 'dart:typed_data' as _i3;

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
    required this.passwordSalt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory EmailAccountPasswordHistory({
    _i1.UuidValue? id,
    required _i1.UuidValue emailAccountId,
    _i2.EmailAccount? emailAccount,
    required _i3.ByteData passwordHash,
    required _i3.ByteData passwordSalt,
    DateTime? createdAt,
  }) = _EmailAccountPasswordHistoryImpl;

  factory EmailAccountPasswordHistory.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return EmailAccountPasswordHistory(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      emailAccountId: _i1.UuidValueJsonExtension.fromJson(
          jsonSerialization['emailAccountId']),
      emailAccount: jsonSerialization['emailAccount'] == null
          ? null
          : _i2.EmailAccount.fromJson(
              (jsonSerialization['emailAccount'] as Map<String, dynamic>)),
      passwordHash:
          _i1.ByteDataJsonExtension.fromJson(jsonSerialization['passwordHash']),
      passwordSalt:
          _i1.ByteDataJsonExtension.fromJson(jsonSerialization['passwordSalt']),
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
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
  /// Obtained in conjunction with [passwordSalt].
  _i3.ByteData passwordHash;

  /// The salt used for creating the [passwordHash].
  _i3.ByteData passwordSalt;

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
    _i3.ByteData? passwordHash,
    _i3.ByteData? passwordSalt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id?.toJson(),
      'emailAccountId': emailAccountId.toJson(),
      if (emailAccount != null) 'emailAccount': emailAccount?.toJson(),
      'passwordHash': passwordHash.toJson(),
      'passwordSalt': passwordSalt.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static EmailAccountPasswordHistoryInclude include(
      {_i2.EmailAccountInclude? emailAccount}) {
    return EmailAccountPasswordHistoryInclude._(emailAccount: emailAccount);
  }

  static EmailAccountPasswordHistoryIncludeList includeList({
    _i1.WhereExpressionBuilder<EmailAccountPasswordHistoryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EmailAccountPasswordHistoryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EmailAccountPasswordHistoryTable>? orderByList,
    EmailAccountPasswordHistoryInclude? include,
  }) {
    return EmailAccountPasswordHistoryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EmailAccountPasswordHistory.t),
      orderDescending: orderDescending,
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
    required _i3.ByteData passwordHash,
    required _i3.ByteData passwordSalt,
    DateTime? createdAt,
  }) : super._(
          id: id,
          emailAccountId: emailAccountId,
          emailAccount: emailAccount,
          passwordHash: passwordHash,
          passwordSalt: passwordSalt,
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
    _i3.ByteData? passwordHash,
    _i3.ByteData? passwordSalt,
    DateTime? createdAt,
  }) {
    return EmailAccountPasswordHistory(
      id: id is _i1.UuidValue? ? id : this.id,
      emailAccountId: emailAccountId ?? this.emailAccountId,
      emailAccount: emailAccount is _i2.EmailAccount?
          ? emailAccount
          : this.emailAccount?.copyWith(),
      passwordHash: passwordHash ?? this.passwordHash.clone(),
      passwordSalt: passwordSalt ?? this.passwordSalt.clone(),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class EmailAccountPasswordHistoryUpdateTable
    extends _i1.UpdateTable<EmailAccountPasswordHistoryTable> {
  EmailAccountPasswordHistoryUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> emailAccountId(
          _i1.UuidValue value) =>
      _i1.ColumnValue(
        table.emailAccountId,
        value,
      );

  _i1.ColumnValue<_i3.ByteData, _i3.ByteData> passwordHash(
          _i3.ByteData value) =>
      _i1.ColumnValue(
        table.passwordHash,
        value,
      );

  _i1.ColumnValue<_i3.ByteData, _i3.ByteData> passwordSalt(
          _i3.ByteData value) =>
      _i1.ColumnValue(
        table.passwordSalt,
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
    passwordHash = _i1.ColumnByteData(
      'passwordHash',
      this,
    );
    passwordSalt = _i1.ColumnByteData(
      'passwordSalt',
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
  /// Obtained in conjunction with [passwordSalt].
  late final _i1.ColumnByteData passwordHash;

  /// The salt used for creating the [passwordHash].
  late final _i1.ColumnByteData passwordSalt;

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
        passwordSalt,
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
  EmailAccountPasswordHistoryInclude._(
      {_i2.EmailAccountInclude? emailAccount}) {
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<EmailAccountPasswordHistoryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EmailAccountPasswordHistoryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EmailAccountPasswordHistoryTable>? orderByList,
    _i1.Transaction? transaction,
    EmailAccountPasswordHistoryInclude? include,
  }) async {
    return session.db.find<EmailAccountPasswordHistory>(
      where: where?.call(EmailAccountPasswordHistory.t),
      orderBy: orderBy?.call(EmailAccountPasswordHistory.t),
      orderByList: orderByList?.call(EmailAccountPasswordHistory.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<EmailAccountPasswordHistoryTable>? where,
    int? offset,
    _i1.OrderByBuilder<EmailAccountPasswordHistoryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EmailAccountPasswordHistoryTable>? orderByList,
    _i1.Transaction? transaction,
    EmailAccountPasswordHistoryInclude? include,
  }) async {
    return session.db.findFirstRow<EmailAccountPasswordHistory>(
      where: where?.call(EmailAccountPasswordHistory.t),
      orderBy: orderBy?.call(EmailAccountPasswordHistory.t),
      orderByList: orderByList?.call(EmailAccountPasswordHistory.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Finds a single [EmailAccountPasswordHistory] by its [id] or null if no such row exists.
  Future<EmailAccountPasswordHistory?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    EmailAccountPasswordHistoryInclude? include,
  }) async {
    return session.db.findById<EmailAccountPasswordHistory>(
      id,
      transaction: transaction,
      include: include,
    );
  }

  /// Inserts all [EmailAccountPasswordHistory]s in the list and returns the inserted rows.
  ///
  /// The returned [EmailAccountPasswordHistory]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<EmailAccountPasswordHistory>> insert(
    _i1.Session session,
    List<EmailAccountPasswordHistory> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<EmailAccountPasswordHistory>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [EmailAccountPasswordHistory] and returns the inserted row.
  ///
  /// The returned [EmailAccountPasswordHistory] will have its `id` field set.
  Future<EmailAccountPasswordHistory> insertRow(
    _i1.Session session,
    EmailAccountPasswordHistory row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<EmailAccountPasswordHistory>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [EmailAccountPasswordHistory]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<EmailAccountPasswordHistory>> update(
    _i1.Session session,
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
    _i1.Session session,
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
    _i1.Session session,
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
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<EmailAccountPasswordHistoryUpdateTable>
        columnValues,
    required _i1.WhereExpressionBuilder<EmailAccountPasswordHistoryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EmailAccountPasswordHistoryTable>? orderBy,
    _i1.OrderByListBuilder<EmailAccountPasswordHistoryTable>? orderByList,
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
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [EmailAccountPasswordHistory]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<EmailAccountPasswordHistory>> delete(
    _i1.Session session,
    List<EmailAccountPasswordHistory> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<EmailAccountPasswordHistory>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [EmailAccountPasswordHistory].
  Future<EmailAccountPasswordHistory> deleteRow(
    _i1.Session session,
    EmailAccountPasswordHistory row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<EmailAccountPasswordHistory>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<EmailAccountPasswordHistory>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<EmailAccountPasswordHistoryTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<EmailAccountPasswordHistory>(
      where: where(EmailAccountPasswordHistory.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
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
}

class EmailAccountPasswordHistoryAttachRowRepository {
  const EmailAccountPasswordHistoryAttachRowRepository._();

  /// Creates a relation between the given [EmailAccountPasswordHistory] and [EmailAccount]
  /// by setting the [EmailAccountPasswordHistory]'s foreign key `emailAccountId` to refer to the [EmailAccount].
  Future<void> emailAccount(
    _i1.Session session,
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

    var $emailAccountPasswordHistory =
        emailAccountPasswordHistory.copyWith(emailAccountId: emailAccount.id);
    await session.db.updateRow<EmailAccountPasswordHistory>(
      $emailAccountPasswordHistory,
      columns: [EmailAccountPasswordHistory.t.emailAccountId],
      transaction: transaction,
    );
  }
}

import '../../serverpod_database.dart';

/// A function that returns an [Expression] for a [Table] to be used with where
/// clauses.
typedef WhereExpressionBuilder<T extends Table> = Expression Function(T);

/// A database [Expression].
class Expression<T> {
  final T _expression;

  /// Creates a new [Expression].
  /// Note that the precedence of operators may not be what you think, so
  /// always use parentheses to make sure that that expressions are executed
  /// in the correct order.
  const Expression(this._expression);

  @override
  String toString() {
    return '$_expression';
  }

  /// Returns a list of all [Column]s in the expression.
  List<Column> get columns => [];

  /// Database AND operator.
  Expression operator &(Expression other) {
    return _AndExpression(this, other);
  }

  /// Database OR operator.
  Expression operator |(Expression other) {
    return _OrExpression(this, other);
  }

  /// Database NOT operator.
  Expression operator ~() {
    return NotExpression(this);
  }

  /// Iterator for all [Expression]s in the expression.
  /// Iterates elements deterministically depth first.
  Iterable<Expression> get depthFirst sync* {
    yield this;
  }

  /// Takes an action for each element.
  ///
  /// Calls [action] for each element along with the index in the
  /// iteration order.
  void forEachDepthFirstIndexed(
    void Function(int index, Expression expression) action,
  ) {
    var index = 0;
    for (var expression in depthFirst) {
      action(index, expression);
      index++;
    }
  }
}

/// A database expression that is escaped. This is used to escape values that
/// are not expressions, such as strings and numbers.
class EscapedExpression extends Expression {
  /// Creates a new [EscapedExpression].
  EscapedExpression(super.expression);

  @override
  String toString() {
    return ValueEncoder.instance.convert(_expression);
  }
}

/// A constant [Expression].
class Constant extends Expression {
  const Constant._(super.value);

  /// Creates a constant [String] expression.
  factory Constant.string(String value) => Constant._(EscapedExpression(value));

  /// Creates a constant [bool] expression.
  factory Constant.bool(bool value) => Constant._('$value'.toUpperCase());

  /// Creates a constant [null] expression.
  static Constant nullValue = const Constant._('NULL');
}

/// A builder for a SQL CASE expression.
///
/// Creates a searched CASE expression when [column] is omitted and a
/// simple CASE expression when it is provided.
class Case {
  final Column? _column;
  final List<_WhenThen> _whenThenExpressions = [];

  /// Creates a new [Case] expression builder.
  Case([this._column]);

  /// Adds a WHEN and THEN expression.
  Case when(Expression expression, {required Expression then}) {
    _whenThenExpressions.add(_WhenThen(expression, then));
    return this;
  }

  /// Completes the CASE expression with an ELSE expression.
  Expression orElse(Expression expression) {
    return _CaseExpression(
      _column,
      List.unmodifiable(_whenThenExpressions),
      expression,
    );
  }
}

class _CaseExpression extends Expression<void> {
  final Column? _column;
  final List<_WhenThen> _whenThenExpressions;
  final Expression _elseExpression;

  _CaseExpression(
    this._column,
    this._whenThenExpressions,
    this._elseExpression,
  ) : super(null);

  @override
  List<Column> get columns => [
    if (_column != null) _column,
    ..._whenThenExpressions.expand(
      (expressions) => [
        ...expressions.when.columns,
        ...expressions.then.columns,
      ],
    ),
    ..._elseExpression.columns,
  ];

  @override
  Iterable<Expression> get depthFirst sync* {
    yield* super.depthFirst;
    for (final expressions in _whenThenExpressions) {
      yield* expressions.when.depthFirst;
      yield* expressions.then.depthFirst;
    }
    yield* _elseExpression.depthFirst;
  }

  @override
  String toString() {
    var expression = 'CASE';
    if (_column != null) {
      expression += ' $_column';
    }
    for (final expressions in _whenThenExpressions) {
      expression += ' WHEN ${expressions.when} THEN ${expressions.then}';
    }
    return '$expression ELSE $_elseExpression END';
  }
}

class _WhenThen {
  final Expression when;
  final Expression then;

  _WhenThen(this.when, this.then);
}

/// A database expression to invert the result of another expression.
class NotExpression extends Expression<Expression> {
  /// Creates a new [NotExpression].
  NotExpression(super.expression);

  @override
  Iterable<Expression> get depthFirst sync* {
    yield* super.depthFirst;
    yield* super._expression.depthFirst;
  }

  /// Returns the expression wrapped in NOT.
  Expression get subExpression => _expression;

  @override
  List<Column> get columns => _expression.columns;

  /// Returns the expression as a string wrapped in NOT.
  String wrapExpression(String expression) {
    return 'NOT $_expression';
  }

  @override
  String toString() {
    return 'NOT $_expression';
  }
}

/// A database expression with two parts.
abstract class TwoPartExpression extends Expression<Expression> {
  final Expression _other;

  /// Creates a new [TwoPartExpression].
  TwoPartExpression(super.expression, this._other);

  @override
  List<Column> get columns => [..._expression.columns, ..._other.columns];

  /// Returns sub expressions for this expression
  List<Expression> get subExpressions => [_expression, _other];

  /// Returns the expression operator as a string.
  String get operator;

  @override
  Iterable<Expression> get depthFirst sync* {
    yield* super.depthFirst;
    yield* _expression.depthFirst;
    yield* _other.depthFirst;
  }

  @override
  String toString() {
    return '($_expression $operator $_other)';
  }
}

class _AndExpression extends TwoPartExpression {
  _AndExpression(super.value, super.other);

  @override
  String get operator => 'AND';
}

class _OrExpression extends TwoPartExpression {
  _OrExpression(super.value, super.other);

  @override
  String get operator => 'OR';
}

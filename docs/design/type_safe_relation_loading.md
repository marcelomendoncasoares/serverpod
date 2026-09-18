# Type-Safe Relation Loading in Serverpod Models

## Summary

Serverpod currently represents unloaded relations using `null`. That conflates two independent concepts:

- **Domain nullability**: whether a loaded relation may legitimately have no value.
- **Loading state**: whether the relation was fetched by the query.

Required and to-many relations are therefore exposed as nullable even though `null` is not a meaningful domain value:

```yaml
company: Company?, relation
reports: List<Employee>?, relation
```

```dart
employee.company!.name;

for (final report in employee.reports!) {
  // ...
}
```

This proposal separates the two. Safe domain types are `Company`, `Employee?`, and `List<Employee>`. Accessing an unloaded safe relation throws `RelationNotLoadedException`.

Required to-one and to-many relations **opt in** through a non-nullable declaration; existing nullable declarations stay legacy. Optional to-one relations already use `T?` for real domain nullability, so they adopt the new loading-state semantics directly.

---

# Goals

1. Make relation nullability accurately represent the domain.
2. Remove unnecessary `!` and `?.` operators from required and to-many relations.
3. Distinguish unloaded relations from legitimate domain `null`.
4. Throw a dedicated ORM exception when an unloaded relation is accessed.
5. Preserve legacy behavior for existing required and to-many declarations.
6. Allow field-by-field opt-in for safer required and to-many relations.
7. Avoid wrapper types such as `Relation<T>` in normal application code.
8. Preserve loading state through constructors, serialization, `copyWith`, and generated ORM operations.

---

# Core principle

> **Public nullability describes the domain. Loading state is a separate ORM concern.**

| Category | When loaded | Safe public type | Domain states |
|---|---|---|---|
| Required to-one | A `Company` always exists | `Company` | `unloaded`, `loaded(T)` |
| Optional to-one | An `Employee` may or may not exist | `Employee?` | `unloaded`, `loaded(null)`, `loaded(T)` |
| To-many | Zero or more employees | `List<Employee>` | `unloaded`, `loaded([])`, `loaded([T, ...])` |

None of these types encode whether the relation was loaded. Unloaded access throws `RelationNotLoadedException`.

---

# Declaration contract

| Model declaration | Public API | Unloaded access | Notes |
|---|---|---|---|
| `Company?, relation` | `Company? company` | `null` | Legacy required to-one |
| `Company, relation` | `Company get/set company` | throws | Safe opt-in. Does not change FK nullability |
| `Employee?, relation(optional)` | `Employee? get/set manager` | throws | Already the correct domain type. No `Employee, relation(optional)` form |
| `List<Employee>?, relation` | `List<Employee>? reports` | `null` | Legacy to-many |
| `List<Employee>, relation` | `List<Employee> get/set reports` | throws | Safe opt-in. Does not change the persisted schema |

There is no meaningful domain-nullable collection. Once loaded, a list is either empty or contains rows, so `employee.reports.isEmpty` means loaded and empty.

On a safe optional relation, `employee.manager == null` means loaded and absent. It no longer also means “not loaded.” That is an intentional behavioral correction.

Users migrate required and to-many fields independently by dropping `?`. Optional declarations do not change.

---

# Loading-state sentinel

Safe and optional relations represent unloaded state with a **typed** sentinel: a generated value that is a subtype of the relation’s public type, distinguishable from any real instance.

That keeps constructors and `copyWith` typed. Undefined sentinels stay the omit/keep token, also typed for these parameters:

| Sentinel | Means |
|---|---|
| undefined | Argument omitted. In `copyWith`, keep the current state |
| unloaded | The relation is not loaded |

`null` is never a loading-state token. It is only a domain value, and only for optional to-one relations. Legacy required and to-many fields keep today’s `null`-means-unloaded behavior.

Object-relation sentinels are generated with the target model so they remain valid across files and for sealed types. List sentinels are a generic subtype of `List<T>`. Application code omits arguments instead of naming these values.

This is valid Dart. Overriding `noSuchMethod` makes the compiler insert interface forwarders, so the sentinel does not reimplement every member:

```dart
class UnloadedSentinel {
  const UnloadedSentinel();

  @override
  Never noSuchMethod(Invocation invocation) {
    throw UnsupportedError(
      'Unloaded relation sentinel: ${invocation.memberName}',
    );
  }
}

class UndefinedSentinel {
  const UndefinedSentinel();

  @override
  Never noSuchMethod(Invocation invocation) {
    throw UnsupportedError(
      'Undefined copyWith sentinel: ${invocation.memberName}',
    );
  }
}

class _UnloadedCompany extends UnloadedSentinel implements Company {
  const _UnloadedCompany();
}

class _UndefinedCompany extends UndefinedSentinel implements Company {
  const _UndefinedCompany();
}

class UnloadedList<T> extends UnloadedSentinel implements List<T> {
  const UnloadedList();
}

class UndefinedList<T> extends UndefinedSentinel implements List<T> {
  const UndefinedList();
}

abstract class Company {
  factory Company({int? id, required String name}) = _CompanyImpl;

  static const Company unloaded = _UnloadedCompany();
  static const Company undefined = _UndefinedCompany();

  int? id;
  String name;

  Company copyWith({int? id, String? name});
  Map<String, dynamic> toJson();
}
```

`Company.unloaded` is a `Company`, so it is a legal default for a `Company` parameter. `Employee(company: null)` is a compile-time error.

One generator constraint: redirecting factories (`factory Employee(...) = _EmployeeImpl`) cannot declare default values. The public constructor must be a forwarding factory so the typed sentinel default can sit on the public signature:

```dart
abstract class Employee {
  factory Employee({
    required String name,
    Company company = Company.unloaded,
    Employee? manager = Employee.unloaded,
    List<Employee> reports = const UnloadedList<Employee>(),
  }) {
    return _EmployeeImpl(
      name: name,
      company: company,
      manager: manager,
      reports: reports,
    );
  }

  static const Employee unloaded = _UnloadedEmployee();
  static const Employee undefined = _UndefinedEmployee();
}
```

---

# Generated implementation

All three safe/optional categories use the same backing-field pattern. Storage stays typed:

```dart
Company _company = Company.unloaded;

Company get company {
  if (_company is UnloadedSentinel) {
    throw RelationNotLoadedException(
      model: 'Employee',
      relation: 'company',
    );
  }

  return _company;
}

set company(Company value) {
  _company = value;
}
```

The public field types follow the declaration table. Assigning through a setter always marks the relation as loaded.

- Safe required / to-many setters do not accept `null`. `employee.reports = []` is loaded empty, not unloaded. Because an unloaded sentinel is a subtype of the field type, generated setters should reject it rather than store it as a loaded value.
- The optional setter is `Employee?`, so `employee.manager = null` is `loaded(null)`, not unloaded.

The precise storage layout is not part of the contract, but unloaded state must not be encoded as `null`.

---

# Constructors

Safe and optional parameters default to a same-type unloaded sentinel, so omission constructs an unloaded relation without widening the API to `Object?`:

```dart
Employee({
  Company company = Company.unloaded,
  Employee? manager = Employee.unloaded,
  List<Employee> reports = const UnloadedList<Employee>(),
});
```

| Argument | Required to-one | Optional to-one | To-many |
|---|---|---|---|
| omitted / unloaded sentinel | unloaded | unloaded | unloaded |
| `null` | compile-time error | `loaded(null)` | compile-time error |
| domain value | `loaded(Company)` | `loaded(Employee)` | `loaded(list)`, including `[]` |

`Employee(company: company)` and `Employee(reports: [])` are loaded. `Employee(manager: null)` is `loaded(null)`. `Employee(company: null)` and `Employee(reports: null)` do not compile.

Legacy constructors are unchanged. ORM hydration uses the unloaded sentinel when a relation was not included in the query.

---

# `copyWith`

`copyWith` must preserve loading state. Parameters stay typed and default to a same-type undefined sentinel:

```dart
copyWith({
  Company company = Company.undefined,
  Employee? manager = Employee.undefined,
  List<Employee> reports = const UndefinedList<Employee>(),
});
```

Argument semantics are the constructor table, except omitted / undefined **keeps the current state** instead of becoming unloaded. Generated code may pass the unloaded sentinel to restore unloaded state.

```dart
employee.copyWith();                 // preserves unloaded optional manager
employee.copyWith(manager: null);    // loaded(null)
employee.copyWith(reports: []);      // loaded empty
```

Legacy `copyWith` is unchanged. `Company?` and `List<Employee>?` legacy fields are not reinterpreted as safe relations.

---

# Runtime behavior

With includes, application code uses domain types. No `!` exists solely because of loading state; the remaining null check on `manager` is genuine domain nullability:

```dart
final employee = await Employee.db.findById(
  session,
  id,
  include: Employee.include(
    company: Company.include(),
    manager: Employee.include(),
    reports: Employee.includeList(),
  ),
);

print(employee!.company.name);

final manager = employee.manager;
if (manager != null) {
  print(manager.name);
}

for (final report in employee.reports) {
  print(report.name);
}
```

Without includes, `employee!.company`, `employee.manager`, and `employee.reports` throw `RelationNotLoadedException`. `employee.manager` does **not** return `null`; a returned `null` means loaded and absent.

Legacy declarations still allow `employee.company == null` and `employee.reports == null` for unloaded state.

---

# `RelationNotLoadedException`

```dart
class RelationNotLoadedException implements Exception {
  final String model;
  final String relation;

  RelationNotLoadedException({
    required this.model,
    required this.relation,
  });

  @override
  String toString() {
    return 'RelationNotLoadedException: '
        '$model.$relation was accessed but was not loaded.';
  }
}
```

The message may also tell the user to include the relation when querying. Legacy required and to-many relations do not throw it.

---

# Serialization

Serialization must preserve loading state and inspect raw internal state, including unloaded sentinels.

| State | Wire |
|---|---|
| unloaded | field omitted |
| `loaded(null)` (optional only) | field present with `null` |
| loaded value | field present with serialized value |

An empty list serializes as a present empty collection, not as an omitted field. Deserializing an unloaded optional relation must not turn it into `loaded(null)`. The exact encoding is an implementation detail.

---

# Generated internal code

Generated code must not invoke safe or optional getters when it needs loading state. That includes ORM hydration, serialization, deserialization, `copyWith`, protocol conversion, persistence helpers, and equality or conversion logic.

```dart
'manager': manager?.toJson(), // wrong: evaluating manager may throw
```

This also applies to `copyWith`. Copying an unloaded model, for example `employee!.copyWith(name: 'John')`, must not evaluate `employee.company`, `employee.manager`, or `employee.reports`.

---

# Migration

Existing:

```yaml
class: Employee
table: employee
fields:
  name: String
  company: Company?, relation
  manager: Employee?, relation(optional)
  reports: List<Employee>?, relation
```

Opt in field by field. `manager` does not change:

```yaml
company: Company, relation
manager: Employee?, relation(optional)
reports: List<Employee>, relation
```

```dart
employee.company.name;          // was employee.company!.name
employee.manager == null;       // loaded and absent, or throws if unloaded
for (final report in employee.reports) { ... }  // was employee.reports!
```

---

# Resulting rule

> **Use nullability to describe actual domain nullability. Where existing Serverpod syntax uses nullability solely to represent unloaded state, retain that syntax as a legacy mode and allow users to opt into the safer non-nullable form.**

For optional to-one relations, `?` already represents real domain nullability, so the existing syntax becomes the safe contract directly. For safe and optional relations, unloaded state is a typed unloaded sentinel, not `null`.

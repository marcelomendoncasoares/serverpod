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

Lack of information is unloaded, never domain `null`.

---

# Declaration contract

| Model declaration | Getter type | Setter type (mutable models) | Unloaded access | Notes |
|---|---|---|---|---|
| `Company?, relation` | `Company?` | `Company?` | `null` | Legacy required to-one |
| `Company, relation` | `Company` | `Company` | throws | Safe opt-in. Does not change FK nullability |
| `Employee?, relation(optional)` | `Employee?` | `Employee?` | throws | Already the correct domain type. No `Employee, relation(optional)` form |
| `List<Employee>?, relation` | `List<Employee>?` | `List<Employee>?` | `null` | Legacy to-many |
| `List<Employee>, relation` | `List<Employee>` | `List<Employee>` | throws | Safe opt-in. Does not change the persisted schema |

Immutable models have no setters. Their write path is `copyWith`, with the same relation-state rules as below.

There is no meaningful domain-nullable collection. Once loaded, a list is either empty or contains rows, so `employee.reports.isEmpty` means loaded and empty.

On a safe optional relation, `employee.manager == null` means loaded and absent. It no longer also means “not loaded.” That is an intentional behavioral correction.

Users migrate required and to-many fields independently by dropping `?`. Optional declarations do not change.

---

# Internal representation

A sentinel is not the canonical loading-state representation. Storage is not part of the public contract.

```text
Required safe T:
  internal representation may be T? where null = unloaded

Optional T?:
  requires an extra state because null = loaded(null)

Safe List<T>:
  internal representation may be List<T>? where null = unloaded
```

A sentinel is necessary internally only where there are genuinely three states, or where Dart’s API/default-argument rules require one.

An unloaded state must never be observable as a domain `null` through a safe relation getter.

---

# Constructors

Keep Serverpod’s redirecting factory. Dart allows a redirecting factory to have an optional non-nullable named parameter with no default; omitted arguments are forwarded to the redirectee, whose parameter types and defaults decide the internal state.

```dart
abstract class Employee {
  factory Employee({
    required String name,
    Company company,
    Employee? manager,
    List<Employee> reports,
  }) = _EmployeeImpl;
}

class _EmployeeImpl implements Employee {
  _EmployeeImpl({
    required this.name,
    Company? company, // omitted -> null = unloaded
    Object? manager = _unloaded, // omitted -> unloaded; null -> loaded(null)
    List<Employee>? reports, // omitted -> null = unloaded
  });
}
```

| Argument | Required to-one | Optional to-one | To-many |
|---|---|---|---|
| omitted | unloaded | unloaded | unloaded |
| `null` | compile-time error | `loaded(null)` | compile-time error |
| domain value | `loaded(Company)` | `loaded(Employee)` | `loaded(list)`, including `[]` |

```dart
Employee(name: 'Ada');                       // relations omitted / unloaded
Employee(name: 'Ada', company: company);     // company loaded
Employee(name: 'Ada', company: null);        // compile error
Employee(name: 'Ada', manager: null);        // manager loaded(null)
Employee(name: 'Ada', reports: []);          // reports loaded empty
```

Callers cannot pass `null` for `company` or `reports` because those public parameters are non-nullable. Omission still constructs an unloaded relation because the redirectee accepts `T?`.

For optional relations, omission meaning unloaded while `manager: null` means `loaded(null)` is intentional: absence of an argument means the relation was not populated; explicit `null` means it is known to have no value. That is a behavior change for manually constructed objects; see Migration.

Legacy constructors are unchanged.

---

# `copyWith`

`copyWith` must distinguish omission from explicit values in order to preserve relation loading state. It uses Serverpod’s existing private `_Undefined` sentinel and `Object?` parameters, the same pattern generated models already use for nullable fields.

```dart
Employee copyWith({
  Object? company = _Undefined,
  Object? manager = _Undefined,
  Object? reports = _Undefined,
});
```

Omitted relations preserve their loaded/unloaded state and otherwise retain Serverpod's existing `copyWith` deep-copy semantics. Unloaded stays unloaded; `loaded(null)` stays `loaded(null)`; a loaded related model remains loaded and is copied according to existing `copyWith` behavior.

| Argument | Required to-one | Optional to-one | To-many |
|---|---|---|---|
| omitted / `_Undefined` | preserve | preserve | preserve |
| `null` | preserve | `loaded(null)` | preserve |
| domain value | loaded (deep-copied) | loaded (deep-copied) | loaded (deep-copied), including `[]` |

Explicit `null` on required and to-many parameters is not a domain value. It preserves, matching today’s non-nullable `copyWith` fields.

```dart
employee.copyWith();                 // preserves unloaded optional manager
employee.copyWith(manager: null);    // loaded(null)
employee.copyWith(reports: []);      // loaded empty
```

Immutable models use this same `copyWith` contract; they have no relation setters.

Legacy `copyWith` is unchanged. `Company?` and `List<Employee>?` legacy fields are not reinterpreted as safe relations.

---

# Generated implementation

Getters throw when the relation is unloaded:

```dart
Company? _company; // null = unloaded

Company get company {
  final value = _company;
  if (value == null) {
    throw RelationNotLoadedException(
      model: 'Employee',
      relation: 'company',
    );
  }
  return value;
}

set company(Company value) {
  _company = value;
}
```

`employee.reports = []` is loaded empty. `employee.manager = null` is `loaded(null)`.

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

The exception is part of the **common Serverpod runtime used by generated models on both server and client**, not only the server ORM package. Client-side getters have the same contract.

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

Serialization must preserve loading state and inspect raw internal state rather than throwing getters.

| State | Wire |
|---|---|
| unloaded | field omitted |
| `loaded(null)` (optional only) | field present with `null` |
| loaded value | field present with serialized value |

An empty list serializes as a present empty collection, not as an omitted field.

Cross-version behavior:

```text
new -> new:
  absent key    = unloaded
  explicit null = loaded(null)

old -> new:
  absent key    = unloaded
  (loaded(null) cannot be recovered)

new -> old:
  absent/null both degrade to legacy null
```

An old payload with an optional relation key absent is treated as **unloaded**, not `loaded(null)`. That is the only state justified by the information available. If the old sender had loaded the relation and found no row, that fact has been lost; throwing later is preferable to silently asserting that the relation is absent.

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

Optional `relation(optional)` fields start throwing when accessed while unloaded. That is an intentional behavioral correction, including for manually constructed objects:

```dart
Employee(name: 'Ada');                 // manager is unloaded; employee.manager throws
Employee(name: 'Ada', manager: null);  // manager is loaded(null); employee.manager == null
```

Previously both were indistinguishable `null`.

---

# Resulting rule

> **Use nullability to describe actual domain nullability. Where existing Serverpod syntax uses nullability solely to represent unloaded state, retain that syntax as a legacy mode and allow users to opt into the safer non-nullable form.**

For optional to-one relations, `?` already represents real domain nullability, so the existing syntax becomes the safe contract directly.

```text
Required safe relation
  public:   T
  internal: T? is sufficient
  unloaded access: throws

Optional relation
  public:   T?
  internal: needs 3 states
  unloaded access: throws
  loaded(null): returns null

Safe to-many
  public:   List<T>
  internal: List<T>? is sufficient
  unloaded access: throws
  loaded empty: []

Legacy required/to-many
  unchanged
```

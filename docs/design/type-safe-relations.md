# Type-safe relation loading

Model relation types can describe domain nullability independently of whether a
query included the relation. This implements
[issue #5727](https://github.com/serverpod/serverpod/issues/5727).

| Declaration | Public type | Reading before loading |
| --- | --- | --- |
| `company: Company?, relation` | `Company?` | Returns null (legacy) |
| `company: Company, relation` | `Company` | Throws `RelationNotLoadedError` |
| `manager: Employee?, relation(optional)` | `Employee?` | Throws `RelationNotLoadedError` |
| `reports: List<Employee>?, relation` | `List<Employee>?` | Returns null (legacy) |
| `reports: List<Employee>, relation` | `List<Employee>` | Throws `RelationNotLoadedError` |

Required and list relations opt in independently by dropping `?`. This changes
neither foreign key nullability nor the database schema. Optional to-one
relations, including those defined with nullable foreign keys, distinguish
unloaded from loaded null automatically. Non-nullable optional declarations are
rejected. The error extends `StateError` and is exported by the shared
serialization runtime on server and client. It represents a programming error
and is not caught by `on Exception` handlers.

## Constructing and loading models

Omitting a relation constructs an unloaded model. Required and list relation
constructor parameters accept domain values but reject explicit null. Optional
relations distinguish omission from explicit null:

```dart
Employee(name: 'Ada');                // manager is unloaded
Employee(name: 'Ada', manager: null); // manager is loaded and absent
Employee(name: 'Ada', reports: []);   // reports is loaded and empty
```

Queries with includes populate those states. Without includes, safe getters
throw even when an optional foreign key is null. On mutable models, assigning a
relation value marks it loaded; assigning null to an optional relation marks it
loaded and absent. Immutable models have no setters.

## Copying and serialization

`copyWith` preserves omitted relations and deep copies loaded related models and
lists. Explicit null preserves required and list relations; on optional
relations it means loaded and absent. Passing an empty list loads an empty list.
Copying, comparing immutable models, serialization, and generated persistence
helpers inspect stored state without invoking throwing getters.

Unloaded relations are omitted from JSON. Loaded optional nulls are emitted as
present keys with null values; loaded empty lists are present empty arrays. Both
`toJson` and `toJsonForProtocol` preserve these distinctions, as does `fromJson`.
An absent optional key from an older sender is unloaded: its original loading
state cannot be recovered. Older receivers treat omitted and null keys alike.

## Migration

Existing nullable required and list declarations retain their behavior. Opt in
one field at a time and remove null assertions or null-aware operators that only
represented loading state. Regenerate both server and client code.

Optional relation getters now throw when omitted from a constructor or query.
Use an include to establish loaded state, or pass explicit null when constructing
a model whose optional relation is known to be absent. A null optional getter
result means loaded and absent.

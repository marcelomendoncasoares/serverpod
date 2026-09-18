# Typed `copyWith` for Serverpod Object Fields

## Summary

Generated Serverpod `copyWith` methods must distinguish omitted arguments from explicit `null`. Today that is done by widening nullable object parameters to `Object?` and defaulting them to a private `_Undefined` sentinel:

```dart
class User {
  Address? address;
}

User copyWith({
  Object? address = _Undefined,
});
```

Application code conceptually accepts only `Address?`, but the generated signature does not say so.

This proposal generates a **private same-type undefined sentinel** for each Serverpod-generated model object, so `copyWith` parameters keep their domain type:

```dart
User copyWith({
  Address? address = _undefinedAddress,
});
```

```text
omitted       -> _undefinedAddress -> preserve
explicit null -> null              -> clear field
Address       -> Address           -> replace
```

This is independent of relation loading. Relation `copyWith` benefits from it, but does not own it. See [Type-safe relation loading](type_safe_relation_loading.md).

---

# Goals

1. Make generated `copyWith` parameter types match the field’s domain type for Serverpod objects and for collection types Serverpod can sentinel.
2. Preserve the existing three-way semantics: omit, set `null`, replace.
3. Keep per-model object sentinels private so application code cannot name them.
4. Leave Dart-disallowed scalar impersonation unchanged (`String?`, `int?`, `bool?`, `double?`, `num?`).
5. Preserve Serverpod’s existing `copyWith` deep-copy behavior.

---

# Scope

For **nullable fields whose type is a Serverpod-generated model object**, generated `copyWith` methods should use a private typed undefined sentinel instead of widening the parameter to `Object?`.

Applies to:

```yaml
address: Address?
settings: UserSettings?
metadata: SomeServerpodModel?
manager: Employee?, relation(optional)
```

whether or not the field is a relation.

The same three-way `copyWith` problem exists for **nullable collections**. Serverpod does not generate `List` or `Map`, but those are Dart interfaces, so a generic sentinel can implement them with `noSuchMethod` forwarders:

```dart
class $UndefinedList<T> extends UndefinedSentinel implements List<T> {
  const $UndefinedList();
}

class $UndefinedMap<K, V> extends UndefinedSentinel implements Map<K, V> {
  const $UndefinedMap();
}
```

```dart
User copyWith({
  List<Employee>? people = const $UndefinedList<Employee>(),
  Map<String, Address>? byId = const $UndefinedMap<String, Address>(),
});
```

`Set<T>?` is the same pattern. Nested collections work because the sentinel is generic (`$UndefinedList<List<Address>>()`).

Shared sentinels live in **`serverpod_serialization`**, next to the existing `copyWith` clone helpers. Generated server and client models already import that package, so they can use the same defaults without a new dependency.

That package owns:

- `UndefinedSentinel` (the `noSuchMethod` base)
- `$UndefinedList<T>`, `$UndefinedMap<K, V>`, `$UndefinedSet<T>`
- `$UndefinedDateTime`, `$UndefinedUuidValue`, `$UndefinedDuration`, `$UndefinedUri`

These are generated-code infrastructure, not application API. A `$` prefix keeps them out of ordinary naming. Per-model sentinels such as `_undefinedAddress` stay library-private in the generated model file and **extend** `UndefinedSentinel` from `serverpod_serialization`.

The same `implements` + `noSuchMethod` trick works for several **core / package types** that are ordinary classes, not forbidden Dart primitives:

```dart
class $UndefinedDateTime extends UndefinedSentinel implements DateTime {
  const $UndefinedDateTime();
}

class $UndefinedUuidValue extends UndefinedSentinel implements UuidValue {
  const $UndefinedUuidValue();
}

class $UndefinedDuration extends UndefinedSentinel implements Duration {
  const $UndefinedDuration();
}

class $UndefinedUri extends UndefinedSentinel implements Uri {
  const $UndefinedUri();
}
```

```dart
User copyWith({
  DateTime? createdAt = const $UndefinedDateTime(),
  UuidValue? uuid = const $UndefinedUuidValue(),
});
```

It does **not** work for types Dart forbids implementing:

```dart
String   // subtype_of_disallowed_type
int
bool
double
num
BigInt   // final, cannot be implemented outside its library
```

Those retain:

```dart
Object? value = _Undefined
```

There is no same-type fake `String` or `int`. A reserved real value (`''`, `0`, a private-use character) would type-check, but could collide with a legitimate field value, so it is not used.

---

# Public contract

Before:

```dart
User copyWith({
  Object? address = _Undefined,
  String? name,
});
```

After:

```dart
User copyWith({
  Address? address = _undefinedAddress,
  String? name,
});
```

| Argument | Meaning |
|---|---|
| omitted | Preserve the current value (deep-copied per existing `copyWith` rules) |
| `null` | Set the field to `null` |
| `Address` | Replace the field (deep-copied per existing `copyWith` rules) |

`user.copyWith()` and `user.copyWith(address: null)` remain distinguishable. The public parameter type is `Address?`.

---

# Generated sentinel

For each generated model `Address`, generate a private same-type sentinel in that model’s library, extending `UndefinedSentinel` from `serverpod_serialization`:

```dart
class _UndefinedAddress extends UndefinedSentinel implements Address {
  const _UndefinedAddress();
}

const Address _undefinedAddress = _UndefinedAddress();
```

Overriding `noSuchMethod` makes the compiler insert interface forwarders, so the sentinel does not reimplement every `Address` member.

The sentinel is a library-private symbol. Callers can omit the `copyWith` argument; they cannot write `_undefinedAddress`.

Detection in generated `copyWith`:

```dart
address: identical(address, _undefinedAddress) ? this.address : address
```

or `address is UndefinedSentinel`, as long as a real `Address` is never a sentinel.

Defensive setters on mutable models may reject a leaked sentinel with `ArgumentError`. That is not a supported public operation.

---

# Non-nullable object parameters

The same private sentinel also lets a `copyWith` parameter stay non-nullable `T` when `null` must be a compile-time error — used by safe required relations and safe to-many relations in [type-safe relation loading](type_safe_relation_loading.md):

```dart
Employee copyWith({
  Company company = _undefinedCompany,
  List<Employee> reports = _undefinedReports,
});
```

```text
omitted     -> preserve
Company     -> replace
null        -> compile error
```

Ordinary methods cannot make a non-nullable named argument optional without a default. The typed sentinel is that default. Safe to-many relations use the same generic list sentinel with a non-nullable `List<T>` parameter so `copyWith(reports: null)` does not compile.

---

# Out of scope

- Changing constructor signatures.
- Changing serialization.
- Manufacturing sentinels for types Dart forbids implementing (`String`, `int`, `bool`, `double`, `num`, `BigInt`).
- Making sentinels part of application-facing API.

---

# Relation loading

[Type-safe relation loading](type_safe_relation_loading.md) needs `copyWith` to distinguish omission from explicit values in order to preserve loading state. Optional object relations then use this improvement directly:

```dart
Employee copyWith({
  Employee? manager = _undefinedEmployee,
});
```

```dart
copyWith()              // preserve relation state
copyWith(manager: null) // loaded(null)
copyWith(manager: x)    // loaded(x)
```

---

# Resulting rule

> **Where a same-type undefined sentinel can be constructed — generated model objects, `List` / `Map` / `Set`, and impersonable classes such as `DateTime`, `UuidValue`, `Duration`, and `Uri` — generated `copyWith` should advertise that type. `_Undefined` as `Object?` remains only for types Dart will not let Serverpod implement (`String`, `int`, `bool`, `double`, `num`, `BigInt`).**

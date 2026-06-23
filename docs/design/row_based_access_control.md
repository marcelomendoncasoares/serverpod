# Design: Row-Based Access Control (`secure` keyword)

## Summary

Serverpod has no built-in mechanism to restrict access to individual database
rows based on the authenticated user. Developers must enforce ownership and
multi-tenancy rules manually in endpoint or business logic, which is verbose,
easy to get wrong, and impossible to audit centrally.

This design introduces **row-based access control** declared in the model YAML
via an enhanced `secure` keyword. A protected table restricts access to rows
where a model field matches a value from the request's `AuthenticationInfo`
(initially `userIdentifier`). Restrictions are enforced at the database layer using
PostgreSQL's native **Row-Level Security (RLS)**: policies are generated as part
of database migrations, and Serverpod seeds a per-transaction session variable
(`SET LOCAL serverpod.user_id = …`) into the transaction so the policies resolve
against the authenticated user. Developers query secured tables through a
dedicated, user-scoped transaction (`session.db.transactionForUser(...)`); the
framework supplies the identity, never the developer.

```yaml
class: Channel
table: channel
secure: userIdentifier=author
fields:
  name: String
  channel: String
  author: UuidValue
```

`AuthenticationInfo.userIdentifier` is always a UUID (as issued by the Serverpod
auth modules), so the matched field is a UUID column.

The `secure` keyword accepts a **list of conditions** so it can grow toward
scope/role checks (`secure: userIdentifier=author, scope=admin`) without a syntax
break.

## Goals

- Declarative, per-table row access control in the model YAML.
- Enforcement at the database layer via PostgreSQL RLS policies emitted into
  migrations.
- Automatic, transparent propagation of the authenticated user's identity (and
  later scopes) to the database for every request.
- A condition grammar that is a list from day one, so `scope=…` and other
  `AuthenticationInfo` fields can be added later without breaking existing
  models.

## Non-Goals (initial milestone)

- Full scope/role evaluation (`scope=admin`). The grammar and migration format
  reserve space for it; enforcement is a follow-up.
- Matching arbitrary `AuthenticationInfo` fields. Only `userIdentifier` is mapped
  first.
- SQLite enforcement. SQLite has no RLS; for SQLite targets the feature is a
  validated no-op at the SQL layer (see [SQLite](#sqlite-and-non-postgres-targets)).
- Generated application-layer query rewriting (auto-injecting `WHERE author = …`
  into every generated query). Considered as an alternative below but not the
  primary mechanism.

## Background: relevant existing systems

The implementation threads through four layers. Key entry points discovered in
the codebase:

### 1. Model parsing (CLI)

- Keyword constants: [keywords.dart](../../tools/serverpod_cli/lib/src/analyzer/models/validation/keywords.dart)
  (`class`, `table`, `managedMigration`, `fields`, `indexes`, …).
- Parser: [model_parser.dart](../../tools/serverpod_cli/lib/src/analyzer/models/model_parser/model_parser.dart)
  — `_parseClassFile` reads `table`/`managedMigration` (≈ lines 31–65) and builds
  the `ModelClassDefinition`.
- In-memory definition: `ModelClassDefinition` in
  [definitions.dart](../../tools/serverpod_cli/lib/src/analyzer/models/definitions.dart)
  (≈ lines 171–214) holds `tableName`, `indexes`, `manageMigration`, etc.
- Validation: [restrictions.dart](../../tools/serverpod_cli/lib/src/analyzer/models/validation/restrictions.dart)
  and the allowed-keys schema in
  [class_yaml_definition.dart](../../tools/serverpod_cli/lib/src/analyzer/models/yaml_definitions/class_yaml_definition.dart).

### 2. Database definition model (serverpod_database)

The schema is itself described with Serverpod models (`*.spy.yaml`) and code-
generated:

- [table_definition.spy.yaml](../../packages/serverpod_database/lib/src/models/table_definition.spy.yaml)
  — `name`, `columns`, `foreignKeys`, `indexes`, `managed`, …
- Sibling definitions: `column_definition`, `index_definition`,
  `foreign_key_definition`, `database_definition`.
- These serialize into the migration's `definition.json` (see below), so any new
  field is persisted in every migration's schema snapshot.

### 3. Model → DatabaseDefinition conversion + SQL generation (CLI)

- `createDatabaseDefinitionFromModels` in
  [create_definition.dart](../../tools/serverpod_cli/lib/src/database/create_definition.dart)
  maps each `ModelClassDefinition` into a `TableDefinition`.
- DDL generation: `PostgresSqlGenerator` and the `…PgSqlGeneration` extensions in
  [postgres.dart](../../tools/serverpod_cli/lib/src/database/dialects/postgres.dart)
  — `tableCreationToPgsql()` emits `CREATE TABLE`/indexes; the
  `DatabaseMigration` extension emits incremental `ALTER TABLE` SQL.
  [sqlite.dart](../../tools/serverpod_cli/lib/src/database/dialects/sqlite.dart)
  is the SQLite counterpart.
- Migration diffing: `generateDatabaseMigration` / `generateTableMigration` in
  [migration.dart](../../tools/serverpod_cli/lib/src/database/migration.dart)
  diff two `DatabaseDefinition`s into `DatabaseMigrationAction`s
  (`createTable` / `alterTable` / `deleteTable`). `TableMigration`
  ([table_migration.spy.yaml](../../packages/serverpod_database/lib/src/models/table_migration.spy.yaml))
  carries `addColumns`/`deleteColumns`/`addIndexes`/… and is where row-security
  changes must be represented for alters.
- Migration artifacts are written as `definition.json`, `definition.sql`,
  `migration.json`, `migration.sql` — paths in
  [constants.dart](../../packages/serverpod_shared/lib/src/constants.dart)
  (`MigrationConstants`). `migrationApiVersion` currently `1`.

### 4. Runtime (serverpod)

- `AuthenticationInfo`
  ([authentication_info.dart](../../packages/serverpod/lib/src/authentication/authentication_info.dart))
  exposes `userIdentifier` (a String — e.g. an auth-user UUID), `scopes`
  (`Set<Scope>`), and `authId`. **Note:** there is no `userId` field; the
  proposal's `userId` maps to `userIdentifier` (see
  [Identity mapping](#identity-mapping)).
- A `Session` holds the current `AuthenticationInfo` via `authenticated`
  ([session.dart](../../packages/serverpod/lib/src/server/session.dart) ≈ line 64).
- **Runtime parameter infrastructure already exists.** `RuntimeParameters`
  ([runtime_parameters.dart](../../packages/serverpod_database/lib/src/concepts/runtime_parameters.dart))
  builds `SET [LOCAL] <key> = <value>` statements; `Transaction.setRuntimeParameters`
  ([transaction.dart](../../packages/serverpod_database/lib/src/concepts/transaction.dart))
  and the Postgres implementation
  ([database_connection.dart](../../packages/serverpod_database/lib/src/adapters/postgres/database_connection.dart) ≈ line 1191)
  apply them with `isLocal: true`. This is the primary tool for `SET LOCAL
  serverpod.user_id`.
- `DatabaseInterceptor`
  ([serverpod.dart](../../packages/serverpod/lib/src/server/serverpod.dart) ≈ line 40)
  lets a custom `Database` wrap the framework default per `Session` — a clean
  hook for injecting auth context into every database call.

## Proposed solution

### `secure` keyword syntax

```yaml
secure: userIdentifier=author                 # single condition
secure: userIdentifier=author, scope=admin    # list of conditions (future scope eval)
```

Grammar (parsed into a list of conditions regardless of count):

```
secure      := condition ( "," condition )*
condition   := authField "=" target
authField   := "userIdentifier" | <reserved: "scope", others later>
target      := <model field name>   (for userIdentifier)
             | <scope name>          (for scope, future)
```

Parsed representation — a new value object, e.g. `RowSecurityCondition { AuthField field; String target; }`, collected into
`ModelClassDefinition.securityConditions` (empty list when `secure` absent).

### Identity mapping

| `secure` token   | `AuthenticationInfo` source         | Notes |
| ---------------- | ----------------------------------- | ----- |
| `userIdentifier` | `AuthenticationInfo.userIdentifier` | Always a UUID (as issued by the Serverpod auth modules). |
| `scope` (later)  | `AuthenticationInfo.scopes`         | `Set<Scope>` → comma-joined string for `serverpod.scopes`. |

`userIdentifier` is always a UUID, so the matched model field is a UUID column
(`UuidValue`). The session variable is written as text and the policy casts it
back to `uuid` for the comparison:
`"author" = NULLIF(current_setting('serverpod.user_id', true), '')::uuid`. An unset variable
yields `NULL::uuid` → no match (safe). Validation should require the matched field
to be a UUID column and produce a clear error otherwise.

### Enforcement: PostgreSQL native RLS (primary)

For each secured table the migration emits, in addition to `CREATE TABLE`:

```sql
ALTER TABLE "channel" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "channel" FORCE ROW LEVEL SECURITY;  -- so table owner is also bound

CREATE POLICY "channel_rls_userIdentifier_author" ON "channel"
  USING ("author" = NULLIF(current_setting('serverpod.user_id', true), '')::uuid);
```

At runtime, before any query in a request touches the database, Serverpod sets
the session variable for the current transaction:

```sql
SET LOCAL serverpod.user_id = '123';
-- future: SET LOCAL serverpod.scopes = 'admin,read_only';
```

`current_setting('serverpod.user_id', true)` returns `NULL` when unset (the
`true` = `missing_ok`), so an unauthenticated/uninitialised connection matches no
rows — a safe default. Internal/maintenance sessions that must bypass RLS connect
as a role with `BYPASSRLS` (see [Privileged sessions](#privileged-and-internal-sessions)).

### Runtime injection — a dedicated `transactionForUser`

**Design decision:** secured tables are queried **only** inside an explicit,
user-scoped transaction opened with a dedicated method —
`session.db.transactionForUser(...)` — that the developer passes to the operation.
The framework does **not** open transactions automatically, and does **not** seed
the auth context onto the plain `transaction()` primitive:

- Auto-wrapping every CRUD call would branch the entire ORM (every generated
  method, every code path) and pollute the codebase.
- Auto-seeding the plain `transaction()` would make the single most
  security-relevant property — "is this query scoped to the current user?" —
  invisible at the call site and dependent on ambient session state. Two identical
  `transaction()` calls would return different rows depending on auth.

A dedicated `transactionForUser` keeps that intent **explicit, greppable, and
auditable**, and lets the call fail loud instead of silently empty:

```dart
// Developer code — user-scoped transaction for operations on secured tables.
await session.db.transactionForUser((tx) async {
  // The framework seeded `SET LOCAL serverpod.user_id` on `tx` from
  // session.authenticated, so RLS resolves to the current user.
  return Channel.db.find(session, transaction: tx);
});
```

Semantics:

- **Identity comes from the session, never a parameter.** `Session` exposes the
  settings as `transactionForUserSettings`
  (`{'serverpod.user_id': authenticated.userIdentifier}` when authenticated, else
  `null`); `transactionForUser` applies them. No `userId` argument in the common
  path — an explicit id would be an impersonation footgun. (An advanced
  `actingAs`-style overload gated for system/bypass use can be added later.)
- **Throws a clear error when the session provides no settings** (for example,
  when it is not authenticated), rather than opening an unscoped transaction that
  silently returns zero rows from secured tables.
- **Plain `transaction()` stays the unscoped primitive** — no auth context. It is
  used by system/admin code and the `BYPASSRLS` paths. Touching a secured table
  inside a plain `transaction()` (or with no transaction at all) leaves the
  session variable unset, so the policy matches no rows — a safe default. The
  policy wraps the value in `NULLIF(current_setting(...), '')` so that an unset or
  empty variable resolves to `NULL` rather than failing the `::uuid` cast on a
  pooled connection where the placeholder has already been registered.

The mechanism is a **generic passthrough**, so `serverpod_database` stays unaware
of authentication:

- `DatabaseSession` exposes `Map<String, String>? get transactionForUserSettings`.
  `Session` is the only auth-aware piece, populating it from
  `authenticated.userIdentifier`; this lives in the `serverpod` package. The
  variable name is the shared `RowSecurityConstants.userIdParameter` (in
  `serverpod_shared`), the single source of truth used by both the policy
  generator and the runtime so they cannot drift.
- `Database.transactionForUser` is an **extension** over `transaction()` and
  `transactionForUserSettings`. It opens a transaction, applies the settings as
  `SET LOCAL` runtime parameters (`MapRuntimeParameters` +
  `Transaction.setRuntimeParameters`), runs the developer's function, and throws a
  `StateError` if the session provides none. Being an extension rather than an
  instance method, database wrappers — such as the test rollback proxy that
  `implements Database` — get the correct behavior through their own
  `transaction()` without reimplementing it; they only provide the
  `transactionForUserSettings` getter.

The developer never writes the `SET LOCAL` themselves; they only choose the right
transaction method.

This also sidesteps the pooled-connection problem. `SET LOCAL` lives only for the
current transaction, and Serverpod uses a pooled connection — so a non-`LOCAL`
`SET` would leak the previous user's identity onto the next request reusing that
connection. Because the context is only ever set `LOCAL` on an explicit
transaction, it is bound to, and torn down with, that transaction; nothing persists
on the pooled connection.

The context is set once on the outermost transaction; nested transactions /
savepoints inherit it. Developer ergonomics — needing `transactionForUser` to read
secured tables — is an accepted trade-off for keeping the ORM untouched and the
security boundary explicit.

### Definition & migration format changes

Add row-security to the persisted schema so migrations diff and reproduce it:

- New model `row_security_policy_definition.spy.yaml` (name, condition list:
  auth field + target column/value).
- `TableDefinition` gains `rowSecurity: List<RowSecurityPolicyDefinition>?`
  (nullable for backward-compatible `definition.json` of existing migrations).
- `TableMigration` gains `addRowSecurity` / `dropRowSecurity` (or a single
  `rowSecurity` replacement) so `alterTable` can enable/disable/replace policies.
- No `migrationApiVersion` bump required: every new field is optional/nullable, so
  existing `definition.json` files deserialize unchanged and older readers ignore
  the new keys.

## Implementation plan

Sequenced so each phase compiles and is independently testable.

### Phase 1 — Model layer (parse + validate, no SQL yet)

1. Add `secure` to
   [keywords.dart](../../tools/serverpod_cli/lib/src/analyzer/models/validation/keywords.dart).
2. Add `RowSecurityCondition` value object + `List<RowSecurityCondition>
   securityConditions` to `ModelClassDefinition` in
   [definitions.dart](../../tools/serverpod_cli/lib/src/analyzer/models/definitions.dart).
3. Parse `secure` in
   [model_parser.dart](../../tools/serverpod_cli/lib/src/analyzer/models/model_parser/model_parser.dart)
   (alongside `table`/`managedMigration`), splitting on `,` then `=`.
4. Validation in
   [restrictions.dart](../../tools/serverpod_cli/lib/src/analyzer/models/validation/restrictions.dart)
   + allowed-key registration in
   [class_yaml_definition.dart](../../tools/serverpod_cli/lib/src/analyzer/models/yaml_definitions/class_yaml_definition.dart):
   - `secure` requires `table:` to be set.
   - LHS must be a known auth field (`userIdentifier`; reject `scope` with a "not
     yet supported" message until Phase 6).
   - RHS (for `userIdentifier`) must name an existing field on the model, and that
     field must be a UUID column (`UuidValue`) — error otherwise.
   - Clear errors for malformed syntax.

### Phase 2 — Database definition model

1. Add `row_security_policy_definition.spy.yaml`; extend
   [table_definition.spy.yaml](../../packages/serverpod_database/lib/src/models/table_definition.spy.yaml)
   with `rowSecurity: List<RowSecurityPolicyDefinition>?`.
2. Extend
   [table_migration.spy.yaml](../../packages/serverpod_database/lib/src/models/table_migration.spy.yaml)
   to represent row-security add/drop.
3. Regenerate serverpod_database models (`serverpod generate`) and update
   `protocol.dart`/exports.

### Phase 3 — Conversion

1. In
   [create_definition.dart](../../tools/serverpod_cli/lib/src/database/create_definition.dart),
   map `ModelClassDefinition.securityConditions` →
   `TableDefinition.rowSecurity`.

### Phase 4 — SQL generation

1. In
   [postgres.dart](../../tools/serverpod_cli/lib/src/database/dialects/postgres.dart):
   - `tableCreationToPgsql()` (and `definition.sql`) emit `ENABLE/FORCE ROW LEVEL
     SECURITY` + `CREATE POLICY` for each policy.
   - The `DatabaseMigration` → SQL path emits enable/`CREATE POLICY` /
     `DROP POLICY` for `alterTable` actions; drop-table cleans up implicitly.
   - Deterministic policy names (e.g. `<table>_rls_<authField>_<target>`).
2. In
   [migration.dart](../../tools/serverpod_cli/lib/src/database/migration.dart):
   `generateTableMigration` detects row-security differences and records them on
   `TableMigration`.

### Phase 5 — Runtime injection

1. Add `Map<String, String>? get transactionForUserSettings` to the
   `DatabaseSession` interface
   ([database_session.dart](../../packages/serverpod_database/lib/src/interface/database_session.dart));
   the non-auth implementors return `null`.
2. Implement the getter on `Session`
   ([session.dart](../../packages/serverpod/lib/src/server/session.dart)),
   returning `{'serverpod.user_id': authenticated.userIdentifier}` when
   authenticated, else `null`.
3. Add `transactionForUser` as an **extension** on `Database`
   ([database.dart](../../packages/serverpod_database/lib/src/database.dart)) that
   opens a transaction, applies `transactionForUserSettings` as `SET LOCAL`
   parameters (`MapRuntimeParameters` + `Transaction.setRuntimeParameters`), and
   throws when none are present. The plain `transaction()` primitive stays
   unscoped, and the framework does **not** open transactions automatically (see
   [Runtime injection](#runtime-injection--a-dedicated-transactionforuser)).
4. Ensure internal/maintenance sessions (future calls, migrations, health
   checks) bypass RLS by connecting as a dedicated `BYPASSRLS` role (see
   [Privileged sessions](#privileged-and-internal-sessions)).

### Phase 6 — Scopes (follow-up)

1. Accept `scope=…` in the grammar; map `AuthenticationInfo.scopes` →
   `SET LOCAL serverpod.scopes`.
2. Generate policies referencing
   `current_setting('serverpod.scopes', true)` and document the matching
   semantics (membership in a comma-separated list).

### Phase 7 — Tests & docs

- CLI unit tests: parsing, validation, `create_definition` mapping, Postgres SQL
  (`tableCreationToPgsql` + migration diff), SQLite no-op.
- serverpod_database/integration tests: RLS enforced under Postgres — an
  authenticated session sees only its rows; switching `serverpod.user_id`
  switches visibility; unset → no rows; bypass role sees all.
- Golden migration test: a secured model produces the expected
  `definition.sql` / `migration.sql` policy statements.
- Docs: a row-based access control page (and an entry under
  `docs/design/` cross-link) covering syntax, identity mapping, and the
  PostgreSQL-only caveat.

## SQLite and non-PostgreSQL targets

SQLite has no row-level security. For SQLite generation
([sqlite.dart](../../tools/serverpod_cli/lib/src/database/dialects/sqlite.dart))
row-security is a no-op at the DDL layer. Because much of the test suite and some
deployments use SQLite, the validator should emit a warning (not a hard error)
that `secure` is unenforced on SQLite, so behavior is explicit rather than
silently insecure.

## Alternatives considered

- **Generated application-layer query filtering** — auto-inject `WHERE author =
  :currentUser` into every generated query/`Table`. Pros: DB-agnostic, no RLS
  role management, works on SQLite. Cons: only covers generated queries (raw SQL
  and `unsafeQuery` bypass it), weaker guarantee than the proposal's
  "enforce at the data layer," and easy to circumvent. Could be layered on later
  as defense-in-depth but is not the primary mechanism the proposal asks for.
- **Manual endpoint filtering** — the status quo; rejected (the motivation).
- **External/hand-managed Postgres RLS** — not integrated with migrations or
  auth; rejected.

## Resolved decisions

- **Pooled-connection leakage — resolved.** Secured tables are queried only inside
  an explicit transaction that the developer passes; the framework seeds the auth
  context onto it with `SET LOCAL`. The context is bound to the transaction and
  never persists onto the pooled connection. It is set once on the outermost
  transaction (nested transactions/savepoints inherit it).
- **No automatic transactions — resolved.** The framework does not auto-wrap CRUD
  calls in transactions; that would branch the entire ORM and pollute the code.
  Developers open a transaction and pass it to operations on secured tables.
- **Dedicated `transactionForUser` — resolved.** Rather than auto-seeding the auth
  context onto the plain `transaction()` (ambient, invisible at the call site),
  user scoping is opted into explicitly via `session.db.transactionForUser(...)`.
  It derives the user from `session.authenticated`, throws if unauthenticated, and
  keeps `transaction()` as the unscoped primitive for system/`BYPASSRLS` paths.
  Chosen for explicitness, auditability, and a loud (not silently-empty) failure
  mode.
- **Performance — accepted.** The extra round trips per developer-opened
  transaction are acceptable for the first iteration and can be optimized later.
- **Identity type — resolved.** `userIdentifier` is always a UUID, so the matched
  field is a UUID column. The policy casts the session variable back to `uuid`
  (`... = NULLIF(current_setting('serverpod.user_id', true), '')::uuid`); validation requires
  the matched field to be a UUID column.
- **Keyword naming — resolved.** Use `userIdentifier` as the public keyword token
  (matches the runtime field, always a UUID). No `userId` alias.
- **Migration format/version — resolved.** All new definition/migration fields are
  optional, so the change is backward compatible; no `migrationApiVersion` bump.
- **Bypass surfaces — documented.** `unsafeQuery` and direct pool access bypass
  RLS by design; this boundary will be documented so users understand it.

## Privileged and internal sessions

Internal/maintenance work — migrations, future calls, health checks, admin
tooling — must read/write all rows regardless of RLS.

**Decision: a dedicated `BYPASSRLS` role.** The trust boundary lives in
PostgreSQL rather than in application logic: the normal runtime role is
*incapable* of bypassing RLS, so correctness of the feature does not hinge on
remembering an opt-out on every internal call site. A bug or a missed code path
cannot accidentally leak data, because the runtime role simply *cannot* see other
users' rows. Concretely:

- The normal runtime database role is **not** `BYPASSRLS`, and secured tables use
  `FORCE ROW LEVEL SECURITY` so even the table owner is bound by policies.
- A separate role with `BYPASSRLS` (used via its own connection or `SET ROLE`) is
  used for migrations and internal/maintenance sessions.
- Document this clearly so operators provision the roles and avoid locking
  themselves out.

## Backwards compatibility

- `secure` is opt-in; models without it generate identical SQL and definitions.
- `TableDefinition.rowSecurity` is nullable, so previously generated
  `definition.json` files deserialize unchanged.
- No change to generated Dart CRUD APIs in the primary (RLS) design; enforcement
  is transparent at the database layer.

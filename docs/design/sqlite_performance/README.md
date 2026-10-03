# SQLite execution performance

Measured while implementing `perf/sqlite-execution`, based on
`5410f872fd8ada1908524a8c915ae16588058567` (September 2026).
The incremental table records each change when it was implemented. Review
subsequently disabled driver statement caching and changed maintenance locking;
measurements with those settings are recorded separately below. The public cache
option was later removed. Gains must not be added together.

## Measurements

Native Dart 3.12.2 on Linux/WSL2, warmed JIT with `-Ddart.vm.product=true`,
SQLite through the resolved `sqlite_async` 0.14.5 driver, temporary disk databases,
WAL and the driver's default synchronous setting. Seven measured samples follow
three or five warmups; setup is outside timing. The main measurements ran
without test suites in parallel. The host was not otherwise isolated, so small
differences are inconclusive. Times are milliseconds per workload, not per row.

| Change | Workload | Before | After | Interpretation |
| --- | --- | ---: | ---: | --- |
| Linear relation grouping | Include 10,000 children of one parent, ordered by ID | 187.386 | 45.471 | 4.12x faster |
| Keep update selection in SQL | Update 10,000 rows with `noReturn` | 36.693 | 3.908 | 9.39x faster |
| Batch bound writes | Insert 1,000 rows with `noReturn` | 141.078 | 3.564 | 39.58x faster |
| Batch bound writes | Update 1,000 rows with `noReturn` | 114.164 | 2.724 | 41.91x faster |
| Normalize results once | Find 10,000 parents with nested includes | 303.453 | 301.433 | No clear timing gain |
| Return only upsert IDs | Upsert 1,000 rows, each with 4 KB text and a 100-element list, `noReturn` | 690.548 | 464.851 | 1.49x faster |
| Bind returning writes with experimental caching | Insert 1,000 rows with returned models | 150.011 | 142.317 | Small, inconclusive |
| Bind returning writes with experimental caching | Update 1,000 rows with returned models | 139.936 | 127.133 | Small, inconclusive |
| Skip parsing generated SQL | Find 1,000 rows individually by ID | 239.837 | 146.248 | 1.64x faster |
| Add literal-default columns directly | Add boolean default to a table containing 100,000 rows | 40.575 | 7.193 | 5.64x faster |
| Maintain planner statistics | 100 lookups on 100,000 rows with competing indexes | 595.190 | 39.444 | 15.09x faster for this deliberately skewed fixture |

The initial cache before/after read comparison regressed (171.409 to 209.823 ms).
A follow-up alternating same-process experiment used cache sizes 0, 100, 100, 0,
with five warmups and eleven samples per configuration. The medians for 1,000
parameterized adapter reads were 163.283, 133.744, 134.085, and 143.217 ms.
This supports a modest cache benefit, but the spread does not justify a precise
percentage claim. Review found that the driver caches complete SQL text,
including large literals used by some ORM operations at that revision. The
public cache option was subsequently removed: the modest, noisy benefit did not
justify the additional API and memory-retention trade-off. The per-connection
driver cache is explicitly disabled. Parameter binding and statement reuse
within each bounded batch remain enabled; each batch closes its prepared
statements before returning. The cache measurements above are historical
experiments, not claimed improvements in the final implementation.

The planner fixture has `a=1` for every row and a distinct `b` per row, indexed
separately. Before maintenance, SQLite chose the `a` index; afterwards, it chose
`b`. This demonstrates a fix for missing statistics, not a universal query gain.
Timing excludes opening the database and therefore excludes startup maintenance
cost. A separate five-reader empty-database open/close comparison measured
22.811 ms before maintenance versus 30.003 ms afterwards (five warmups, eleven
samples). The final maintenance design below replaces the exclusive pool lock,
which review found could deadlock under contention. The reader regression
verifies planner statistics refresh; busy readers use a best-effort timed lease.

## Final defaults after review

Re-measured at `594c9f9ab`, with statement caching disabled and bounded analysis
using the writer followed by individual reader refreshes:

| Workload | Final median (ms) |
| --- | ---: |
| Insert 1,000 rows, `noReturn` | 3.460 |
| Update 1,000 rows, `noReturn` | 2.873 |
| Upsert 1,000 wide rows, `noReturn` | 242.902 |
| Find 1,000 rows individually by ID | 177.685 |
| 100 lookups on the skewed 100,000-row fixture | 43.183 |

An additional open/close comparison with caching disabled on both sides measured
25.433 ms without maintenance and 27.703 ms with final maintenance. The sample
ranges overlap (20.574–36.615 and 24.678–35.119 ms), so this does not establish a
precise startup overhead. The clear batching gains remain with caching disabled.
The final upsert result includes later parser-bypass changes as well as the
narrower returned projection; it is not attributable to one change alone.

Raw medians and sample ranges are retained in [measurements.json](measurements.json).
The scratch harnesses and full test logs for this run are in
`/tmp/serverpod-sqlite-perf/`; they are local artifacts, not repository fixtures.
A representative invocation was:

```sh
dart --packages=.dart_tool/package_config.json -Ddart.vm.product=true \
  /tmp/serverpod-sqlite-perf/implementation/bulk.dart batch upsert
```

## Preserved behavior

- Execute writes in input order, retaining trigger order and generated-ID
  behavior. Returning batches reuse preparations across interleaved shapes
  without reordering inputs. All chunks share one transaction or savepoint.
- Bind data values, including binary views, JSON, UUIDs, and SQL punctuation.
- Preserve upsert duplicate-target errors and `updateWhere` skips; UUID IDs are
  compared by value.
- Raw SQL retains parsing and script atomicity. Generated SQL uses the driver's
  single-statement API, with reads routed to reader connections.
- Literal defaults use `ADD COLUMN`; expressions and constraint changes retain
  the table rebuild path.
- Planner maintenance runs at startup, daily, and within schema migrations.
  Analysis is bounded with mask `0x10012`. The writer is released before
  best-effort reader refreshes through individual one-second leases. Refresh
  uses `writable_schema=RESET`, which disables schema writes and reloads cached
  schema state. Shutdown cancels the timer and waits for pending maintenance;
  restarting during shutdown is rejected.

SQLite documents [planner maintenance](https://www.sqlite.org/lang_analyze.html)
and the [RESET behavior](https://www.sqlite.org/pragma.html#pragma_writable_schema).
Statistics can change query plans; their benefit depends on the data.

## Validation

Completed validation:

- Database package: 871 tests passed, including embedded PostgreSQL checks.
- SQLite client suite: 590 passed, one existing skip.
- Full SQLite server integration suite: 1,439 passed, one existing skip.
- CLI database migration and SQL-generation suite: 767 passed.
- Database configuration tests: 50 passed.
- Chrome affected CRUD, rollback, pagination, and list-include suites: 55 passed.
- Static analysis and formatting passed for the changed code.
- Added regressions cover batch rollback, typed values and quoting, generated
  IDs, duplicate upserts, pagination, cached schema changes, literal defaults,
  planner refresh, and pool shutdown/restart.

Browser validation exposed a nested-lock issue in the driver's web
`withAllConnections` implementation. Maintenance now uses the normal write lock
when there are no reader connections. All 55 browser checks passed after that
fix. After the review corrections, the 871 database-package tests, 590 client
tests, and all 55 browser checks passed again; the eight maintenance/migration
regressions include the new native deadlock case.

## Adversarial review

Opus xhigh reviewed the implementation through Orca orchestration. The first
pass reported two significant open findings, both addressed:

- **Native maintenance deadlock:** exclusive pool access could wait behind a
  transaction whose independent read then waited behind maintenance. Commit
  `594c9f9ab` uses separate writer and reader leases. The new adapter regression
  fails with a two-second timeout against `0f4f48841` and passes after the fix.
- **Literal retention by the statement cache:** the review's 100 × 1 MiB blob
  update reproduction reported 540 MiB RSS growth with cache size 100 versus
  57 MiB with caching disabled. Commit `3b3f06a07` restored the default to zero.
  The public cache option was later removed, while retaining statement reuse
  within each bounded batch.

The follow-up Opus xhigh review of `594c9f9ab` reported **no remaining significant
findings**. The reviewer independently reproduced completion with the revised
locking pattern (413 ms) and ran the four pool-maintenance tests successfully.
Orca run `run_748f2cacf2c8` records both accepted reviews (dispatches
`ctx_a7aa66d8f815` and `ctx_ad6380b718e2`).

Shutdown can wait for active maintenance, including up to one second per reader
lease attempt. Driver statement caching remains disabled; statement reuse
within an ordered batch ends when that batch completes.

## Returning write investigation

Investigated on September 30, 2026, at `f3bcd20f8`. The artifacts under
[returning_writes](returning_writes/) are executable research and recorded
results. That research revision changed no production code; the completed
implementation and its validation are recorded below.

**Recommendation:** add ordered execution batches that return one result set
per input statement. Prepare and execute those statements beside SQLite, inside
the existing transaction or savepoint. This removes the per-row asynchronous
driver exchange while retaining database defaults, input order, skipped rows,
and each statement's returned values. SQLite still executes individual writes.
The experiments support this as the general solution for the current behavior;
set-based SQL is a separate optimization with narrower applicability.

### Dialect results

[dialect_probe.py](returning_writes/dialect_probe.py) runs 23 isolated experiments
against system SQLite 3.45.1 and records every bound SQL call, result, and expected
error in [dialect_results.json](returning_writes/dialect_results.json).
[driver_probe.dart](returning_writes/driver_probe.dart) replays those calls with
the repository's resolved SQLite 3.53.4 and checks the same outcomes. Random
16-byte hex values are normalized for replay comparison; their values are not
expected to match across runs. Versions, source IDs, and compile options are in
the result files.

| Alternative | Observed SQLite behavior | Consequence |
| --- | --- | --- |
| Inline `DEFAULT`, `SET v=DEFAULT`, or `default(v)` | Syntax errors on both versions | No hidden equivalent of PostgreSQL's keyword was found. |
| Omit columns in a multi-row `INSERT` | Database defaults apply; random defaults are evaluated per row | Works when all rows share the omitted columns. |
| Inline the schema's default expression | Mixed defaults, supplied values, and explicit NULL work in one statement | A valid SQL option, requiring actual default SQL and input correlation. |
| Read `pragma_table_xinfo.dflt_value` as a value | Stores SQL text, such as the quoted string `'actual'` | Introspection does not evaluate the expression. |
| Evaluate a default through an uncorrelated scalar subquery | A counting function runs once for three rows | Keep the expression in the per-row expression position. |
| `NULL` or `OR REPLACE` as a default convention | Explicit NULL remains NULL for nullable columns; REPLACE only substitutes a default for a NOT NULL violation | These cannot generally preserve the distinction between NULL and DEFAULT. |
| Omit a column on upsert, then use `excluded.v` | Both inserted and conflict-updated rows receive the database default | The update column list must remain independent of the insert column list. |
| `WITH input AS (VALUES ...) UPDATE ... FROM input` | Works for distinct IDs; output order differs from input; repeated IDs update once | ID correlation fixes return ordering only. It does not restore repeated-update semantics. |
| Set-based update with distinct IDs and UNIQUE values | Updating ID 2 from `b` to `c`, then ID 1 from `a` to `b` succeeds sequentially; the combined statement fails | Distinct IDs alone are insufficient to establish equivalent write semantics. |
| Multi-row upsert with repeated conflict keys | SQLite returns two changes to the same row; an `updateWhere` skip returns nothing | Serverpod must retain its duplicate-affected-ID check. |
| Return `input.ord` directly | Rejected for INSERT and UPDATE FROM | Source-only metadata cannot directly accompany generated IDs. |
| Correlated subquery against a materialized input CTE | Returns the correct ordinal when a unique, known target ID is available | Useful for restricted set-based paths, including explicit-ID inserts. |
| Select rows after the batch | An AFTER trigger changes `before` to `after`, whereas RETURNING reports `before` | Readback is not equivalent to collecting RETURNING. |
| Infer generated IDs from a contiguous range | Ignoring a duplicate produces IDs 1 and 3 under AUTOINCREMENT | Neither a range nor `last_insert_rowid()` identifies every successful input. |
| Regroup all inputs by SQL shape | A different input wins a unique conflict | Preserve the entire input sequence, even across alternating shapes. |
| Stage rows in a temporary table with defaults | Stage IDs conflict with existing destination IDs; regenerating destination IDs loses the stage ordinal | Staging alone does not solve generated-ID correlation. |
| Writable CTEs or RETURNING inside a trigger | Rejected | PostgreSQL-style chaining cannot collect the result sets. |
| Combine a child-before-parent self-reference into one INSERT | Combined statement succeeds; the first individual write fails its immediate FK | Combining statements also changes constraint-check boundaries. |

SQLite documents these boundaries in its [INSERT syntax](https://www.sqlite.org/lang_insert.html),
[default evaluation rules](https://www.sqlite.org/lang_createtable.html#the_default_clause),
[UPDATE FROM rules](https://www.sqlite.org/lang_update.html#update_from), and
[RETURNING limitations](https://www.sqlite.org/lang_returning.html#limitations_and_caveats).
The returned row order is explicitly unspecified, including for INSERT. Observing
insertion order in these probes is not a guarantee that an ORM can rely on.

The viable expression substitution looks like this:

```sql
-- Suppose the live schema declares v DEFAULT 'db'.
INSERT INTO t(k, v)
VALUES (?, 'db'), (?, ?), (?, NULL)
RETURNING *;

-- A fixed expression shape can distinguish default from explicit NULL.
INSERT INTO t(k, v)
VALUES (?, CASE WHEN ? THEN 'db' ELSE ? END)
RETURNING *;
```

An implementation must use the actual schema expression, bind application data,
and retain SQLite evaluation of volatile expressions. `Column.hasDefault` is
only a boolean; it does not provide the expression. Loading and invalidating
schema metadata would be additional work. This syntax resolves the varying
column-set issue, but not the independent identity and write-order issues.

For an all-default integer-rowid model, `INSERT INTO t(id) VALUES(NULL),(NULL)`
is viable. A BLOB primary key with a default behaves differently: explicit NULL
fails its NOT NULL constraint. Also, `DEFAULT VALUES ON CONFLICT DO NOTHING` is
invalid. Substituting `INSERT OR IGNORE` is broader: a separate probe shows it
silently skips a CHECK violation which `ON CONFLICT DO NOTHING` rejects.

### Native driver measurements

The driver prototype executes up to 256 ordered statements in one
`SqliteWriteContext.computeWithDatabase` callback. It keeps a prepared statement
per SQL shape within the chunk, binds each input in order, collects each
`select()` result separately, and closes every prepared statement. Alternating
shapes therefore require no additional driver exchanges.

Final measurements use Dart 3.12.2, `sqlite_async` 0.14.5, `sqlite3` 3.5.2,
SQLite 3.53.4, a temporary disk database, WAL, synchronous NORMAL, and driver
statement caching disabled. Each workload has three warmups and seven measured
samples, rotating method order. Database setup is outside timing; transaction
execution and returned rows are inside it. All methods verify 1,000 returned
rows, unique keys, and expected values after timing.

| 1,000 rows returning three columns | Await each statement | Ordered worker batches | Set-based chunks |
| --- | ---: | ---: | ---: |
| Insert | 138.800 ms | 8.286 ms | 3.791 ms |
| Insert with alternating default column omission | 108.786 ms | 5.673 ms | 3.216 ms |
| Update | 105.372 ms | 4.832 ms | 3.398 ms |
| Upsert existing rows | 92.553 ms | 8.667 ms | 4.038 ms |

Raw samples are in [driver_results.json](returning_writes/driver_results.json).
The set-based mixed insert uses the known literal schema default; it does not
measure schema introspection. These simple, narrow fixtures have no triggers or
duplicate inputs. They establish the available execution gain, not general
semantic equivalence. Host load is uncontrolled; an earlier run was faster, so
do not treat these timings as fixed latency guarantees. These are driver-level
measurements, excluding ORM model serialization, normalization, and hydration.

Separate native behavior checks verify mixed shapes, skipped inserts, missing
update targets, repeated update snapshots, values returned before an AFTER
trigger's modifications, savepoint rollback preserving an outer write, and
returned duplicate upsert IDs. They also exercise native 64-bit integer
precision, BLOB parameters and results, and JSONB.

### Mapping to the current implementation

Source inspection confirms that ordinary `update` already has a fixed selected
column set and binds NULL as NULL. Its remaining per-row loop is an execution
issue, not a DEFAULT syntax issue. Returning insert and update recurse once per
row; no-return insert and update call `executeBatch` for consecutive SQL shapes.
Upsert still loops in both modes and uses the shared `InsertQueryBuilder`.

The proposed changes are:

1. Introduce an ordered statement plan carrying SQL, typed bound parameters,
   input position, and return projection (`none`, `id`, or full row). A transport
   can send a dictionary of SQL shapes plus an ordered list of references and
   parameter sets. Never reorder the executions to group matching shapes.
2. Retain `_parameterizedInsert`'s omission of defaulted columns and generated
   IDs. Retain `_parameterizedUpdate`'s selected columns and NULL semantics.
   Add a parameterized SQLite upsert builder using the same insert omission
   rules, an independent conflict/update clause, and `excluded` references.
   Handle zero-column/default-only inserts explicitly. No long-lived schema
   cache is needed; default-only UUID IDs require the actual schema expression.
3. Replace the recursive returning paths with a common batch executor under
   `DatabaseUtil.runInTransactionOrSavepoint`. Bound transfer size by rows and
   payload bytes; keep preparation caches local and bounded. Preserve error
   translation, cancellation checks, query logging, and operation timestamps.
4. Return a result slot for every input, including an empty slot for skipped
   conflicts or missing updates. Normalize returned fields using the existing
   column mapping and encoder, then merge non-persisted fields from that slot's
   input model. Flatten only after this association. Do not zip a shortened
   returned-row list with the original input list.
5. For upsert, collect actual affected IDs across every chunk, including with
   `noReturn`, and perform the existing duplicate-ID rejection before releasing
   the transaction/savepoint. Decode UUID/BLOB IDs for value equality; object
   identity on raw byte buffers is insufficient. Skips do not count.

The research also reproduced a correctness defect, independent of batching:
[builder_probe.dart](returning_writes/builder_probe.dart) exercises the production
`InsertQueryBuilder` with the SQLite encoder and a defaulted nullable field.
It emits `VALUES (1, DEFAULT)` and SQLite rejects it. The equivalent upsert
omitting that field returns its declared default. The exact generated SQL and
error are in [builder_results.json](returning_writes/builder_results.json).
The SQLite adapter now builds its own bound upserts and omits these columns,
so it no longer passes this invalid SQL to SQLite. The generic builder probe
remains a reproduction of the original dialect mismatch.
The ORM treats null on an insert-default column as a request for its
default; the dialect's ability to express explicit NULL does not create a new
model API for distinguishing those intentions.

### Driver work identified by the investigation

The native prototype works through the installed public driver API. However,
`sqlite_async` 0.14.5's web `_UnscopedContext.computeWithDatabase` explicitly
throws `UnimplementedError`. Its web `executeBatch` sends a `RunBatchRequest`
to `AsyncSqliteDatabase.handleCustomRequest`, where the worker prepares one SQL
statement and calls `executeWith` per parameter set, discarding returned rows.
These web findings are source inspection, not browser execution evidence.

The complete platform solution therefore needs a driver operation for ordered
statements with result sets, implemented in both the native worker and the web
request/response protocol. The current web request already supplies lock and
transaction checks and typed parameter encoding; an extension must preserve
those mechanisms and encode typed results. A native-only `computeWithDatabase`
change would leave web performance unresolved. No dependency was modified or
published during this investigation.

Before production adoption, run the real ORM CRUD suites on native and web,
including model defaults, column aliases, non-persisted fields after skipped
inputs, UUID IDs, watches, cancellation, conflict predicates, duplicate targets
across chunks, late constraint failures, and nested savepoints. The probes here
validate the dialect and native executor design; they do not replace that
adapter/driver integration validation.

Set-based paths can be considered subsequently where the API accepts their
statement semantics and output correlation is provable. Use actual keys rather
than returned-row position, respect bind-variable limits, and bound RETURNING
memory. The observed additional speed does not justify silently changing the
general operation's behavior.

### Reproducing the investigation

Run from the repository root with the resolved package configuration and native
assets available:

```sh
python3 docs/design/sqlite_performance/returning_writes/dialect_probe.py \
  > /tmp/sqlite-dialect-results.json

/home/msoares/fvm/versions/3.44.4/bin/cache/dart-sdk/bin/dart \
  --packages=.dart_tool/package_config.json --enable-experiment=native-assets \
  docs/design/sqlite_performance/returning_writes/driver_probe.dart \
  /tmp/sqlite-dialect-results.json > /tmp/sqlite-driver-results.json

/home/msoares/fvm/versions/3.44.4/bin/cache/dart-sdk/bin/dart \
  --packages=.dart_tool/package_config.json --enable-experiment=native-assets \
  docs/design/sqlite_performance/returning_writes/builder_probe.dart \
  > /tmp/sqlite-builder-results.json
```

The Python process deliberately uses the system SQLite library. Preloading the
repository's native library into Python segfaulted on connection creation, so
the resolved build was validated through Dart instead. Both successful routes
report their actual SQLite version. The final Dart probes passed static analysis
and formatting checks.


## Ordered returning batches implemented

The adapter now builds bounded plans of at most 256 statements and approximately
1 MiB of SQL plus bound input values. A single oversized input travels alone.
All chunks execute under the existing transaction or savepoint. Preparation is
reused by SQL text within each chunk, while execution follows the entire input
sequence. This limits input transport and preparation memory; it does not cap
the returned models retained by the public list-returning API.

Each statement has its own result slot, including empty slots for ignored
conflicts, conditional upsert skips, and missing update targets. The adapter
normalizes column names and types, merges each input's non-persisted fields,
and only then collects the successful models. Repeated updates retain their
individual RETURNING snapshots. No positional guarantee from a multi-row
SQLite RETURNING statement is assumed.

Upserts share the validated conflict clause with PostgreSQL, but build bound
SQLite inserts with defaulted columns omitted. The conflict update list remains
independent of that omission, allowing `excluded` to provide database defaults.
Default-only integer IDs use `VALUES(NULL)`; default-only UUID IDs read the actual
ID default expression once per operation and evaluate it in SQLite for each
input. There is no long-lived schema cache. Duplicate affected IDs are checked
across every chunk, including UUID value equality and `noReturn` operations,
before committing. A duplicate rolls back the entire batch.

Native batches use the public `computeWithDatabase` callback. Browser batches
use a Serverpod worker extension built entirely on public `sqlite_async` and
`sqlite3_web` APIs. The extension carries typed parameters and result sets using
the transaction's existing lock token and checks, and retains update
subscriptions. Uniform inserts/updates with `noReturn` retain the driver's
`executeBatch` path; mixed shapes use the ordered executor. Upserts still collect
IDs when required for duplicate detection.

Browser applications must build and serve the matching worker:

```sh
dart run serverpod_database:build_sqlite_web_worker
```

The default output is `web/serverpod_db_worker.js`. Serve it alongside
`sqlite3.wasm` from the resolved `sqlite3` version and rebuild on dependency
upgrades. Its distinct filename isolates the controller from the driver's
ordinary worker cache. The repository's `util/setup_sqlite_web_assets` builds
this worker and provisions both test packages.

### ORM measurements

[orm_benchmark.dart](returning_writes/orm_benchmark.dart) exercises the actual
client ORM, checks every returned row's ID and value in input order, and verifies
stored data outside the timed operation. Each process uses five warmups and
seven measured samples. Runs use Dart 3.12.2, SQLite 3.53.4, temporary disk
storage, default WAL/NORMAL settings, the default disabled statement cache,
and `-Ddart.vm.product=true`. No test suites ran concurrently with measurements;
the host was not otherwise isolated.

The baseline is `f3bcd20f8`. A source-only archive of its database package is
selected through a separate package configuration, preserving all other resolved
dependencies. Each result records the resolved adapter URI to verify which code
ran. Two runs of each final configuration are shown as ranges of per-run medians;
they are not confidence intervals. Full samples, including the intermediate
version before restoring the uniform no-return fast path, are retained in
[orm_results.json](returning_writes/orm_results.json).

| Workload, 1,000 rows | Baseline median (ms) | Final median (ms) | Interpretation |
| --- | ---: | ---: | --- |
| Insert with returned models | 138.315–149.372 | 9.824–9.917 | About 14–15x faster |
| Update with returned models | 123.256–124.753 | 7.124–7.382 | About 17x faster |
| Upsert with returned models | 131.108–135.853 | 7.169–7.213 | About 18–19x faster |
| Insert with `noReturn` | 2.023–2.476 | 2.807–2.838 | Additional bounded planning costs roughly 0.3–0.8 ms |
| Update with `noReturn` | 1.697–1.727 | 2.346–2.545 | Roughly 0.6–0.8 ms additional overhead |
| Upsert with 4 KB text, a 100-element list, and `noReturn` | 213.530–218.244 | 32.287–34.028 | About 6–7x faster |

The no-return insert/update tradeoff is measurable and is not claimed as an
improvement. The driver fast path avoids unnecessary result transport, while
both paths retain the new input-byte bound. These are native measurements;
browser validation establishes behavior, not a browser speedup figure.

Run the harness from the repository root after a native client test has built
its SQLite assets. When overriding `--packages` for a baseline, the direct VM
invocation needs the same native libraries preloaded on Linux:

```sh
assets="$PWD/tests/serverpod_test_sqlite/serverpod_test_sqlite_client/.dart_tool/lib"
LD_PRELOAD="$assets/libsqlite3.so:$assets/libsqlite3_connection_pool.so" \
  dart --packages=.dart_tool/package_config.json -Ddart.vm.product=true \
  docs/design/sqlite_performance/returning_writes/orm_benchmark.dart current
```

### Validation

- Database package: all 871 tests passed.
- SQLite native client: all 603 tests passed, with one existing skipped test.
- SQLite server integration: all 1,445 tests passed, with one existing skip.
- Chrome client CRUD: all 215 tests passed, with one existing skip.
- Flutter web: the app opens and migrates its database, collects a returning
  batch, and verifies persisted rows after restarting.
- PostgreSQL insert, ignored-conflict insert, and upsert: all 43 tests passed.
- Changed Dart production code, tests, and benchmark passed static analysis;
  formatting and whitespace checks passed.

Focused regressions cover interleaved generated/explicit IDs across chunks,
skipped inputs with non-persisted fields, repeated update snapshots, UNIQUE
value release order, AFTER-trigger snapshots, late failures with nested
savepoints, typed worker transport, conditional upsert skips, duplicate targets
across chunks, omitted defaults on conflict updates, generated UUID defaults,
and committed batch watch notifications. The full integration suite also covers
transaction cancellation, column mappings, relations, and existing watch
behavior.

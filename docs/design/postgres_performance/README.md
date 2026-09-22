# PostgreSQL performance work

Baseline: `f3bcd20f8`, including the completed SQLite performance changes.

## Opportunities, ranked by expected value relative to effort

| Rank | Suggestion | Expected benefit | Effort and constraints |
| --- | --- | --- | --- |
| 1 | Materialize insert/upsert SQL fragments once | Avoid repeated serialization, escaping, and construction of large SQL strings; roughly halve builder work for uniform ID batches | Very low; preserve identical SQL, mixed IDs, defaults, conflicts, and returning behavior |
| 2 | Normalize PostgreSQL result rows once, directly from the result schema | Eliminate intermediate maps and repeated mapping during include traversal; improve large reads and returning writes | Low; preserve aliases, nulls, undecoded bytes, and duplicate-column behavior |
| 3 | Skip query logging work when the session has no logger | Avoid an unused stack trace and duration calculation on every query | Very low; benefit applies when `logQuery` is null (`Session(enableLogging: false)`), not merely when log settings discard query logs; retain enabled logging and exception behavior |
| 4 | Fetch schema metadata in batches | Reduce schema inspection from `1 + 3 × tables` queries to a small fixed number; improve startup/migration checks on larger schemas | Medium; preserve schema isolation, column permissions, extension exclusions, types, constraints, and indexes; bind catalog filters |
| 5 | Hoist bulk-update column type conversion out of the row loop | Reduce repeated Dart type checks for wide bulk updates | Low; probably small compared with PostgreSQL execution; retain only if measurement supports it |
| 6 | Parameterize ORM SQL and consider prepared statements | Reduce large literal SQL and repeated parsing for stable query shapes | High; defer this separate design because parameter limits, type encoders, query logging, pool ownership, and cache memory require broader changes |
| 7 | Remove per-row fallback for non-persisted fields | Potentially remove many round trips on conflict-handling writes | Defer: batching upserts can change duplicate-target behavior, and returned rows still need reliable association with their source objects |

The shared linear relation grouping and SQL-side no-return update/delete
selection are already present in the baseline and are not new PostgreSQL gains.
No connection-count, durability, isolation, SSL, or statement-cache defaults will
be changed by this work.

## Measurement and validation plan

Use the actual adapter and generated server models against a fresh local
embedded PostgreSQL database. Time warmed operations with fixture setup outside
the measured interval, retain individual samples, and check resulting values.
Measure each change against its immediate predecessor; report CPU-only SQL
construction separately from database round trips. Small overlapping timing
differences are inconclusive. Do not add gains across workloads.

Run the existing database and PostgreSQL integration suites, adding regressions
only for uncovered behavior affected by these changes. After implementation,
use an Opus xhigh adversarial reviewer through Orca orchestration and resolve
significant findings before completion.

## Incremental results

Times are medians in milliseconds for the whole workload. Raw samples are in
[measurements.json](measurements.json); the reproducible harness is
[benchmark.dart](benchmark.dart).

| Change | Workload | Before | After | Result |
| --- | --- | ---: | ---: | --- |
| Build insert fragments once | Build SQL for 1,000 rows with 4 KiB text | 97.330 | 54.007 | 1.80x faster CPU construction |
| Build insert fragments once | Same batch with mixed explicit/generated IDs | 124.427 | 53.501 | 2.33x faster CPU construction |
| Build insert fragments once | Insert 1,000 wide rows, no return | 179.028 | 136.752 | 23.6% lower elapsed time |
| Direct result maps | Find 10,000 rows | 49.603 | 46.722 | Small, overlapping samples |
| Direct result maps | Read 10,000 parents with a city and children | 317.936 | 295.041 | 7.2% lower median, overlapping samples |
| Direct result maps | Update 10,000 rows with returning | 142.711 | 142.438 | No clear timing gain |
| Skip unused logging | 1,000 individual reads without a logger | 454.959 | 441.061 | Small, overlapping samples |
| Skip unused logging | Same reads with a logger (control) | 424.673 | 414.943 | Similar variation; no precise speedup claim |
| Batch catalog metadata | Inspect 104 tables, 100 secondary indexes and 103 foreign keys | 532.453 | 26.208 | 20.32x faster; 313 queries become 4 |

Benchmark invocation from the repository root (choose one workload):

```sh
dart --packages=.dart_tool/package_config.json -Ddart.vm.product=true \
  docs/design/postgres_performance/benchmark.dart builder
# Other workloads: rows, logging, catalog, updates
```

The harness creates and removes its own embedded PostgreSQL cluster. Database
measurements retain default durability settings. No tests run concurrently with
the timings. The large insert includes apostrophes and backslashes and checks
that stored text round-trips unchanged.

Result mapping now allocates one map instead of two per normalization and reuses
maps during include traversal. An initial eager variant retained maps even for
single-pass reads and measured 66.157 ms for the plain 10,000-row read; it was
replaced with lazy mapping for single-pass consumers. Small timing changes are
not evidence of a reliable end-to-end speedup, although the redundant map
allocation and repeated include normalization are removed.

The logging guard avoids an unused stack trace and duration computation only
when `DatabaseSession.logQuery` is null. Server sessions reach this path when
created with `enableLogging: false`, as for the internal session. Ordinary
endpoint sessions still have a logger when settings disable query logging, so
they do not benefit from this guard. The enabled-logger control varies by a
similar amount, so the measurements do not establish a reliable percentage gain.
The benchmark verifies all 16,000 enabled callbacks (warmups plus samples).

Catalog analysis binds selected table OIDs and groups each metadata result by
OID. Column queries still use `information_schema.columns`, preserving column
visibility under restricted roles. Per-table methods share the same parsers and
bind schema/table names, which also fixes the previous interpolation failure for
names containing apostrophes. Extension-owned tables remain excluded. Queries
retain the existing PostgreSQL version assumptions and do not cache metadata.

Eight focused real-PostgreSQL regressions cover schema isolation, physical column
order after a drop, defaults, foreign-key actions/deferral, expression and
null-not-distinct indexes, direct/full analysis equivalence, quoted names,
restricted column visibility, and PostGIS table exclusion/types.

## Scope of the analysis

Inspected the PostgreSQL pool, connection/transaction path, SQL builder, value
encoding, result normalization, schema analyzer, and migration runner, plus the
resolved `postgres` 3.5.16 execution path. Bulk inserts and updates already use
set-based statements. The driver sends parse/bind/execute in one exchange for
ordinary extended queries, so there is no separate prepare round trip to remove
there. Stable bound ORM statements and connection-owned prepared caches remain
a separate design opportunity; changes must account for typed values, parameter
limits, transaction poolers, logging, and retained SQL memory.

## Validation

Completed locally:

- 116 existing SQL-builder tests.
- 276 PostgreSQL CRUD, explicit-column-name, and list-include tests; one existing skip.
- 13 existing session-logging tests.
- Full database package: 879 tests, including all eight new catalog regressions.
- Full PostgreSQL database/column suites: 1,415 tests; one existing skip.
- SQLite client: 590 tests; one existing skip.
- CLI database/migration generation: 767 tests.
- Static analysis and formatting for the changed Dart code.
- A later shared-setup catalog assertion also passed when selected alone.
- `dart run melos run test_integration_database`: all 10 tagged adapter tests.
- CI workflow diagnostics match the baseline (details below).

An initial broad run could not initialize a reused embedded data path
because of a stale process marker; it was cancelled and restarted with a fresh
path. That startup failure is not counted as executed test coverage.

## Rejected experiment

Hoisting bulk-update column type conversion was tried in an isolated package
copy. Fresh-process runs in baseline/candidate/baseline order measured the
following medians (ms) for 10,000-row no-return updates:

| Model | Baseline | Candidate | Repeated baseline |
| --- | ---: | ---: | ---: |
| Two-column rows | 88.350 | 76.446 | 75.166 |
| Three-column organizations | 106.714 | 106.432 | 92.199 |

The unchanged baseline reproduced or beat the candidate, so the apparent gain
was not attributable to type hoisting. The candidate was **not retained**.
The `updates` workload and all samples remain available for future profiling.

## Adversarial review

Opus xhigh reviewed `f3bcd20f8..735e43ace` through Orca orchestration, run
`run_62bf30db6872`, task `task_3d165673c1d3`, dispatch `ctx_d44d63bb6bd0`.
The launch receipt confirmed the effective model and effort. The accepted
review reported **no significant findings** in the four production changes.
The reviewer terminal was released after settlement.

The reviewer independently compared old and new catalog output for 46 tables
covering pgvector, PostGIS, GIN, partial/expression/INCLUDE/null-not-distinct
indexes, composite/cross-schema foreign keys, same-named tables, partitions,
inheritance, views, dropped columns and restricted column grants. Output
matched; 139 queries became four. Transaction-local temporary tables also
matched (47 tables, 142 queries to four), as did direct versus bulk inspection.
A 1,501-table check measured 10.3–10.6 seconds before versus 0.24–0.52 seconds
after. Table-list ordering differed, but was already unspecified and consumers
look up definitions by name. Maximum unsigned OID binding also round-tripped.
These independent scale timings are supporting evidence, separate from the
main warmed benchmark samples.

Two low-severity review notes were addressed: clarify that the logging guard
requires a null logger, and route the integration-tagged database tests through
the existing embedded-PostgreSQL CI job and the local Melos integration command.
The CI route covers Windows through its existing non-admin test runner and the
other matrix platforms through an added database-package step. Hosted CI has
not run as part of this local task. Workflow lint reports the same two existing
`matrix.suite.timeout_minutes` diagnostics as the baseline; filtering only
those diagnostics yields no additional errors.

The reviewer also reproduced an **existing, out-of-range bug**: a mixed
explicit/generated-ID batch insert can attach non-persisted fields to the wrong
returned rows because merging follows input indexes while SQL returns generated
IDs first. The unchanged SQL has this behavior at the baseline as well. This is
recorded for a separate correctness fix, alongside deferred opportunity 7; it
is not claimed as fixed by these performance changes.

## Commits

| Commit | Change |
| --- | --- |
| `00c2bfd10` | Ranked opportunities and expected outcomes |
| `ca92036e1` | Build insert/upsert SQL fragments once |
| `67e976755` | Avoid redundant result maps |
| `76697b578` | Skip logging work when no logger is attached |
| `735e43ace` | Batch catalog inspection and pin missing behavior |
| `2b683b487` | Run tagged database adapter tests in CI and Melos |

Each performance commit includes its measurements. The subsequent test-routing
commit addresses review note L1; the final documentation records review note
L2, complete validation, and the rejected type-hoisting experiment. All changes
are local commits; no push or hosted CI run was performed.

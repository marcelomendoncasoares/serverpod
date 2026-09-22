# PostgreSQL performance work

Baseline: `f3bcd20f8`, including the completed SQLite performance changes.

## Opportunities, ranked by expected value relative to effort

| Rank | Suggestion | Expected benefit | Effort and constraints |
| --- | --- | --- | --- |
| 1 | Materialize insert/upsert SQL fragments once | Avoid repeated serialization, escaping, and construction of large SQL strings; roughly halve builder work for uniform ID batches | Very low; preserve identical SQL, mixed IDs, defaults, conflicts, and returning behavior |
| 2 | Normalize PostgreSQL result rows once, directly from the result schema | Eliminate intermediate maps and repeated mapping during include traversal; improve large reads and returning writes | Low; preserve aliases, nulls, undecoded bytes, and duplicate-column behavior |
| 3 | Skip query logging work when the session has no logger | Avoid an unused stack trace and duration calculation on every query | Very low; benefit applies to sessions without query logging; retain full enabled logging and exception behavior |
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

Benchmark invocation from the repository root (choose one workload):

```sh
dart --packages=.dart_tool/package_config.json -Ddart.vm.product=true \
  docs/design/postgres_performance/benchmark.dart builder
# Other workloads: rows, logging, catalog
```

The harness creates and removes its own embedded PostgreSQL cluster. Database
measurements retain default durability settings. No tests run concurrently with
the timings. The large insert includes apostrophes and backslashes and checks
that stored text round-trips unchanged.

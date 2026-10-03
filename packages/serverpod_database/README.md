![Serverpod banner](https://github.com/serverpod/serverpod/raw/main/misc/images/github-header.webp)

> ⚠️ This is an internal package that is part of the Serverpod framework and is not intended to be used directly by end-users. Be aware that this package is subject to breaking changes without prior notice.

# Serverpod
This package is a core part of Serverpod. For documentation, visit: [https://docs.serverpod.dev](https://docs.serverpod.dev).

## What is Serverpod?
Serverpod is an open-source, scalable app server, written in Dart for the Flutter community. Check it out!

[Serverpod.dev](https://serverpod.dev)

## SQLite browser worker

Client-side SQLite uses a Serverpod worker that extends `sqlite_async` with
ordered batches and per-input returning results. Build it with the application's
resolved dependencies:

```sh
dart run serverpod_database:build_sqlite_web_worker
```

Serve `web/serverpod_db_worker.js` alongside `sqlite3.wasm` from the resolved
`sqlite3` release. The distinct worker name keeps Serverpod's controller separate
from ordinary `sqlite_async` databases in the same application.
Rebuild the worker when upgrading Serverpod or its SQLite dependencies. The
standard `sqlite_async` worker does not implement Serverpod's batch protocol.
The worker retains the driver's database locks, typed values, storage selection,
and update notifications. Repository browser tests provision these assets with
`util/setup_sqlite_web_assets`.

### Describe the bug

If a change is made to a model both using the `column` keyword to rename a column and adding another field with the same `column` name as the renamed column, the migration system will not treat the new field as an added column.

---

### To reproduce

1. Define a **source** table with one extra column, e.g. SQL name `old_name`, with a stable model field id (`fieldName` / `effectiveFieldName`), e.g. `renamedField`.
2. Define a **target** table where:
   - the same field `renamedField` now uses SQL name `new_name` (compatible rename), and
   - a **second** field (e.g. `newField`) uses SQL name `old_name` (reuse the freed name).
3. Run `generateDatabaseMigration(databaseSource: …, databaseTarget: …)` and inspect `alterTable.addColumns` and generated SQL.

**Observed:** `modifyColumns` contains the rename; `addColumns` does **not** include the new `old_name` column. Generated SQL may contain `RENAME COLUMN` but not `ADD COLUMN "old_name" …`.

**Minimal repro** (conceptually): same as the test case "renamed column + new field reusing the old SQL name" in `tools/serverpod_cli/test/database/migration/column_rename_test.dart`.

---

### Expected behavior

The migration should include:

- A rename for the existing field (`old_name` → `new_name`).
- An **add** for the new field using `old_name` (after the rename, so the name is free—SQLite/PostgreSQL generators already order rename before add where applicable).

`addColumns` should list the new column definition, and generated SQL should contain the corresponding `ADD COLUMN` (for dialects that apply changes incrementally).

---

### Library version

*(Replace with what you use; example placeholder.)*

Serverpod: *e.g. 2.x.y*
Dart: *e.g. 3.x.y*

Bug is in **`serverpod_cli` migration generation** (table diff / `generateTableMigration`), not in a specific app runtime package version alone.

---

### Platform information

- **OS:** any (generation is local / CI).
- **Where it shows up:** `dart run serverpod generate` / migration generation; applies to **PostgreSQL and SQLite** migration SQL derived from the same `TableMigration`.

---

### Additional context

- **Root cause:** “Added column” detection used **SQL column name** only (`containsColumnNamed` on the source), instead of also considering **model field identity** (`ColumnDefinition.effectiveFieldName`) and whether the row is already covered by `renameColumns`.
- **Related behavior:** If the same field is renamed but **cannot** be migrated with `canMigrateTo` (e.g. incompatible type), the code path is “drop + add”; that must remain distinct from a tracked rename in `renameColumns`.
- A fix should adjust the `addColumns` loop in `tools/serverpod_cli/lib/src/database/migration.dart` and add regression tests (migration diff + SQLite/PostgreSQL SQL ordering).

---


**Suggested issue title:** `Migration omits ADD COLUMN when a new field reuses the old SQL name after a rename`

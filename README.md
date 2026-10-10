# Expense Tracker

Offline-first, multi-device personal finance app for Android and iOS, built with Flutter, Drift
(SQLite) and Supabase.

## Requirements

- Flutter 3.41+ (Dart 3.11+)
- Xcode (iOS 13+) and/or Android Studio (Android API 24+)
- A Supabase project

## Setup

```bash
flutter pub get
cp env.example.json env.json        # then fill in your Supabase values (never commit env.json)
```

`env.json` keys:

| Key | Value |
|---|---|
| `SUPABASE_URL` | Project URL, e.g. `https://abcd.supabase.co` |
| `SUPABASE_ANON_KEY` | The project's **publishable** key (`sb_publishable_...`) or legacy anon key |

### Database (Supabase)

Apply the SQL migrations in `supabase/migrations/` in order: paste each into the Supabase SQL
editor, or run `supabase db push` with the Supabase CLI. Then run `supabase/tests/rls_check.sql`
in the SQL editor. It should end with `RLS check passed`.

## Run

```bash
flutter run --dart-define-from-file=env.json
```

## Development

```bash
dart run build_runner build --delete-conflicting-outputs   # Drift, Riverpod, freezed codegen
flutter gen-l10n                                            # strings from lib/core/l10n/*.arb
dart format --line-length 100 lib test
flutter analyze
flutter test
```

Generated files (`*.g.dart`, `*.freezed.dart`, `lib/core/l10n/generated/`) are committed.

Local schema changes: bump `schemaVersion` in `lib/core/db/app_database.dart`, add a migration
step, then run `dart run drift_dev make-migrations` and extend
`test/core/db/migrations/migration_test.dart`.

## Docs

- `docs/ARCHITECTURE.md`: layers, folder structure, sync, error handling
- `docs/CONVENTIONS.md`: coding standards, core components, Definition of Done
- `docs/PROJECT_PLAN.md`: scope, decisions, data model
- `docs/Progress/TASKS.md`: task list and progress

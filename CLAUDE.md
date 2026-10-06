# Desk Buddy

Flutter desktop reminder companion: an always-on-top animated buddy (overlay
window) plus a dashboard window. Spec: `docs/spec.md`. Behavioral reference:
`docs/prototype.html` (spec wins on conflict). Plan: `docs/plan.md`.
Decisions: `docs/decisions.md`. Status: `docs/progress.md`.

## Development & review rules (owner's, apply to every change)

- **Never commit or push directly to `main`.** Every feature, fix,
  refactor or change gets its own branch with a clear, descriptive name
  (`feature/…`, `fix/…`, `refactor/…`, `chore/…`), and reaches `main` only
  through a reviewed merge / pull request.
- Every branch carries a clear description: **what** changed, **why**, and
  **how it was tested**. It's used as the PR description; the commit message
  gives the short form.
- Never commit or push without testing **and** reviewing the change (run the
  `desk-buddy-review` skill). Push only when asked. Fix all review issues
  before merging.
- Follow the existing architecture, patterns and conventions; reuse existing
  code instead of duplicating code, files or logic.
- No unused code, files, imports, variables or dependencies; no
  over-engineering: implement only what is required.
- Clear, consistent, meaningful names; simple, readable code any developer
  can follow.
- Before committing, verify all of these:
  - `flutter analyze` is clean.
  - `flutter test` passes.
  - `flutter build windows --debug` succeeds.
  - No regressions, duplicates or leftovers.
- Review for correctness, readability, maintainability, performance,
  security and consistency. Fix findings before committing.

## Hard rules (enforced by `test/guards/project_rules_test.dart`)

- **Nothing is hardcoded to a specific reminder.** Behavior comes from data
  (schedule, message template, goal/unit, prop, category). No code branches on
  a reminder title, category name, emoji or prop name. The words
  water/drink/glass/sip may appear only in `assets/seed/` and `test/`. A
  reviewed exception (e.g. eyewear copy) carries `// guard-ok: <reason>`.
- **Never call `DateTime.now()`** outside `lib/core/clock/`. Use `clock.now()`.
- **Pure-Dart engines** (`features/scheduler/engine/`,
  `features/buddy/movement/` — walker and poses, `shared/template/`) must not
  import Flutter or `dart:ui`.
- Wall-clock math goes through local `DateTime(y, m, d, h, min)` — never add
  fixed milliseconds for days (DST).
- User-facing strings live in `lib/shared/strings.dart`.

## Layout

Feature-first: `lib/app`, `lib/core/{clock,db,window,tray}`,
`lib/features/{scheduler,buddy,reminders,dashboard,analytics,character,settings,categories}`,
`lib/shared`. Seed data in `assets/seed/`.

Windows overlay native code: `windows/runner/overlay_channel.{h,cpp}` — the
`desk_buddy/overlay` channel, all coordinates in **physical** pixels. The main
runner window is the overlay (WS_POPUP, topmost, tool window, no-activate).

## Buddy rendering

`features/buddy/render/buddy_painter.dart` ports the prototype's `charSVG`
1:1 (same 120×222 space, same path strings via `svgPath`). Props: add an entry
to `propRegistry` in `render/props.dart` — nothing else. Goldens in
`test/features/buddy/goldens/` (rendered on Windows; regenerate with
`flutter test --update-goldens test/features/buddy/buddy_golden_test.dart`).

## Data

`lib/core/db/`: drift tables (`tables.dart`; row classes end in `Row`),
`AppDatabase`, `openAppData()` (open → default rows → first-launch seed →
90-day log prune). Features use repositories (`features/*/data/`), which map
rows to the freezed domain models and announce writes on `DataChanges`.
Riverpod access: `lib/core/db/providers.dart` (`appDataProvider` is
overridden in `main()`). Seed data: `assets/seed/*.json`.

Schema change (done once already, v1 → v2, D25): edit `tables.dart`, bump
`schemaVersion`, run `dart run build_runner build` and
`dart run drift_dev make-migrations`, write the `fromNToM` step in
`AppDatabase.migration` (`app_database.steps.dart` is generated), and extend
`test/drift/app/migration_test.dart` (schema + data integrity). Backups
(`features/settings/data/backup.dart`) must keep importing older files.

## Scheduler

`features/scheduler/engine/` is pure Dart: `computeNext`/`fitWindow`
(`schedule.dart`), `WallClock` (all calendar math — never add 24 h),
`goals.dart`, and `SchedulerCore` (events → effects). `SchedulerService` runs
it in the overlay. Only the scheduler calls `ReminderRepository.setSchedule`;
user changes go through `ReminderCommands` (bumps `updatedAt`, recomputes
`nextDueAt`). DST tests use `test/helpers/tz_wall_clock.dart`.

Upserts must use `toCompanion(false)` so nulls are written (D18).

## Character renderers

Use `BuddyCharacter` (Rive if `assets/rive/buddy.riv` loads, else the
painter `BuddyView`). The Rive contract is `docs/rive-contract.md`. Adding a
prop also means adding it to the Rive `prop` enum.

## Windows and the dashboard

`main.dart` runs in both engines and branches on `WindowRole`. The overlay
runs the buddy, scheduler, tray (`core/tray/`) and `WindowBus`; the dashboard
(`app/dashboard_app.dart`, screens under `features/*/ui/`) runs the bus plus
Riverpod (`app/providers.dart`; every list is a drift `.watch()`). Cross-
window sync = `dataChanged` → `markTablesUpdated` (D19); never add per-screen
refresh code. Settings changes must use `settings.update((current) => …)`,
never a widget's snapshot (D22). Component text styles must set
`fontFamily: bodyFont` (D23).

Widget tests: `test/helpers/dashboard_harness.dart` (in-memory DB, fixed
clock, recording bus); every page is render-tested at 1280 and 640 px.

## Commands

```sh
flutter analyze
flutter test
dart run build_runner build -d      # freezed / json codegen
flutter run -d windows --dart-define=SPIKE=A --dart-define=DEMO_FIRE_IN=20
powershell -ExecutionPolicy Bypass -File tool\spike_bench.ps1   # Phase 1 spike
```

## Packaging

`docs/release-windows.md` (Inno Setup `installer/windows/desk_buddy.iss`,
MSIX via `msix_config`), `docs/release-macos.md`. Icons:
`python tool/make_app_icons.py`, `python tool/make_tray_icons.py`.
Never change after a release: `AppId` in the .iss, the bundle id, the MSIX
identity, CompanyName/ProductName in `Runner.rc` (they decide the data
folder). macOS native code is unverified until `docs/macos-verification.md`
is done.

## Workflow

Work phase by phase (`docs/plan.md`). After each phase: analyze clean, tests
green, update `docs/progress.md`, then stop for review.

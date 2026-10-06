---
name: desk-buddy-review
description: Code reviewer for the Desk Buddy Flutter app. Use when reviewing a diff, a PR, a file or the whole codebase of this project, or before committing/pushing. Checks the project's hard rules (no reminder-specific code, clock, pure engines, strings), its known bug classes (drift null upserts, stale settings snapshots, scheduler single-writer, font families, cross-window sync) and runs the gates (analyze, tests, guard tests).
---

# Desk Buddy code review

You are reviewing code in the Desk Buddy repo (Flutter desktop: an
always-on-top overlay buddy + a dashboard window sharing one SQLite file).
Read `CLAUDE.md` first; `docs/decisions.md` explains *why* things are the
way they are (cite decision numbers like D18 in findings).

Report **verified** problems only: for each, open the code, trace the real
inputs, and be able to state a concrete failure (inputs/state → wrong
result). Rank most severe first. Style nits only if they break a rule below.

## 1. Gates (run them, report output faithfully)

```sh
flutter analyze                 # must be "No issues found!"
flutter test                    # all green; note the count
dart run build_runner build     # generated code must be up to date
flutter build windows --debug   # native code must compile (Windows)
git status --short              # generated files changed after build? → stale
```

Never commit or push until all gates pass and the review's findings are
fixed (owner's rule, see CLAUDE.md).

## 1b. Owner's quality rules (check every change)

- **Reuse, don't duplicate:** an existing helper, widget, repository method
  or string should be used, never a near-copy of it.
- **Nothing unused:** check new and touched code for unused imports, fields,
  methods, native channel methods, strings, assets and dependencies. The
  analyzer only catches unused *private* members, so grep for public ones.
- **No over-engineering:** only what the request needs; no speculative
  options, layers or parameters.
- **Naming and readability:** clear, consistent names that match the
  surrounding code; simple code a new developer can follow.
- **Also review:** performance (rebuilds, timers, per-frame work) and
  security (no secrets, safe file handling on import/export).

## 2. Hard rules (each is a bug if broken)

| Rule | How to check |
|---|---|
| **No reminder-specific logic.** Nothing branches on a reminder title, category name, emoji or prop name; behavior comes from data. | Grep `lib/` for literal titles/categories ("Health", "Drink", …) and `== '` comparisons on `title`, `name`, `emoji`, `propId`. `test/guards/project_rules_test.dart` covers water/drink/glass/sip; exceptions need `// guard-ok: <reason>`. |
| **No `DateTime.now()`** outside `lib/core/clock/`. | Guard test + grep. Wall-clock math via `WallClock` / `clock`. |
| **Pure engines** (`features/scheduler/engine/`, `features/buddy/movement/`, `shared/template/`) import no Flutter / `dart:ui`. | Guard test. |
| **No fixed-ms day math.** Never `+ 86400000` / `Duration(days:)` for calendar days. | Grep `86400000`, `millisecondsPerDay`, `Duration(days`. Must use `WallClock.startOfDayOffset` / `fromWall` (D15). |
| **User-facing strings** live in `lib/shared/strings.dart`. | Look for string literals inside `Text(...)`, `labelText:`, `tooltip:`, toasts in `lib/**/ui/`. |

## 3. Known bug classes in this codebase

1. **Drift upserts must write nulls** — `insertOnConflictUpdate(row)` with a
   data class skips null fields on update. Every upsert uses
   `.toCompanion(false)` (D18).
2. **Writes from a snapshot** — UI must apply changes to *current* data:
   `settings.update((current) => …)`, `settings.updateLook((current) => …)`,
   `categories.updateWith(id, (current) => …)`; the reminder editor re-reads
   on/off before saving (D22, D34). Never save a `copyWith` of a widget's
   build-time copy, and never generate ids (`newId`, `blank()`) in `build`.
3. **Scheduler is the single writer of `nextDueAt`** via `setSchedule`; user
   changes go through `ReminderCommands` (bumps `updatedAt`, recomputes from
   now) (D14). A direct `reminders.save` that changes scheduling fields
   without recomputing is a bug.
4. **Cross-window sync** — every write must go through a repository (they
   notify `DataChanges`); writing the db directly skips the bus (D19).
   Writes that the other window doesn't need (buddy position) are the only
   intentional exception.
5. **Component text styles** (ButtonStyle.textStyle, chip labelStyle, …) must
   set `fontFamily: bodyFont` (D23).
6. **Progress semantics** — `semanticsValue` must be numeric (D21).
7. **Async UI** — after every `await` in a widget, check `mounted` /
   `context.mounted` before using `context` or `setState`.
8. **Timers, tickers, subscriptions** are cancelled in `dispose`; widget
   tests don't leave pending timers.
9. **Native channels** (`windows/runner/overlay_channel.cpp`,
   `macos/Runner/MainFlutterWindow.swift`, `lib/spike/overlay_native.dart`)
   must agree on method names, argument keys and types. Coordinates are
   physical px (Windows) / flipped points (macOS) — never mix with logical.
10. **Overlay must not steal focus** — no `SetForegroundWindow`/activation
    outside `focusForAlert` (D2, D24).
11. **Things that must never change after a release** — Inno `AppId`, bundle
    id, MSIX identity, `Runner.rc` CompanyName/ProductName (data folder) (D31).

12. **Scheduler effects** are isolated (one failure must not stop the
    queue); responses carry `firedAt`; nothing dispatches after `dispose`
    (D34).
13. **Not a bug:** read-then-write in `db.transaction` across the two
    windows — drift's native executor uses `BEGIN IMMEDIATE` (D34).

## 4. Tests

- New logic in `engine/`, repositories, analytics or backup needs unit tests;
  new screens/states need a render test (`test/helpers/dashboard_harness.dart`
  renders every page at 1280 and 640 px).
- DST-sensitive code is tested with `test/helpers/tz_wall_clock.dart`
  (America/New_York, Australia/Sydney), not the machine's zone.
- Schema changes: new `drift_schemas/` dump + step + data-integrity test (D25).

## 5. Output

A short table: severity (bug / risk / nit), file:line, what breaks, fix.
Then the gate results. Say plainly if everything passes.

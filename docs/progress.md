# Progress

## Blockers (owner action needed)

1. **Visual Studio C++ workload missing.** No Windows build is possible, so the
   Phase 1 measurements and every on-screen check wait on it. Fix (admin
   PowerShell):
   `& "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\setup.exe" modify --installPath "C:\Program Files\Microsoft Visual Studio\18\Community" --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended --passive`
2. **Flutter 3.44.8 is behind the current stable (3.47.6).** The spec targets
   latest stable, and we're on a freezed prerelease because of it (D5). Run
   `flutter upgrade` when convenient.

## Phase 0 — Setup (partial, done as a prerequisite of Phase 1)

- [x] Project `desk_buddy` (windows, macos), org `com.deskbuddy`
- [x] very_good_analysis (strict casts/inference/raw types), analyze clean
- [x] Guard tests: no reminder-specific words, no `DateTime.now()`, pure engines
- [x] `CLAUDE.md`, `docs/spec.md`, `docs/prototype.html`, `docs/plan.md`, git init (no commits yet)
- [x] Fonts: Baloo 2 (500/700/800) and Figtree (400–700) bundled, with OFL texts
- [x] Riverpod 3 + generator, drift 2.35 (sqlite3 3.x hooks, D10), uuid
- [ ] Chime (Phase 4); window/tray/notification packages (Phases 4–5)

## Phase 1 — Overlay spike (code done, measurements blocked)

- [x] Native overlay channel (Windows runner) + overlay window style (D2)
- [x] Strategies A / B / C: walk, idle, edge bounce, drag, tap → bubble, display switching
- [x] `Walker` (pure Dart, tested)
- [x] Benchmark harness (`tool/spike_bench.ps1`)
- [ ] Run the benchmark; check transparency, click-through, focus and multi-monitor; decide (D4)
- [ ] macOS overlay code path + click-through check on a Mac (owner)

## Phase 2 — Buddy rendering & movement (code done, on-screen check blocked)

- [x] `BuddyLook` (freezed + JSON) and the four look presets
- [x] `BuddyPainter`: every prototype part in z-order, same path data (`svgPath`), derived shades (`shade()`)
- [x] Prop registry (none, bottle, coffee, book, phone, dumbbell, pill); `default` → look's usual item
- [x] Poses: walking / idle / alert / dragging, blink in all states, reduce-motion (static; alert keeps the arm raised)
- [x] `BuddyView`: per-vsync only while walking/alerting, 15 fps idle, nothing with reduce motion (D7); flip; semantics label
- [x] Bubble: comic stroke text, goal pill, focusable buttons (Enter/Space), springy pop-in; peek variant
- [x] Position persistence (`BuddyPositionStore`, JSON file for now, Settings row in Phase 3); restore ignores monitors that are gone
- [x] Wired into the spike host: real buddy, taps alternate peek / demo alert (exercises click-through on bubble buttons), Enter/Space peek, position saved on drag end + every 15 s
- [x] Tests: 48 passing (unit, widget, goldens for looks × poses, props, bubbles)
- [ ] See it on screen (blocked by the VS workload)

### Hand-check list once it builds (`flutter run -d windows --dart-define=SPIKE=A`, then B, C)

- Background fully transparent, no black box, no flicker on start
- Typing in another app while the buddy walks: focus is never stolen
- Click on empty desktop near the buddy (B/C): reaches the window underneath
- Tap buddy → peek; tap again → demo alert; both bubble buttons clickable
- Drag across monitors (and between 100% / 150% scaling): size and position stay right
- Move or auto-hide the taskbar: the buddy stays above it
- Quit and relaunch: the buddy comes back where it was

## Phase 3 — Data layer (done)

- [x] Domain models (freezed + JSON): `Category`, `Reminder`, `LogEntry`, `AppSettings` (with `normalized()`), `Starter`; `BuddyLook` from Phase 2
- [x] Drift schema v1: categories, reminders (FK, `CHECK every ≥ 1`, `goal ≥ 0`), log_entries (indexed, no FK by design), single-row settings and buddy_looks
- [x] File opener: WAL, busy_timeout, foreign keys (D10)
- [x] Repositories + `DataChanges` topics. Category delete moves reminders and refuses to delete the last one; scheduler and position writes are column-scoped (D12)
- [x] Seed JSON copied 1:1 from the prototype (4 categories, 7 starters); first launch inserts the first 3; categories resolved or created by name; idempotent
- [x] Startup `prepare()`: default rows → seed → prune logs older than 90 days (local midnight, DST-safe)
- [x] Buddy position now lives in the settings row (`SettingsBuddyPositionStore`); the spike reads look and position from the DB
- [x] Riverpod providers for the clock, AppData and repositories
- [x] Migrations: `drift_schemas/app/drift_schema_v1.json` + schema verification test (`test/drift/`)
- [x] Tests: 83 passing (35 new: repositories, constraints, seeding, retention, two-connection WAL file, schema)
- [ ] Debug-only sample history generator: moved to Phase 5 with the dev menu (the `sample` column and removal are ready)

## Phase 4 — Scheduler (logic done; on-screen check blocked)

- [x] `WallClock` with a DST policy (D15); `computeNext` / `fitWindow` hardened (overnight windows, inclusive ends, invalid input → null)
- [x] `fillTemplate` (unknown tokens kept), `countToday` (manual included), `streak` (from yesterday until today is met), goal ring
- [x] `SchedulerCore` reducer: one pop-up at a time, earliest first, queueing, done/snooze/auto-miss, one-off disable, DND, sleep catch-up (fires once, no backlog), test fire, snooze all, stale-reload protection (D14, D16)
- [x] `SchedulerService`: 1 s tick, drift streams in, ordered effects, filled alert view (message, goal pill, labels), chime, notification fallback when the buddy is hidden
- [x] `ReminderCommands`: validate (the three editor messages), save/enable recompute from now, delete, manual +1
- [x] Overlay host: real alerts (bubble buttons answer, buddy holds the reminder's prop), peek shows the next reminder with a countdown; size, speed, walking, visibility and look follow settings live; native `setVisible`
- [x] Chime asset (generated, D17); `audioplayers` + `local_notifier` wired in `main`
- [x] Debug aid `--dart-define=DEMO_FIRE_IN=20`
- [x] Bug fixed: upserts didn't clear nullable columns (D18)
- [x] Tests: 169 passing (86 new: schedule incl. New York/Sydney DST, template, goals, core scenarios, service end-to-end, commands, countdown)

### Hand-check once it builds

- `flutter run -d windows --dart-define=SPIKE=A --dart-define=DEMO_FIRE_IN=20`: after ~20 s the buddy hops and waves holding a bottle, the bubble says "Hey, there! Did you drink water?" with "0 / 8 glasses today", and a chime plays
- "Yes!" closes it; tap the buddy → peek shows the next reminder and its countdown
- Leave a pop-up for 5 min → it closes (logged as missed)
- With `buddyVisible` off (set in the DB until the dashboard exists), a Windows toast with both buttons appears instead
- Sleep the PC through a due time → on wake, one pop-up, not a burst

## Phase 5 — Dashboard window, tray, sync (code done; on-screen check blocked)

- [x] Window roles + `openDashboard()`; plugin registration for the second engine (Windows and macOS runners)
- [x] `WindowBus`: `dataChanged` → `markTablesUpdated` sync, `testReminder` command; no echo; quiet when the peer is closed (D19)
- [x] Tray: icons generated, menu with live labels/checks, Windows left-click → dashboard (D20)
- [x] Theme: spec tokens light/dark as a `ThemeExtension`, Baloo 2 + Figtree, theme mode from settings
- [x] Shell: prototype-style rail → top bar under 860 px
- [x] Dashboard: greeting, next-up countdown / DND notice, goal ring, goal rows with streak/bar/+1, empty state → Reminders, today's counts, Preview, DND switch, Coming up, Today (with "logged")
- [x] Reminders: list (switch, Test, Edit, Delete + Undo, live "next in"), starter chips, full editor with show/hide fields, three validation messages, live schedule description
- [x] Character: live preview on a floor backdrop, presets, six color pickers, chips for hair, hat, held item, spectacles; saves → overlay updates live
- [x] Analytics: KPIs, stacked bars by category with legend of used categories, goal line with dashed goal + dropdown + average/streak, by-reminder table, by-hour chart, empty state, Remove sample history
- [x] Settings: every setting, categories editor (delete moves reminders, last can't be deleted), Reset everything (confirm), debug-only sample generator
- [x] Bugs found and fixed: stale-snapshot settings writes (D22), component fonts (D23), non-numeric progress semantics (D21)
- [x] Tests: 207 passing (38 new: bus with two real connections, analytics, describe, sample history, window roles, and widget tests covering every page × 2 widths, goal rows, editor validation, starters, preview)
- [ ] Launch at login, export/import: Phase 6

### Hand-check once it builds

- Tray icon appears; left click opens the dashboard (titled, centred, 1180×820); right click shows the menu
- Tray "Hide Buddy" → the buddy disappears and the menu now says "Show Buddy"; DND check mark matches the dashboard switch both ways
- Dashboard "Test" on a reminder → the buddy pops it up; answering it adds nothing to Today
- Edit a reminder's interval to 1 min in the dashboard → the buddy fires about a minute later; the change shows in the overlay without a restart
- Character changes and settings (size, speed, walk) apply to the walking buddy immediately
- Close the dashboard and reopen it from the tray: it works again; quitting from the tray closes everything

## Phase 6 — Polish (code done; on-screen check blocked)

- [x] Schema v2 + first real migration (`focusPopups`), schema and data-integrity tests (D25)
- [x] Keyboard / screen-reader access to pop-ups: "Focus pop-ups" setting, automatic with a screen reader, focus handed back afterwards (D24)
- [x] Reduce motion from Windows' "Animation effects", live (D26)
- [x] Launch at login (`launch_at_startup`), OS-wins-on-start sync (D27)
- [x] Export / import with validation, repair, confirmation and one-transaction restore (D27)
- [x] Optional Rive character with painter fallback + `docs/rive-contract.md` (D28)
- [x] Idle efficiency: hidden buddy renders and ticks nothing (D29)
- [x] Tests: 216 passing (8 new + the migration test: backups, login sync, Rive fallback)
- [ ] macOS: focus-for-alert, reduce-motion source, login item (Mac pass, Phase 7)
- [ ] CPU target (< 2% while walking): measure with `tool/spike_bench.ps1` once it builds

### Hand-check once it builds

- Windows Settings → Accessibility → Visual effects → Animation effects **off**: the buddy stops swinging and bobbing but still walks; turn it back on and it animates again (no restart)
- Settings → Focus pop-ups on, then `DEMO_FIRE_IN=20`: the pop-up takes focus, Enter answers it, and focus returns to the app you were in. With it off, typing in another app is never interrupted
- Narrator running: pop-ups are read out and take focus without the setting
- Launch at login on → appears in Task Manager → Startup apps; disable it there → the setting shows off after the next start
- Export → Reset everything → Import the file → everything is back; the buddy stays where it was

## Phase 7 — Packaging (configured; building blocked)

- [x] App icon at every size (D33); Windows version info says "Desk Buddy"
- [x] Single instance on Windows; second launch opens the dashboard (D30)
- [x] Inno Setup installer script (per-user, upgrade-safe, uninstall cleanup) + MSIX config (D31)
- [x] macOS runner: overlay panel, overlay channel, accessibility, focus, login item, reopen → dashboard, LSUIElement, entitlements (D32, **unverified**)
- [x] Guides: `docs/release-windows.md`, `docs/release-macos.md`, `docs/macos-verification.md`
- [ ] Build both packages (needs the VS C++ workload / a Mac)
- [ ] Decide the overlay strategy from measurements (D4), move it out of `lib/spike/`, and drop the benchmark-only code paths

## Owner to-do list (everything left needs a machine I don't have)

1. Install the VS C++ workload (command at the top of this file), optionally `flutter upgrade`.
2. Windows: `powershell -ExecutionPolicy Bypass -File tool\spike_bench.ps1`, then work through the hand-check lists from Phases 1–6 above. Report anything off.
3. Mac: `docs/macos-verification.md`.
4. Choose a real bundle id / publisher name before the first public release (they become permanent), then follow the release guides.

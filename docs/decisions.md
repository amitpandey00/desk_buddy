# Decisions

## D1 — Windows-first development (2026-10-06)

The dev machine is Windows 11. macOS code paths are written alongside but must
be verified on a Mac by the owner at each phase gate.

## D2 — Overlay window: native channel instead of window_manager for movement (2026-10-06)

Reading the plugin sources (window_manager 0.5.2, screen_retriever 0.2.2) on
Windows showed two problems for an overlay:

1. `windowManager.setPosition` → `SetWindowPos(hwnd, HWND_TOP, …, SWP_NOSIZE)`
   **without `SWP_NOACTIVATE`**. Every walking step would activate the window
   and steal keyboard focus from the user's app.
2. screen_retriever divides each monitor's rect by *that monitor's* scale
   factor and the cursor by the *window's* scale factor. On a mixed-DPI
   multi-monitor setup the results aren't in one coordinate space, so edge and
   display math breaks.

Decision: the Windows runner exposes a small `desk_buddy/overlay` channel
(`windows/runner/overlay_channel.cpp`) that works in physical pixels:
`getDisplays` (bounds, work area, scale), `getCursor` (+ button state),
`setFrame` (`SWP_NOACTIVATE | SWP_NOZORDER`), `setClickThrough`,
`setHitRegion`, `raise`, `cpuTimes`, and a `displaysChanged` event (on
WM_DISPLAYCHANGE, WM_DPICHANGED, and WM_SETTINGCHANGE/SPI_SETWORKAREA, which
covers taskbar moves). window_manager stays for the dashboard window and
macOS.

The main runner window is created as the overlay: `WS_POPUP`,
`WS_EX_TOPMOST | WS_EX_TOOLWINDOW` (no taskbar or Alt-Tab entry),
`WS_EX_NOACTIVATE` + `MA_NOACTIVATE` (clicking the buddy doesn't steal focus),
shown with `SW_SHOWNOACTIVATE`. Transparency comes from
`DwmExtendFrameIntoClientArea(-1)` + the transparent accent policy
(the same technique window_manager uses).

Consequence to handle in Phase 6 (accessibility): a no-activate window can't
take keyboard focus. When a reminder pops up, or the buddy is reached by
keyboard, we'll temporarily allow activation.

## D3 — Drag uses the native cursor, not Flutter pointer deltas (2026-10-06)

When the window moves under the pointer (Option A), Flutter's local pointer
coordinates feed back on themselves, and a release outside the window can be
lost. Drag therefore records the grab offset on pointer-down, then each frame
reads `getCursor` (physical position + button state) until the button is
released. Movement under 4 logical px counts as a tap. This works the same
for every strategy and across monitors.

## D4 — Overlay strategy: PENDING MEASUREMENT

Candidates (all in `lib/spike/`, chosen with `--dart-define=SPIKE=…`):

| | How | Click-through | Expected cost |
|---|---|---|---|
| **A** | buddy-sized window moved with `SetWindowPos` (60 or 30 Hz) | not needed (window ≈ buddy) | small surface; one native call per frame |
| **B** | work-area-sized window | `WS_EX_LAYERED|TRANSPARENT` toggled by a 50 ms cursor poll | full-screen surface; 20 polls/s forever; first click can fall through in a ≤50 ms race |
| **C** | work-area-sized window | `SetWindowRgn` follows the buddy (+bubble) | full-screen surface; region update only when the buddy moves; no polling |

C was added because it removes B's polling and input race on Windows.

Results: run `tool\spike_bench.ps1` (needs the VS C++ workload, see
progress.md). It records CPU (% of one core), fps, build/raster p50/p90/p99,
and native call rate/latency for three phases: walking, idle-animating, and
static.

_Numbers and the final choice go here._

### Rejected: `LWA_COLORKEY` click-through

Color-key layered windows are click-through on keyed pixels for free, but
they can't do anti-aliased edges or the drop shadow, so they leave visible
fringes. Rejected on quality.

## D5 — freezed 4.0.0-dev.3 until the Flutter SDK is upgraded (2026-10-06)

Stable freezed 4.0.x needs Dart ≥3.13, and this machine has Flutter 3.44.8 /
Dart 3.12.2. Stable freezed 3.2.x conflicts with json_serializable 6.13+
(source_gen 3 vs 4). `4.0.0-dev.3` is the 4.0 generator that supports Dart
3.12 and analyzer 13. Once on Flutter ≥3.47 (the current stable), change it
to `freezed: ^4.0.2` and `freezed_annotation: ^3.1.0`.

## D6 — `BuddyLook.spectacles` instead of `glasses` (2026-10-06)

The spec names the eyewear flag `glasses`, but its own no-hardcoding grep
bans `glass`. The code field is `spectacles`, which passes even a plain
substring grep. The guard test matches whole words, and a reviewed line can
opt out with `// guard-ok: <reason>` (for example the Character screen's
"Glasses" label).

## D7 — Buddy frame budget (2026-10-06)

`BuddyView` drives its pose through a `ValueListenable`, so animation frames
repaint only the painter and never rebuild widgets.
- walking / alert: every vsync (Ticker)
- idle / dragging: 15 fps timer (breathing is 1.5 px and a blink lasts
  ~90 ms, so more frames buy nothing)
- reduce motion: no timers; repaints only when inputs change

The overlay host's own movement ticker stops while the buddy is idle and wakes
on a timer when the walker's idle period ends. Animation time is a monotonic
`Stopwatch`, not wall-clock time, so it's outside the clock rule.

## D8 — Overlay root provides its own focus scope; alerts focus "done" (2026-10-06)

The overlay is a `WidgetsApp` without a Navigator, so nothing had focus and
Tab did nothing (caught by a widget test). The root now wraps content in an
autofocusing `FocusScope`, and an alert bubble focuses its primary action:
Enter answers it, Tab reaches "Remind me". This still depends on the window
being allowed to take focus when an alert shows (D2, Phase 6).

## D9 — Prop labels live in the prop registry (2026-10-06)

The spec asks that adding a prop means only adding a registry entry, and that
all strings live in one place. Those conflict for prop names. Each
`PropDef` therefore carries its own label. When localization arrives, labels
become keys looked up in the strings file.

## D10 — SQLite via `sqlite3` 3.x build hooks, not `sqlite3_flutter_libs` (2026-10-06)

`sqlite3_flutter_libs` is end-of-life (`0.6.0+eol`). `sqlite3` 3.x bundles
SQLite itself through Dart build hooks (it downloads prebuilt binaries, so no
C toolchain is needed). Drift 2.35 is built on it. `drift_flutter` was dropped
too: it still depends on the end-of-life package plus SQLCipher, and its only
job is a convenience opener. `open_database.dart` does that in a few lines,
with WAL, `busy_timeout = 3000` and `synchronous = NORMAL`. A side benefit:
`flutter test` opens real SQLite (3.53) on Windows, so the data layer is fully
tested without the native build.

## D11 — Seeded reminders start unscheduled (2026-10-06)

The seeder doesn't compute `nextDueAt`; the Phase 4 scheduler fills it in on
start for every enabled reminder whose value is null. Phase 3 therefore
doesn't depend on Phase 4. A disabled or past one-off reminder legitimately
stays null.

## D12 — Two windows, one file: write rules (2026-10-06)

Each window has its own connection to the same database file.
- Writes that happen often or in the background touch only their own
  columns: `saveBuddyPosition` (overlay) and `setSchedule` (scheduler). They
  can't overwrite an edit made a moment earlier in the other window. Tested.
- `settings.update` is a read-modify-write inside one transaction.
- Deleting a category (moving its reminders, then deleting) happens in one
  transaction.
- The settings and look tables are enforced single-row (`CHECK id = 1`).
- `DataChanges` announces every write by table topic. Phase 5 forwards it as
  `dataChanged` to the other window, which refreshes its providers.
- A test runs two connections on one WAL file with 40 interleaved writes and
  no `SQLITE_BUSY`.

## D13 — Small schema additions beyond the spec (2026-10-06)

- `log_entries.sample`: marks debug-generated history, so "Remove sample
  history" deletes exactly those rows.
- `reminders.source` (default `local`): the extension point the spec asks for
  ahead of calendar integration.
- Indexes on `log_entries(at)` and `(reminder_id, at)`, which serve the
  dashboard (today), analytics (7 days) and streak queries.
- `daysOfWeek` is stored as sorted JSON text.
- No foreign key from log entries to reminders, because history outlives
  deleted reminders (spec).

## D14 — Scheduler = pure reducer + thin service (2026-10-06)

`SchedulerCore` (`features/scheduler/engine/`, no Flutter, no I/O) turns
events (`Tick`, `RemindersLoaded`, `ConfigChanged`, `Respond`, `TestFire`,
`SnoozeAll`) into effects (`ShowAlert`, `HideAlert`, `WriteLog`,
`UpdateSchedule`). `SchedulerService` (overlay only) runs the 1 s timer, feeds
it drift streams, and applies effects strictly in order.

The core decides synchronously and keeps its own copy of the schedule. A
reload that predates its last write can't make a reminder fire twice. A
reload with a newer `updatedAt` (a user edit, in either window) wins over the
pending write. Hence:
- the scheduler is the only caller of `setSchedule`, which leaves
  `updatedAt` alone
- every user change goes through `ReminderCommands` (full save, bumps
  `updatedAt`, recomputes `nextDueAt` from now)

## D15 — Time and DST policy (2026-10-06)

- All calendar math goes through `WallClock` (`LocalWallClock` in the app, a
  `timezone`-backed one in tests: New York, Sydney).
- Daily and one-off times are wall-clock times: 07:00 stays 07:00 across DST,
  23 or 25 real hours apart (tested).
- Intervals are elapsed time: "every 60 min" is 60 real minutes, also across
  a DST jump.
- A time skipped by spring-forward (02:30) fires at 03:30, the
  `java.time` / JS "compatible" convention. A time that happens twice on
  fall-back fires once, at the first occurrence.
- Days, streaks, "today" and retention use calendar days, never 24 h.

## D16 — Scheduling behaviors the spec left open (2026-10-06)

- **Test / Preview pop-ups** aren't logged, don't reschedule, and work during
  DND. Opening one over a real pop-up hides the real one, which stays due and
  comes back.
- **Turning DND on** hides an open pop-up without logging it. It stays due and
  fires after DND ends.
- **One-offs** switch themselves off whenever nothing is left to schedule:
  after done, and also after missed (the spec only says done). A snoozed
  one-off stays on and returns.
- **After sleep** (a tick more than 2 min after the last one), a pop-up left
  open is logged as missed at the moment it was last seen. An interval
  reminder that became due while asleep, and whose active window has since
  closed, moves to the next window instead of firing out of hours. Only
  sleep does this: a reminder that waits in the queue, is snoozed past the
  window end, or is held by DND still fires when its turn comes (revised in
  D34).
- **Snooze all** logs an open pop-up as snoozed and pushes every reminder due
  within the period to its end.
- **Ties** in due time fire in creation order.

## D17 — Chime and notification fallback (2026-10-06)

- `assets/sounds/chime.wav` is generated by `tool/make_chime.py` from the
  prototype's Web Audio parameters (660 Hz then 880 Hz). WAV, not MP3: no
  encoder needed and audioplayers plays it on both OSes.
- Played through `audioplayers`; any playback error is swallowed, so a missing
  chime can never break a reminder.
- When the buddy is hidden, `local_notifier` shows the pop-up with the done and
  snooze buttons. On Windows those are toast buttons. On macOS, buttons depend
  on the user's notification style; an unanswered notification auto-misses
  like an unanswered bubble.
- Both sit behind small interfaces (`PlayChime`, `AlertNotifier`), so the
  service is tested with fakes.

## D18 — Upserts write explicit nulls (bug found in Phase 4) (2026-10-06)

drift's `insertOnConflictUpdate(dataClass)` treats null fields as "leave
unchanged" on the update path. Turning a reminder off therefore didn't clear
`nextDueAt`; clearing an active window, a one-off's date or the saved
position would also have silently failed. Every upsert now passes
`toCompanion(false)`. There are regression tests for reminders, `saveAll` and
settings.

## D19 — Two windows: roles, sync and commands (2026-10-06)

- Both windows run `main()`. `WindowController.fromCurrentEngine().arguments`
  decides the role (`WindowRole`): empty means the overlay (the process's
  main window); `{"role":"dashboard"}` means the dashboard, created from the
  tray (`openDashboard()` reuses an existing one).
- Each engine opens its own connection to the shared database (D12).
- **Sync:** `WindowBus` sends every local `DataChanges` event to the peer as
  `dataChanged(topics)`. The peer calls drift's `markTablesUpdated` for those
  tables, so every `.watch()` query in that window re-runs and the Riverpod
  providers refresh. Nothing is written, so nothing echoes back. Tested with
  two real connections to one WAL file, including a control test showing
  that without the bus the other window would never notice.
- **Commands:** `testReminder(id)` (dashboard → overlay: Test / Preview). The
  spec's `setDnd`, `settingsChanged` and `characterChanged` are plain writes
  announced as `dataChanged{settings}` or `dataChanged{look}`. One mechanism,
  and the tray and dashboard can't disagree.
- Transport: `desktop_multi_window` 0.3's `WindowMethodChannel`; tests use
  an in-memory pair. If the dashboard isn't open, sends complete quietly.
- Plugins are registered for the dashboard's engine via the
  `desktop_multi_window` created-window callback in both runners.

## D20 — Tray (2026-10-06)

- `tray_manager` 0.5.3: 0.7 needs Flutter 3.47 (see the SDK upgrade note).
- Icons are generated by `tool/make_tray_icons.py`, with no image libraries:
  a colored buddy face as `.ico` (16/24/32) for Windows, and a
  black-plus-alpha template PNG for the macOS menu bar.
- Windows: left click opens the dashboard, right click shows the menu.
  macOS: any click shows the menu.
- Menu: Open Dashboard · Show/Hide Buddy (label follows the state) · Do Not
  Disturb (check mark) · Snooze all for 30 min · Quit. Labels and checks
  follow the settings whoever changes them.

## D21 — Dashboard choices (2026-10-06)

- Deleting a reminder happens at once and offers **Undo** (snackbar), instead
  of a confirmation dialog.
- The editor has an "Only between certain hours" checkbox, so an interval can
  have no window (the spec's `null` = all day), which the prototype couldn't
  express.
- Starter chips resolve or create the starter's category when tapped (as in
  the prototype), but save nothing until "Add reminder".
- "Launch at login" is stored now; Phase 6 wires it to `launch_at_startup`.
  Export/import is also Phase 6, as planned.
- Sample history: Settings → Developer, only in debug builds (`kDebugMode`),
  plus "Remove sample history" on Analytics whenever sample rows exist.
- The by-reminder table and completion rate exclude manual +1s (prototype),
  but they do count toward "completed" and the goal charts.
- The goal bar's screen-reader value must be numeric (Flutter 3.44 asserts
  it), so it reports a percentage, and "3 of 8" goes in its label. Caught by
  the render tests.

## D22 — Settings writes apply to the current row (bug found in Phase 5) (2026-10-06)

The first version of the settings switches built the new settings from the
page's last snapshot (`s.copyWith(...)`). Flipping a switch could therefore
undo a change made a moment earlier in the other window or the tray. Every
control now goes through `settings.update((current) => …)`.

## D23 — Component text styles name the font (bug found in Phase 5) (2026-10-06)

Chip labels and button text styles replace the theme's text style rather
than extending it, so they lost Figtree and would have fallen back to Segoe UI
on Windows. Found by rendering the screens to images: the test font
showed those labels as blocks. The chip, input, snackbar and button styles
now set `fontFamily` themselves.

## D24 — Keyboard and screen-reader access to pop-ups (closes the D2 caveat) (2026-10-06)

The overlay is no-activate, so it never steals focus while you type. The
downside is that a keyboard or screen-reader user can't reach a pop-up.
- New setting **Focus pop-ups** (schema v2, default off). When it's on, or
  while a screen reader is running (`SPI_GETSCREENREADER`, read live), a
  pop-up takes keyboard focus: `focusForAlert` drops `WS_EX_NOACTIVATE` and
  brings the overlay forward. Windows only hands foreground to the active
  app, so it uses the documented synthetic-Alt technique. The "done" button
  is autofocused (D8), so Enter answers and Tab reaches "Remind me".
- When the pop-up closes, `releaseFocus` restores no-activate and gives focus
  back to the app that had it.
- Default off, because a pop-up that grabbed focus would swallow whatever the
  user was typing.
- On macOS the same calls are a to-do for the Mac verification pass.

## D25 — First schema migration (v1 → v2) (2026-10-06)

`settings.focus_popups BOOLEAN DEFAULT 0`, written with drift's
`make-migrations` (`app_database.steps.dart` → `stepByStep(from1To2: …)`).
Tested two ways: the schema check (v1 migrated to v2 equals a fresh v2), and
a data-integrity test that fills a real v1 database, migrates it and checks
every row survived.

## D26 — Reduce motion (2026-10-06)

The Windows embedder doesn't put "Animation effects" into `MediaQuery`, so the
overlay reads `SPI_GETCLIENTAREAANIMATION` natively and live
(`WM_SETTINGCHANGE` → `accessibilityChanged`). Reduce motion stops every
looping animation and the bubble's pop. The buddy still changes position, as
the spec says. Elsewhere (macOS, the dashboard) `MediaQuery.disableAnimations`
applies as usual.

## D27 — Launch at login, export / import (2026-10-06)

- **Launch at login:** `launch_at_startup` (Windows Run key; MSIX
  StartupTask once packaged, Phase 7). At startup the OS state wins: if the
  user removed Desk Buddy in Windows' Startup apps, the setting follows. After
  that, the setting drives the OS. If the OS refuses, the setting shows the
  truth. The macOS login item needs native setup: Phase 7.
- **Export / import:** one JSON file `{format: "desk-buddy-backup", version,
  schemaVersion, exportedAt, categories, reminders, log, settings, look}`.
  - Import validates everything first, then replaces all data in one
    transaction.
  - Reminders pointing at a missing category move to the first category.
    Intervals below 1 minute and negative goals are clamped. Settings are
    normalized.
  - `nextDueAt` is cleared, so the scheduler plans from now instead of firing
    a backlog.
  - This machine's buddy position is kept, and export leaves it out.
  - The confirmation dialog shows the counts before anything is replaced.

## D28 — Optional Rive character (2026-10-06)

`BuddyCharacter` uses `RiveBuddyView` when `assets/rive/buddy.riv` ships and
loads; otherwise it uses the painter. Any Rive failure is logged and falls back
to the painter, so a broken file can never cost the user their buddy. The
inputs are view-model properties (Rive 0.14 data binding), not legacy
state-machine inputs: `state`, `flip`, `reduceMotion`, six colors, `hairStyle`,
`hat`, `spectacles`, `prop`. Missing properties are skipped. The full spec for
the artist is in `docs/rive-contract.md`. This path is untested: no `.riv`
exists, and `rive_native` isn't loaded under `flutter test`. The fallback is
tested.

## D29 — Idle efficiency (2026-10-06)

- Hidden buddy: nothing is rendered, the movement ticker stops, and B's cursor
  poll skips. Only the scheduler's 1 s timer remains.
- Idle: the movement ticker is off; the buddy repaints at 15 fps (D7).
- Reduce motion: no repaint loop at all.
- The < 2% CPU-while-walking target still needs measuring on hardware
  (Phase 1 benchmark).

## D30 — Single instance (2026-10-06)

Launch at login plus a manual launch would have meant two buddies and two
schedulers writing the same database.
- **Windows:** a named mutex (`Local\DeskBuddy.SingleInstance`). A second
  launch broadcasts a registered window message and exits; the running
  overlay opens its dashboard.
- **macOS:** LaunchServices already keeps one instance;
  `applicationShouldHandleReopen` opens the dashboard.
- The installer's `AppMutex` reuses the same name, to close the app before
  upgrading.

## D31 — Windows packaging: Inno Setup first, MSIX second (2026-10-06)

- **Inno Setup** (recommended): per-user, no admin prompt; upgrades in place
  and closes the running app; uninstall removes the launch-at-login entry
  and only deletes user data on request. Launch at login there is the plain
  registry Run key the app already manages.
- **MSIX**: configured (`msix_config`); signing required. Under MSIX,
  `launch_at_startup` switches to a Startup-folder shortcut, detected by
  the identity name in the install path. That's untested, so MSIX is second
  choice until it's verified.
- App data lives in `%APPDATA%\Desk Buddy\Desk Buddy`, because path_provider
  builds the path from CompanyName/ProductName in `Runner.rc`, which now
  say "Desk Buddy". **This changed the data folder** (it was
  `com.deskbuddy\desk_buddy`). It doesn't matter yet because nobody has run
  the app, but it must never change again after a release.

## D32 — macOS runner (unverified) (2026-10-06)

- The overlay is a non-activating `NSPanel` at `.statusBar` level, joining
  all Spaces and full-screen apps. `LSUIElement` hides the Dock icon.
- The `desk_buddy/overlay` channel is implemented in Swift with the same
  contract as Windows. Points are flipped to a top-left origin and the scale
  is reported as 1, so the Dart side is unchanged.
- `setHitRegion` doesn't exist on macOS, so overlay strategy C is
  Windows-only; macOS uses A or B.
- Launch at login uses `SMAppService` (macOS 13+) behind launch_at_startup's
  channel, avoiding the LaunchAtLogin Swift package and its manual Xcode
  steps.
- Sandbox stays on, plus user-selected file read/write for export and
  import. Distribution is Developer ID + notarization (`docs/release-macos.md`).
- Nothing here has been compiled; `docs/macos-verification.md` is the
  checklist.

## D33 — App icon (2026-10-06)

The buddy's face on a rounded accent tile, generated at every size from one
1024 px master by `tool/make_app_icons.py` (no image libraries):
Windows `.ico` 16–256, the macOS AppIcon set, and the MSIX logo.

## D34 — Full code review before the first push (2026-10-06)

Four parallel reviews (scheduler, data and sync, overlay and native,
dashboard), run with the project skill `.claude/skills/desk-buddy-review`.
Each finding was checked against the code before fixing. All fixed items
have regression tests; 231 tests now pass.

**Fixed (bugs)**
- *Scheduler:*
  - An effect that throws (a refused notification, a busy disk) no longer
    stops the scheduler: effects are isolated and reported.
  - A response now names the pop-up it answers (`firedAt`), so a stale click
    can't answer a newer one.
  - The active-window skip is limited to sleep (see D16).
  - A test pop-up of a disabled reminder survives reloads.
  - `dispose` stops further dispatching.
  - `updatedAt` only ever grows, so "edit wins" holds even if the system
    clock goes backwards.
  - A disabled past one-off can be renamed, and can't be re-enabled.
  - Intervals below 1 min are rejected with a message instead of being
    clamped silently.
- *Dashboard:*
  - The new-reminder form kept a fresh id on every build, so any data
    refresh wiped what the user was typing.
  - Undo used `ref` after unmount, and revived a stale due time.
  - The editor re-enabled a reminder switched off while it was open (D22).
  - The date picker asserted on past one-offs.
  - The name field wrote an old name back after an import.
  - Look and category edits saved snapshots; they now go through
    `updateLook` / `categories.updateWith`.
  - The busiest-hour label read −1 when there were no completions.
  - The goal dropdown could overflow.
  - Streaks are counted over the full 90 days kept.
- *Backup:*
  - Importing another PC's backup no longer switches on launch at login
    here.
  - Duplicate ids are rejected up front.
  - A failed restore shows a message.
- *Launch at login:* changes apply one at a time, so a failing earlier
  change can't overwrite a newer choice.
- *Overlay host:*
  - When a monitor is unplugged the buddy falls back to the primary display
    instead of staying on the vanished one.
  - A scale change on the same work area is picked up.
  - Strategy A keeps its window and bubble on screen and flips the bubble
    below when there's no room above.
  - Strategy C measures the bubble outside the pop-in animation, retries
    region updates instead of dropping them, and starts with an empty
    region.
  - A pop-up that fired before the overlay subscribed is shown.
  - Focus is always handed back after an alert.
  - Quitting saves the position first.
  - Second-launch and accessibility callbacks are wired before startup's
    awaits.
- *Rive:* a file that parses but breaks the contract falls back to the
  painter (probed while loading); unknown props fall back the same way as
  the painter's.
- *Windows native:*
  - Alt is held across `SetForegroundWindow`, so the user's app never sees a
    full Alt tap (which would open its menu bar).
  - The tray menu now closes on an outside click (`bringAppToFront`).
- *macOS native (still uncompiled):*
  - `activate(options:)` replaces the macOS 14-only `activate()`.
  - The level is set after `isFloatingPanel`.
  - `.nonactivatingPanel` is set at init.
  - Mixed array literals are typed.
  - Reopen is handled through the Apple event instead of an override that
    may not exist on `FlutterAppDelegate`.

**Checked and rejected**
- "Read-then-write transactions race into SQLITE_BUSY_SNAPSHOT." True for a
  plain `BEGIN`, which raw SQLite confirms (code 517). However, drift's
  native executor opens every transaction with `BEGIN IMMEDIATE`, so the
  write lock is held from the start and the other window waits on
  `busy_timeout`. That's now pinned by a two-connection test.

**Recorded for the overlay strategy decision (D4)**
- Strategy A's window, while showing a bubble, is about 334 × (buddy + 190)
  logical px and isn't click-through. For the length of an alert it
  swallows clicks around the buddy.

## D35 — The buddy only appears for reminders by default (2026-10-07)

The owner's first on-screen run: a buddy that's always walking is too
present. New setting **Always on screen** (schema v3, `buddyAlwaysOn`,
default **off**). When it's off, the overlay window is hidden and appears
only while a pop-up (real or Test) is showing, then hides again after Done,
Remind me later or auto-miss. It returns at its saved position. Turning it
on restores the spec's always-walking buddy. The switch is in Settings and
in the tray menu ("Always on Screen"). "Show buddy" off still means no
character at all, with reminders as system notifications. Existing installs
upgrade to off.

## D36 — "No" button and the sad reaction (2026-10-07)

Owner request. Pop-ups (and the Windows toast) now have three answers: the
reminder's done label, **No**, and Remind me in N min.
- "No" logs a new action **skipped**: "I didn't do it", which isn't the
  same as *missed* (never answered). The reminder then goes to its next
  normal time, not a snooze. A one-off switches itself off. Stored as text,
  so no schema change; older backups import unchanged.
- Analytics: skipped answers count as pop-up responses that weren't done,
  so they lower the completion rate. They get their own "Said no" column
  and KPI count, and a "said no" tag in Today.
- The buddy reacts with a new `BuddyState.sad` for about 3.2 s: slumped
  2.5 px, slow 3.2 s breathing, eyes at 70%, brows raised in the middle, a
  frown and a tear, and a compact "😢 Oh… okay. Next time!" bubble. It then
  leaves, unless "Always on screen" is on. Reduce motion keeps the sad face
  without the breathing. The Rive contract gains the `sad` state.

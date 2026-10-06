# Build "Desk Buddy" — a Flutter desktop reminder companion

## 1. What we're building

Desk Buddy is a desktop app (macOS first, Windows second) with an animated character that lives **on top of all other windows**. The character walks along the bottom of the screen, idles, and can be dragged anywhere. When a reminder is due, it stops, hops and waves, and a speech bubble pops up with the reminder message and two buttons: a "done" button and "Remind me in N min".

A separate **Dashboard window**, opened from the menu-bar/tray icon, holds five sections:
- Dashboard
- Reminders
- Character
- Analytics
- Settings

A working HTML prototype of the full behavior is at `docs/prototype.html`. Open it in a browser and read its JavaScript. **Treat it as the behavioral spec.** When this prompt and the prototype disagree, this prompt wins.

### The one rule that matters most

**Nothing is hardcoded to a specific reminder.** "Drink water" is only one starter template, stored as seed data. No code path may branch on a reminder title, category name, emoji, or prop name.

Every behavior comes from fields on the data:
- schedule
- message template
- goal and unit
- prop
- category

Adding a new kind of reminder must never require a code change. Before finishing each phase, grep the `lib/` folder for `water`, `drink`, `glass`, and `sip`. They may appear only in the seed JSON asset and in tests.

---

## 2. Tech stack

Use these packages. If one doesn't work on current stable Flutter, pick the closest maintained alternative and tell me why.

| Concern | Package |
|---|---|
| State management | `flutter_riverpod` (with `riverpod_generator`) |
| Persistence | `drift` + `sqlite3_flutter_libs` (SQLite, WAL mode) |
| Window control | `window_manager` |
| Screen / cursor info | `screen_retriever` |
| Second window | `desktop_multi_window` |
| Tray / menu bar | `tray_manager` |
| Launch at login | `launch_at_startup` |
| System notification fallback | `local_notifier` |
| Sound | `audioplayers` |
| Charts | `fl_chart` |
| Testable time | `clock` (always use `clock.now()`, never `DateTime.now()`) |
| Models | `freezed` + `json_serializable` |
| Character animation (phase 6) | `rive` |

- Target the latest stable Flutter.
- Enable `macos` and `windows` desktop targets.
- Linux is a non-goal for now, but don't do anything that blocks it.

---

## 3. Architecture

### Two windows, one source of truth

**1. Overlay window (main engine)**
- Transparent, frameless, always on top, not shown in the taskbar or Dock, visible on all Spaces/virtual desktops.
- Renders the buddy and the bubble.
- Owns the **scheduler**. Only this engine fires reminders.

**2. Dashboard window**
- A normal window, created with `desktop_multi_window` from the tray menu.
- Reads and writes the same SQLite database.

**Sync between them:**
- After any write, the writer sends a lightweight `dataChanged` message over the multi-window method channel.
- The other side re-queries its providers.
- The dashboard sends commands to the overlay over the same channel: `testReminder(id)`, `setDnd(bool)`, `characterChanged`, `settingsChanged`.

### Overlay window strategy — do a spike first

Before building features, prototype both options below. Measure smoothness and CPU, then pick one and document the decision in `docs/decisions.md`.

- **Option A — moving small window.** The window is only as big as the buddy plus the bubble area. Move the whole window with `windowManager.setPosition` as the character walks. Click-through isn't needed because the window is tiny. Risk: jank at 30–60 fps position updates.
- **Option B — full-screen transparent overlay.** One window covers the display's visible frame, and the buddy is drawn inside it. Use `setIgnoreMouseEvents(true)` by default. Poll the cursor position (`screen_retriever`, about every 50 ms). When the cursor is over the buddy's or bubble's hit rect, switch to `setIgnoreMouseEvents(false)`; switch back when it leaves.

Whichever option wins, it must meet these requirements:
- Walking stays inside the **visible frame**, above the macOS Dock and Windows taskbar.
- It uses the display the buddy is currently on.
- It handles displays being added or removed and resolution changes.

### macOS specifics
- Set `LSUIElement` = true so there is no Dock icon.
- Use a floating window level that stays above full-screen apps where possible.
- Make the window visible on all Spaces.
- Use a transparent `NSWindow` background.

### Windows specifics
- Skip the taskbar and stay always on top.
- Transparent background; no flicker on show.

### Folder structure (feature-first)

```
lib/
  main.dart                 # decides overlay vs dashboard entry by window args
  app/                      # bootstrap, theme, routing for dashboard
  core/
    clock/                  # clock provider
    db/                     # drift database, tables, DAOs, migrations
    window/                 # overlay window service, multi-window channel
    tray/                   # tray menu
  features/
    scheduler/              # pure Dart scheduling engine + service
    buddy/                  # character painter, animation controller, movement, bubble
    reminders/              # list, editor form, starters
    dashboard/
    analytics/
    character/              # customization UI
    settings/
    categories/
  shared/                   # widgets, formatting, placeholder filling
assets/
  seed/starters.json
  seed/default_categories.json
  sounds/chime.mp3
test/
```

The scheduler and placeholder logic must be **pure Dart with no Flutter imports**, so they're fully unit-testable.

---

## 4. Data model

Use Drift tables backed by freezed domain models. Store IDs as UUID strings and timestamps as UTC epoch milliseconds.

### Category
| Field | Type | Notes |
|---|---|---|
| id | String | |
| name | String | |
| emoji | String | |
| colorHex | String | e.g. `#1FA97F` |
| sortOrder | int | |

### Reminder
| Field | Type | Notes |
|---|---|---|
| id | String | |
| title | String | required |
| emoji | String | |
| messageTemplate | String | supports placeholders (see §5) |
| categoryId | String | FK → Category |
| scheduleType | enum | `interval`, `daily`, `once` |
| everyMinutes | int | interval only, ≥ 1 |
| activeFrom / activeTo | String? `HH:mm` | interval only; null means all day; may cross midnight |
| timeOfDay | String `HH:mm` | daily and once |
| daysOfWeek | List<int> | daily only; 0 = Sunday; empty = every day |
| date | String? `yyyy-MM-dd` | once only |
| dailyGoal | int | 0 = no goal |
| goalUnit | String | e.g. "glasses", "pages", "sets" |
| propId | String | key in the prop registry, or `default` = character's usual item |
| doneLabel | String | text on the done button |
| enabled | bool | |
| nextDueAt | int? | epoch ms; null = nothing scheduled |
| createdAt / updatedAt | int | |

### LogEntry
| Field | Type | Notes |
|---|---|---|
| id | String | |
| reminderId | String? | keep the row even if the reminder is deleted |
| categoryId | String? | snapshot at log time |
| at | int | epoch ms |
| action | enum | `done`, `snoozed`, `missed` |
| responseSeconds | int | from pop-up to response |
| manual | bool | true when logged via the "+1" button rather than a pop-up |

### BuddyLook (single row)
| Field | Notes |
|---|---|
| skinHex, hairHex, jacketHex, shirtHex, pantsHex, shoesHex | colors |
| hairStyle | `spiky`, `short`, `long`, `none` |
| hat | `none`, `cap`, `beanie` |
| glasses | bool |
| defaultPropId | the item it usually holds |

### Settings (single row)
| Field | Default |
|---|---|
| userName | "there" |
| buddySize | 120 (logical px wide, range 70–220) |
| walkSpeed | 45 px/s (range 10–140) |
| walkEnabled | true |
| buddyVisible | true |
| soundEnabled | true |
| snoozeMinutes | 10 (options 5/10/15/30/60) |
| autoMissMinutes | 5 (options 2/5/10/15) |
| doNotDisturb | false |
| themeMode | system / light / dark |
| launchAtLogin | false |
| lastBuddyPosition | so it reappears where it was |

### Seed data
- On first launch, insert the default categories from `assets/seed/default_categories.json`: Health, Work, Breaks, Personal.
- Insert the first three starters from `assets/seed/starters.json`: Drink water, Evening meeting, Stretch break.
- `starters.json` also holds the other templates (Eye break, Read 10 pages, Take vitamins, Workout). The Reminders screen shows all of them as one-tap starters. Copy their fields from the prototype's `STARTERS` array.
- Starters reference categories **by name**. If the category doesn't exist, create it.

### Retention and migrations
- Keep 90 days of logs and prune on startup.
- Write Drift migrations from version 1 onward, with a schema-version test.

---

## 5. Scheduling engine (pure Dart)

Port `computeNext` and `fitWindow` from the prototype and harden them.

### Computing the next due time
- **interval:** next = `from + everyMinutes`, then fitted into the active window. If outside the window, move to the next `activeFrom` (the same day if before it, otherwise the next day). Windows that cross midnight (e.g. 22:00–02:00) must work.
- **daily:** the first occurrence of `timeOfDay` strictly after `from` whose weekday is in `daysOfWeek` (or any weekday if the list is empty). Search up to 8 days ahead.
- **once:** `date + timeOfDay` if it's in the future, otherwise null.
- All times are **local wall-clock**. Handle DST correctly: a daily 07:00 reminder stays at 07:00 local across a DST change. Build dates with local `DateTime(y, m, d, h, min)`, never by adding fixed milliseconds for days.

### Responding to a reminder
| Action | What happens |
|---|---|
| done | log it, then `nextDueAt = computeNext(now)`. If `once` returns null, set `enabled = false`. |
| snoozed | log it, then `nextDueAt = now + snoozeMinutes`. |
| no response | after `autoMissMinutes`, log `missed`, then `nextDueAt = computeNext(now)`. |

### Service loop
- Ticks every second and uses `clock.now()`.
- Only one pop-up at a time. If several are due, fire the earliest. The rest fire one after another after the user responds.
- **DND:** don't fire anything. When DND is turned off, overdue reminders fire one at a time.
- **After sleep or a long gap:** detect when wall time jumps by more than 2 minutes between ticks. Each overdue reminder fires **at most once**, then reschedules from now. Never replay a backlog of missed intervals.
- Enabling a reminder recomputes `nextDueAt` from now. Editing a reminder recomputes it as well.

### Placeholders
`fillTemplate(template, context)` replaces these tokens:

| Token | Value |
|---|---|
| `{name}` | user's name |
| `{title}` | reminder title |
| `{count}` | times done today for this reminder, including manual |
| `{goal}` | daily goal |
| `{unit}` | goal unit |
| `{category}` | category name |

Unknown tokens stay as-is.

### Goal math
- **Today's count** = done entries for that reminder since local midnight.
- **Streak** = consecutive days with count ≥ goal. If today isn't met yet, start counting from yesterday.

### Unit tests (required)
Use `clock` with fixed times. Cover:
- interval inside the window, before it, after it, and with an overnight window
- daily with specific weekdays, empty weekdays, and the same-minute boundary
- once in the past and once in the future
- DST forward and back, using a fixed time zone setup or by injecting a tz offset function
- snooze, auto-miss, and once-disable behavior
- sleep-gap catch-up firing once
- multiple due reminders queuing
- streak and count calculations
- placeholder filling

---

## 6. The buddy (overlay)

### Character rendering
- **Phase 2:** port the prototype's SVG character to a `CustomPainter` built from layered parts:
  - shadow
  - legs and shoes
  - back arm
  - torso, shirt and lapels
  - neck
  - head with ears and back hair
  - hair style
  - hat
  - brows
  - eyes (blink)
  - glasses
  - cheeks
  - smile
  - front arm with the prop
  - hand
- Keep the prototype's 120 × 222 coordinate system and scale it to `buddySize`.
- Colors come from `BuddyLook`. The darker jacket shade is derived, as in the prototype's `shade()`.
- **Prop registry:** a `Map<String, PropPainter>` in a single file. Include `none`, `bottle`, `coffee`, `book`, `phone`, `dumbbell`, and `pill`. Adding a prop means adding a map entry and nothing else.
- During a pop-up, the buddy holds the reminder's `propId` (or its default prop if the reminder says `default`).

### Animation states
Drive these with `AnimationController`s and a small state machine:

| State | Behavior |
|---|---|
| walking | legs swing ±16° about the hips, back arm swings, body bobs 3 px, ~0.5 s cycle |
| idle | gentle 1.5 px breathing, 2.4 s cycle |
| alert | hop of 9 px every 0.9 s, back arm waves between -165° and -125° |
| dragging | idle pose, no auto-movement |

- Eyes blink about every 4.5 s in all states.
- The buddy flips horizontally when walking left. The bubble never flips.
- Respect the OS reduce-motion setting: no looping animations, and the buddy still moves position but without limb animation.

### Movement
- Walking alternates randomly between walk for 4–11 s and idle for 1.5–5 s, with a 40% chance of turning around after an idle.
- It turns around at the visible-frame edges.
- When `walkEnabled` is false, it stays idle where placed.
- Dragging moves it freely. A click with less than 4 px of movement counts as a tap. A tap shows a 2.8-second peek bubble: "<emoji> <title> in <countdown>", or "Nothing scheduled" if nothing is.
- The position persists across launches.

### Bubble
- Comic-style text: bold rounded display font (Baloo 2, bundled as an asset), yellow fill (`#FFCB2E`), thick coral stroke (`#E8473A`), drop shadow.
- Content:
  - reminder emoji + filled message
  - if the reminder has a goal: a white pill showing "<count> / <goal> <unit> today"
  - two buttons: `doneLabel` (dark) and "Remind me in N min" (white)
- Positioned above the buddy, clamped to the screen. If there's no room above, it shows below.
- It pops in with a springy scale from 0.6 to 1.0.
- A chime plays if sound is on.
- If `buddyVisible` is false, show a system notification through `local_notifier` instead, with the same message and actions where the OS supports them.

### Tray / menu bar menu
- Open Dashboard
- Show/Hide Buddy
- Do Not Disturb (checkable)
- Snooze all for 30 min
- Quit

---

## 7. Dashboard window screens

Use Material 3 with a custom theme in light and dark. Tokens:

| Token | Light | Dark |
|---|---|---|
| bg | `#EAF1F6` | `#121920` |
| panel | `#FFFFFF` | `#1B242E` |
| panel2 | `#F4F8FB` | `#222D38` |
| ink | `#1C2733` | `#E7EEF4` |
| muted | `#5E6D7C` | `#93A3B3` |
| line | `#D5E0E9` | `#2E3B48` |
| accent | `#2F7DE1` | `#5A9CF0` |
| coral | `#E8473A` | `#E8473A` |
| mint | `#1FA97F` | `#1FA97F` |

- Use **Baloo 2** for headings and **Figtree** for body text, both bundled as assets.
- Use a left navigation rail for the five sections.
- Match the prototype's layout and copy.

### Dashboard
- Time-based greeting with the user's name.
- A "Next up: … in <live countdown>" line, or a DND notice.
- **Hero:**
  - A progress ring showing % of all of today's goals combined (sum of min(count, goal) ÷ sum of goals).
  - Beside it, "Today's goals": one row per reminder with `dailyGoal > 0`. Each row shows the emoji tile tinted with the category color, the title, "count / goal unit", the streak, a progress bar, and a **+1** button that logs a manual done.
  - If there are no goals, show an empty state with a "Set a goal" button that opens Reminders.
- Today's done, snoozed and missed counts.
- A "Preview next reminder" button and a DND switch.
- Two panels:
  - **Coming up:** the next 5 reminders with live countdowns.
  - **Today:** the last 8 log entries with time, reminder, and a done/snoozed/missed/logged tag.

### Reminders
- **List:** emoji tile, title, category, schedule description, goal, a live "next in" countdown, an enable switch, and Test / Edit / Delete buttons.
- **Starter chips:** all templates from `starters.json`. Tapping one loads the editor pre-filled and doesn't save until the user confirms.
- **Editor fields:**
  - title (required), icon, message (with a placeholder hint)
  - category dropdown, "Buddy holds" dropdown (including "Its usual item")
  - repeat type, with fields that show or hide depending on the type
  - every (minutes), active from/until
  - time, date, weekday toggles
  - daily goal and "counted as" unit
  - done-button label
- **Validation messages:**
  - "Give the reminder a title"
  - "Pick a date for a one-time reminder"
  - "That time has already passed"
- **Schedule descriptions** follow the prototype's `describe()`, e.g. "Every 60 min, 08:00–22:00", "7:00 PM, weekdays", "Once on 2026-10-10 at 9:00 AM".

### Character
- A large live preview on a simple floor backdrop.
- Look presets: Classic, Sporty, Office, Cozy.
- Six color pickers.
- Chips for hair, hat, usually-holding (from the prop registry), and glasses.
- Changes apply to the overlay buddy immediately via `characterChanged`.

### Analytics (last 7 days)
- **KPIs:**
  - completion rate (done ÷ pop-up responses, excluding manual entries)
  - average response time
  - total completed, with snoozed and missed counts
- **Completed per day:** a stacked bar chart by category color, with a legend showing only the categories used.
- **Goal progress:** a line chart for the selected goal reminder (dropdown if there's more than one) with a dashed goal line, average per day, and streak.
- **By reminder:** a table of done, snoozed, missed, and completion % per reminder.
- **When you respond:** a bar chart of completions by hour (24 bars).
- An empty state when there's no data.
- A "Remove sample history" button, shown only if sample rows exist. Only generate sample history in debug builds via a dev menu, never in release builds.

### Settings
- Every setting from §4, plus launch at login and theme.
- **Categories editor:** add, rename, change emoji and color, delete. Deleting moves its reminders to the first remaining category, and you can't delete the last one.
- **Export / Import:** export all data to JSON and import with a confirmation dialog.
- **Reset everything:** with a confirmation dialog.

---

## 8. Quality bar
- `flutter analyze` is clean, using `very_good_analysis` or `flutter_lints` with strict mode.
- Every public scheduler and analytics function has tests.
- Add widget tests for the reminder editor's validation and the dashboard goal rows.
- No `DateTime.now()` anywhere outside the clock provider.
- No hardcoded reminder-specific logic (see the grep rule in §1).
- Keyboard accessible: focus order, Enter/Space on the buddy opens the peek, and the bubble buttons are focusable.
- Add semantic labels for screen readers on the buddy, bubble, and charts.
- The overlay idles efficiently: when the buddy is idle or hidden, stop the ticker and cursor polling except for the 1 s scheduler tick. Target under 2% CPU while walking on an M1 Mac.
- All user-facing strings live in one place (`lib/shared/strings.dart` or ARB files) so localization can be added later.

---

## 9. Work plan — go phase by phase

After each phase:
1. Run `flutter analyze` and the tests.
2. Update `docs/progress.md`.
3. **Stop and give me a short summary of what's done, what you decided, and anything I need to check by hand.**

Don't start the next phase until I reply.

0. **Setup.** Create the project, add packages, set up macOS/Windows runner configs, and write a `CLAUDE.md` with the key rules from this prompt (the no-hardcoding rule, the clock rule, the folder structure, and the test commands).
1. **Overlay spike.** Build Options A and B with a placeholder circle that walks and can be dragged. Measure, choose, and write `docs/decisions.md`. Make sure click-through works on macOS.
2. **Buddy rendering and movement.** CustomPainter character, prop registry, all animation states, flip, drag, peek bubble, and persisted position.
3. **Data layer.** Drift schema, DAOs, seed import from JSON assets, and migrations test.
4. **Scheduler.** Pure engine with full tests, the service loop in the overlay, the alert bubble with done/snooze, auto-miss, DND, sleep catch-up, sound, and notification fallback.
5. **Dashboard window and tray.** Multi-window setup, the sync channel, and all five screens wired to real data.
6. **Polish.**
   - Rive character option: design the state machine with `walk`, `idle`, `alert`, and `drag` states and color inputs, keeping the CustomPainter as the fallback. Document the expected `.riv` inputs so I can commission or make the asset.
   - Launch at login, export/import, reduce-motion, and accessibility.
7. **Packaging.** macOS `.app`/`.dmg` (note what signing and notarization I'll need) and a Windows MSIX or installer.

## 10. Non-goals for now
- Cloud sync and accounts
- Mobile
- Calendar integration (but keep `Reminder` easy to extend with a `source` field later)
- Multiple buddies on screen at once

If anything in this spec is ambiguous or technically impossible on a platform, ask me before guessing. Small choices are fine to make yourself; note them in `docs/decisions.md`.

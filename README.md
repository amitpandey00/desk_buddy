# Desk Buddy

A desktop reminder companion: an animated character lives on top of your
windows, walks along the bottom of the screen, and pops up with a speech
bubble when a reminder is due — drink water, stretch, a 7 PM meeting,
anything you set up. A dashboard (from the tray / menu-bar icon) holds your
reminders, goals, analytics, the character editor and settings.

Flutter, Windows first, macOS second.

> **Status:** all features are implemented and unit/widget-tested (233
> tests), but the app has **not yet been run natively**: the Windows build
> waits on the Visual Studio C++ workload, and the macOS runner on a Mac
> verification pass. See [`docs/progress.md`](docs/progress.md).

## Highlights

- Nothing is hard-coded to a reminder: schedules, messages (`{name}`,
  `{count}`, `{goal}`…), goals, the prop the buddy holds and categories are
  all data.
- Interval (with active hours, overnight windows), daily-at-time and one-off
  schedules; DST-correct; sleep-safe (no backlog bursts); DND; snooze;
  auto-miss.
- Two windows, one SQLite database (WAL), kept in sync live.
- Accessible: keyboard/screen-reader pop-ups, reduce motion, semantics.
- Export / import, launch at login, single instance, installer scripts.

## Develop

```sh
flutter pub get
dart run build_runner build
flutter analyze
flutter test
flutter run -d windows --dart-define=SPIKE=A --dart-define=DEMO_FIRE_IN=20
```

Windows needs Visual Studio with **Desktop development with C++**.

## Docs

| Doc | What |
| --- | --- |
| [`docs/spec.md`](docs/spec.md) | The product spec |
| [`docs/prototype.html`](docs/prototype.html) | The behavioral prototype (open in a browser) |
| [`docs/plan.md`](docs/plan.md) | Phase plan |
| [`docs/decisions.md`](docs/decisions.md) | Every non-obvious decision (D1…) |
| [`docs/progress.md`](docs/progress.md) | Status and hand-check lists |
| [`docs/rive-contract.md`](docs/rive-contract.md) | Spec for an optional Rive character |
| [`docs/release-windows.md`](docs/release-windows.md), [`docs/release-macos.md`](docs/release-macos.md) | Packaging and signing |
| [`CLAUDE.md`](CLAUDE.md) | Project rules for contributors (and Claude Code) |

Code review: the project skill [`.claude/skills/desk-buddy-review`](.claude/skills/desk-buddy-review/SKILL.md)
encodes the review checklist.

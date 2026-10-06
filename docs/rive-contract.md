# Desk Buddy — Rive character contract

This is the spec for anyone building or commissioning a Rive version of the
buddy. Drop the exported file at `assets/rive/buddy.riv` and rebuild. The app
uses it automatically, and falls back to the built-in painter if the file is
missing or doesn't load (`lib/features/buddy/ui/buddy_character.dart`).

The look of the built-in character is the reference:
`test/features/buddy/goldens/looks_x_poses.png` and `props.png`, and the
prototype's SVG in `docs/prototype.html` (`charSVG`).

## File, artboard and state machine

| Item | Value |
|---|---|
| Path | `assets/rive/buddy.riv` (Rive runtime 0.14 / `rive_native`) |
| Artboard | `Buddy`, **120 × 222** (same design space as the painter) |
| State machine | `Main` |
| Floor shadow | Inside the artboard, at the bottom, like the painter's (ellipse at y≈214) |
| Facing | Facing the viewer, walking **right** by default |

The app sizes the artboard to the buddy's width (70–220 px) with
`Fit.contain`, keeping the 120:222 ratio. Leave a little headroom above the
head for the alert hop (≈9 px in design units).

## Data binding

Make one **view model** (any name), set it as the artboard's default, and
mark a default instance as **exported**. The app binds with
`DataBind.auto()`. Property names must match exactly. Any property the file
doesn't have is skipped, so a simpler first version still works.

### Behavior

| Property | Type | Values / meaning |
|---|---|---|
| `state` | enum | `walking`, `idle`, `alert`, `dragging`, `sad` |
| `flip` | boolean | `true` while walking left. Mirror the character only; the speech bubble is drawn by the app and never flips |
| `reduceMotion` | boolean | `true` = no looping animation (OS "reduce motion"). Hold a still pose; in `alert`, keep the arm raised so it still reads as "hey!" |

What each state should look like (matching the painter, see
`lib/features/buddy/movement/buddy_pose.dart`):

| State | Motion |
|---|---|
| `walking` | Legs swing ±16° about the hips on a 1 s cycle (ease-in-out, alternating); back arm swings with the front leg; body bobs 0 → 3 px every 0.25 s |
| `idle` | Breathing: body rises 1.5 px and back over 2.4 s |
| `alert` | Hop 9 px at 30% of a 0.9 s cycle (down by 60%, rest until 100%); back arm waves between −165° and −125° |
| `dragging` | Same as idle (the app moves the buddy; feel free to add a "lifted" pose) |
| `sad` | ~3 s after the user answers "No": slumped 2.5 px lower, slow breathing (3.2 s), half-closed eyes, brows raised in the middle, a frown and a tear |
| all | Blink every 4.5 s: eyes squash to 10% height at 94–100% of the cycle |

Transitions between states may blend (≤150 ms). The app changes `state`
freely, including from `alert` straight back to `walking`.

### Look

| Property | Type | Values |
|---|---|---|
| `skin`, `hair`, `jacket`, `shirt`, `pants`, `shoes` | color | Any color the user picks. Derived shades the painter uses: lapels and the back arm = jacket darkened by 28/255 per channel; back leg = pants −12; neck = skin −10; brows = hair +10. Do them with blend/overlay layers, not extra properties |
| `hairStyle` | enum | `spiky`, `short`, `long`, `none` |
| `hat` | enum | `none`, `cap`, `beanie` (both take the jacket color; brim/band darker) |
| `spectacles` | boolean | Glasses on/off |
| `prop` | enum | `none`, `bottle`, `coffee`, `book`, `phone`, `dumbbell`, `pill`, held in the front hand |

**Props are data-driven.** The app sends the id of the prop the current
reminder asks for, from `propRegistry` in
`lib/features/buddy/render/props.dart`. When a prop is added there, add the
same value to the `prop` enum and draw it. Unknown values are sent as `none`.
The art itself must not assume what any reminder is about.

## Checklist before handing over

- [ ] Artboard `Buddy` 120×222, state machine `Main`, default view model instance exported
- [ ] All five states animate as described; blink in every state
- [ ] `flip` mirrors the character around its center
- [ ] `reduceMotion` freezes every loop
- [ ] Six colors recolor every matching part, including the derived shades
- [ ] Every enum value above exists with exactly that spelling
- [ ] Looks right at 70 px and at 220 px wide, in light and dark dashboards (transparent background)

## Notes for the developer

- Needs `rive_native`'s native libraries. `flutter run` / `flutter build`
  download them; for tests, `dart run rive_native:setup --platform windows`.
- The renderer is chosen once per window. Restart to pick up a new file.

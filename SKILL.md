---
name: keyformstudio-animation-json
version: 1.2.0
vasf: 6
app: 0.39.0
description: Generate and validate VASF JSON animations (VASF-1 to VASF-6) for import into Keyform Studio. Use when asked to create an animation JSON, a "vasf" file, a Keyform Studio / Vector Anim Studio animation, or to fix a JSON rejected by the importer.
---

# Generate VASF animation JSON

Produce ONE JSON file describing a 2D animation. The user imports it into
**Keyform Studio** (home ▸ "Import a JSON file" creates a new project; Studio ▸
Shapes ▸ "Import a VASF as instance…" inserts a skeleton into the current
project). The importer is strict and reports every problem in French with its
path.

## Start here

1. Read `references/vasf-1-format.md` — every field, default and limit.
2. Copy patterns from `references/vasf-example.json` — ONE complete animation
   that exercises every feature: element groups (v6), theme aliases, defs+ref,
   layers[], cycle, animated scaleX/scaleY, pivot, cubic-bezier, step easing,
   start/end windows, animated color, point morph, flipH/flipV, rectangle
   corners, a skeleton with IK + bend, bone `move`, and both shape and
   layer bindings. It is a single importable object.

## Core rules

- Time in **seconds**, angles in **degrees**, colors `#RRGGBB` / `#AARRGGBB`.
- Canvas origin is top-left, y grows downward, positive degrees are clockwise.
  Defaults: 720×1280, 25 fps, background `#14161C`.
- One shape = one primitive (rect, circle, line, path, triangle, star, hexagon,
  cross, heart, arrow). A character is several shapes, each bound to its bone.
- Draw order = order of the `shapes` array (first = background). `zIndex` is
  REJECTED on import.
- Shape keyframes are PARTIAL poses: an omitted property is carried from the
  previous keyframe (or the base pose). Bone keyframes do NOT carry — omitted
  `opacity`/`stretch`/`squash`/`move` fall back to neutral (1/1/1/[0,0]).
- A keyframe's `easing` is the curve of the segment ARRIVING at it: `linear`,
  `easeIn`, `easeOut`, `easeInOut` (default), `step`.
- Bone keyframe `angle` is an ABSOLUTE world angle in degrees, not a delta.
- `start`/`end` display windows are active: a shape renders only on
  `[start, end]`. Missing `end` = latest other end, else 4 s; a keyframe past
  `end` extends it. Project duration = latest end (floor 4 s).
- Alpha in `#AARRGGBB` is REPLACED by the computed opacity, not multiplied.
  Animate `opacity` for fades.
- Unknown fields are REJECTED at every level (root, canvas, shape, bone) with
  the offending path. Check spellings against the spec.
- Skeleton: parents must be declared before their children; `bind` targets
  shapes by NAME (`"Shape"` or `"Shape/Layer"`); `"bone": "Name"` on a shape is
  a whole-shape binding shortcut (conflicts with `bind` = error).

## Format versions

Set `version` to the highest extension you use; a `version: 1` file stays valid
and the importer accepts 1 to 6.

- **v2** — `"layers": [...]` packs several primitives into one shape (local
  pose per layer, `x`/`y` relative to the shape center; `x/y/rotation/scale/
  opacity` and `keyframes` remain the GROUP pose). `"theme"` palette with
  `"$alias"` colors. `"cycle": {"repeat": N}` repeats the keyframe pattern
  (period = last − first time; end on the starting pose for a clean loop).
  `"defs"` + `"ref"` define geometry once.
- **v2 axis/pivot/easing** — `scaleX`/`scaleY` are axis factors (effective
  scale = `scale` × factor; a keyframe value of 1 REPLACES the factor, it does
  not restore it). `"pivot": [dx, dy]` offsets the rotation/scale center in
  shape units and is STATIC — allowed on the SHAPE only, NEVER inside
  `layers[]` (rejected; rotation would fall back to the center). CSS easing
  `"cubic-bezier(x1, y1, x2, y2)"` with x1/x2 in [0,1]; linear identity is
  (0.333, 0.333, 0.667, 0.667), NOT (0,0,1,1).
- **v3** — animated color per keyframe: `"color": "#hex"` on a single-layer
  shape, `"colors": {"LayerName": "#hex"}` on a layered shape (the reverse is
  rejected). Point morph: `"points": [[x,y]…]` or `"layerPoints":
  {"LayerName": [[x,y]…]}`; the path interpolates point by point, a shorter
  cloud is padded by repeating its last point, and the reference frame is the
  BASE `points` list (not each keyframe's bbox, or the morph drifts) — the
  FIRST keyframe must define the starting cloud (copy the base at `t: 0`).
  Bone translation: `"move": [dx, dy]` in WORLD canvas coordinates, offset from
  the joint's rest position; children and bound pieces follow rigidly and it
  combines with `angle` on the same keyframe. IK: `ik: true` on the chain ROOT
  — dragging the last bone's tip solves the whole chain (2 bones = exact solver
  plus `bend`; ≥ 3 bones = iterative CCD, elbow side not guaranteed); the chain
  follows single-child bones and stops at the first branch.
- **v4** — `"flipH": true` / `"flipV": true` per layer (or at shape level when
  flat) mirrors the layer CONTENT around its origin; keyframes are untouched.
- **v5** — `cornerRadius` sets the shared rectangle radius (0 = square corners,
  absent = legacy automatic radius); `roundTopLeft`, `roundTopRight`,
  `roundBottomRight`, `roundBottomLeft` enable corners individually. Works flat
  and inside `layers[]`.
- **v6** — element groups: root `"groups": [{"name": "Head", "color":
  "#FF8800", "visible": true, "collapsed": false, "x": 0, "y": 0,
  "rotation": 0, "scaleX": 1, "scaleY": 1}]` plus `"groupId": "Head"` on each
  member shape. `groupId` is the group NAME, resolved after creation, so JSON
  key order is free; an unknown name is an error. A group holds no keyframes
  and no bones (its span derives from its children); `visible: false` hides all
  its shapes. Groups are flat: no nesting, one group per shape. The static
  group transform IS rendered: it wraps each shape's pose and rotates/scales
  around the group's VISUAL CENTRE (mean of its children's rest positions), not
  the canvas origin; a neutral group renders exactly like ungrouped shapes.
- Bone objects may embed their own `"keyframes"` and `"cycle"` (the `bone`
  field is then implied). A bone with its own cycle is excluded from the global
  `skeleton.cycle`, so different bones can run different periods.

## Gotchas

- Path inside `layers[]`: `points` are recentered on the layer origin — place
  the path with the layer's `x`/`y` (e.g. a smile: `y` = vertical center of its
  bbox).
- A bone keyframe carrying only `t` resets opacity/stretch/squash to neutral —
  always give `angle` to animate a bone.
- Layer local pose (`x/y/rotation/scale/opacity` in `layers[]`) is static: only
  the group pose, layer COLORS and layer POINTS animate. `pivot` is not
  animatable. `ref` works at shape level only, not inside `layers[]`.
- No nested project instances.

## Workflow

1. **Design** — pick canvas, duration, shapes and timeline. Falling → `easeIn`,
   rising/relaunch → `easeOut`, hard stop → `step`, otherwise `easeInOut`.
   Squash & stretch: `scale`, or independent `scaleX`/`scaleY` (ground impact =
   `scaleX > 1` + `scaleY < 1`). Rotation around an edge → `pivot` on the shape
   (e.g. a door: `[-width/2, 0]`).
2. **Write** the JSON to a scratch path with a descriptive name. One root
   object only.
3. **Validate** — `python3 scripts/validate_vasf.py <file>.json`. Fix every
   error; re-read warnings (auto-rename, scale/axis factors outside 0.05–4,
   oversized pivot, elastic bezier y, morph starting after t ≈ 0).
4. **Preview** — `python3 scripts/preview_vasf.py <file>.json [t1 t2 ...]
   [--bones] [--pick KEY]` renders with the same formulas as the app engine
   (verified against the official harness, diff < 1/255). Output:
   `tmp/vasf_preview/<name>/planche.png` (side-by-side) plus full-resolution
   `frame_t*.png` for pixel measurements. Without instants it samples 5 points
   over the content duration; `--bones` overlays the rig; `--pick` selects an
   object from a collection. Read the board and check composition, positions
   and morph. Exit codes: 0 = OK, 1 = parse errors, 2 = fatal.
5. **Deliver** the `.json` file itself. If the app rejects it, the "Import
   impossible" dialog lists the errors with paths — fix and resend.

## Animation tips

- Bouncing ball: alternate `easeIn` (fall) / `easeOut` (rise), squash on the
  ground with `scale` over 1–2 keyframes.
- Character: shapes at rest, bones at the joints, `bind` shape → bone; animate
  with world-angle bone keyframes (elbow at rest 100° → keyframe `angle: 150`).
- IK: enable `ik` on the chain ROOT (shoulder); `bend` picks the elbow side on
  2-bone chains.
- Stay readable: few shapes, short durations (2–8 s), 2–4 keyframes per
  property.

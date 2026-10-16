# Tileh Bazi: Marbles Game

An independent Espadna 3D marbles game, built with **Godot 4.5.1 / GDScript / Compatibility renderer**. Native iOS and Android are the product targets; browser and Windows builds are available for prototype review.

**Current milestone: M1 physical offline prototype, with early M2 features. This is not production art or a finished mobile release.**

## Play locally

Open `project.godot` in Godot **4.5.1 Standard**, then press F6/F5, or:

```sh
godot --path .
```

Pull backward near your marble and release. Pull farther for more power. Drag onto the circular × zone to cancel. Mouse and touch share the same input logic. The actual shot comes from the animated thumb; there is no slingshot.

The menu defaults to Persian; English, Arabic and Hindi are available. Settings include hand style, skin tone, sound, mobile haptics and a low graphics option. The aiming camera is fixed. Reduced motion is on by default; turning it off permits a restrained lateral camera follow during shots.

## Implemented

- Wall precision: physical rebounds and opponent collisions, surface distance scoring, independent 3/2 point categories, five rounds, alternating starters, paired extra rounds.
- Square knockout: six target marbles, physical collisions, complete-line exit collection, one shot per turn, empty-board completion and draws.
- Real-shaped qualifying hole and paired shots to choose the first player.
- One-device two-player handoff and labeled offline computer opponent at three heuristic difficulty levels.
- Uneven collision terrain, stable soft/hard patches, rolling resistance, original synthesized rolling/impact sounds, out-of-bounds and timeout recovery.
- Replaceable procedural hand, glass shells and colored internal ribbons, native and WebAssembly builds.
- Seven destination entries; **only Isfahan dirt is playable in this first slice**. Other landmark blockouts are previews marked as in preparation.

No account, online matchmaking, purchases or advertising SDKs are installed. The online entry is explicitly marked as future work.

## Checks

```sh
godot --headless --editor --path . --import --quit
godot --headless --path . --script res://tests/run.gd --fixed-fps 120
godot --headless --path . --script res://tests/integration.gd --fixed-fps 120
```

The first suite uses real rigid-body simulation, not only mocked coordinates. The integration suite runs the actual gameplay controller through shots, recovery, handoff, the qualifying hole, a wall match and AI turns. See `docs/VALIDATION.md` for observed results and limitations.

## Exports

Install Godot's matching **4.5.1** export templates. Create the output directories first.

```sh
godot --headless --path . --export-release Web build/web/index.html
godot --headless --path . --export-release Windows build/windows/TilehBazi.exe
node tools/serve.mjs
```

The web preview opens at `http://127.0.0.1:4173`. Serve it over HTTP; double-clicking the HTML file cannot load WebAssembly correctly. Node is needed only for this small local preview server, not the game itself. Release artifacts from CI contain the executable/web files; they are not committed to Git.

For mobile, see `docs/DELIVERY.md`. No mobile performance or store-readiness claim is made from desktop checks.

## Documentation

- `docs/RULES.md`: final scope, scoring and provisional edge cases.
- `docs/ARCHITECTURE.md`: engine decision, audit and future server authority.
- `docs/ASSETS.md`: original assets, sources and licenses.
- `docs/VALIDATION.md`: tests and actual tested platforms.
- `docs/DELIVERY.md`: build/release process and remaining platform setup.

No production deployment is triggered by this repository's prototype CI. Public deployment and store submission require the owner's explicit release approval.

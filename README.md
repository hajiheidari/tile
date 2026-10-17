## v0.3 gameplay revision

Each new match uses a fresh, shared seeded terrain. Shape and resistance stay fixed throughout the match so players can learn and respond to the ground. Use **Move marble**, tap the turquoise launch area, then **Ready to aim** before pulling back to shoot. Placement is optional; the default position still works. Moving does not use a turn.

The current graphics remain an open issue following user feedback. This revision focuses on real terrain variation and player-controlled launch positions; it is not final art approval.

# Tileh Bazi: Marbles Game

An independent Espadna 3D marbles game, built with **Godot 4.5.1 / GDScript / Compatibility renderer**. Native iOS and Android are the product targets; browser and Windows builds are available for prototype review.

**Current milestone: M1 physical offline prototype, with early M2 features. This is not production art or a finished mobile release.**

### v0.2 — graphics and shot-control revision

- Replaced the old physics solver with built-in Jolt and tuned small-scale contact tolerances/internal-edge handling.
- Reduced terrain gradients and soft/hard differences. The seven-lane straight-shot regression now caps lateral deviation at 2 cm; the Windows reference maximum is 1.70 cm, versus 24.72 cm in v0.1 under the same scenario.
- Corrected perspective aiming: diagonal screen guides now match physical shot direction. Improved camera framing leaves room to pull backward.
- Rebuilt the hand from continuous meshes, grounded its supporting fingertip and aligned the thumb/hand with the chosen shot.
- Added volume-style glass/refraction, contact shadows, a packed-dirt texture and a detailed distant architectural matte painting integrated with 3D ground, trees, terrace and pool. The distant painting is deliberately 2D, not an authored 3D building model.

This remains a work in progress; these improvements are not a claim that the approved concept's final art quality has been achieved.

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
- Gently shaped collision terrain, mild soft/hard patches, rolling resistance, original synthesized rolling/impact sounds, out-of-bounds and timeout recovery.
- Replaceable continuous-mesh hand, volume-style colored glass, native and WebAssembly builds.
- Seven destination entries; **only Isfahan dirt is playable in this first slice**. Other landmark blockouts are previews marked as in preparation.

No account, online matchmaking, purchases or advertising SDKs are installed. The online entry is explicitly marked as future work.

## Checks

```sh
godot --headless --editor --path . --import --quit
godot --headless --path . --script res://tests/run.gd --fixed-fps 120
godot --headless --path . --script res://tests/integration.gd --fixed-fps 120
godot --headless --path . --script res://tests/control.gd --fixed-fps 120
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

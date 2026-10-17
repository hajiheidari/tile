# Architecture and audit

## Engine decision

Godot **4.5.1 Standard**, GDScript, built-in **Jolt Physics**, 120 Hz physics and the Compatibility renderer. A real 3D engine supplies contact solving, sphere collisions, mesh collision, articulated transforms and native platform exports. Compatibility also supports the browser's WebGL 2 renderer. We deliberately avoid C# because Godot 4's standard web export is not the .NET path.

v0.1 used GodotPhysics3D. User playtesting exposed excessive lateral deflection. v0.2 uses Jolt's enhanced internal-edge removal, small-marble contact tolerances and a much gentler heightfield. This is a solver/terrain correction, not an invisible post-release steering correction. The old baseline's seven-lane maximum was 24.72 cm; the revised Windows run was 1.70 cm. The two solvers are not assumed to produce interchangeable trajectories.

Godot was absent from PATH at audit time. Its official Windows binary and matching export templates were obtained from Godot's official distribution, then actually used. The detected machine has Intel HD Graphics 4600; Godot selected ANGLE due to the driver's OpenGL limitations. No Unity, Android SDK, adb, JDK or .NET toolchain was detected on PATH.

Reference docs: https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_web.html and https://docs.godotengine.org/en/4.5/classes/class_rigidbody3d.html

## Existing repositories inspected

- `hajiheidari/tile`: empty repository at audit, default branch reported as main; connector confirmed push permission. No existing code, README or AGENTS.md.
- `hajiheidari/espadna-site`: studio marketing pages, Cloudflare configuration, documented GitHub Actions deployment. Each app owns its web build and subdomain. Do not change or deploy this unrelated site during the prototype.
- `hajiheidari/crowns-app`: Expo 57 / React Native 0.86 app; EAS development, preview, production and Bazaar profiles; independent app identifiers, EAS project and Cloudflare static config. No `.github/workflows` entry in its inspected main tree. EAS submit profile alone does not prove a successful TestFlight submission. Native wrappers and SDKs are not copied into this game.

Repository secret values were not requested or printed. Their existence does not prove platform signing or Cloudflare permission validity. No third-party app identifier, signing key or EAS project identifier is reused.

## Separation

- `rules.gd`: pure state, match totals, exclusive scoring, full-line collection.
- `terrain.gd`: versioned analytic heightfield, triangulated once for both visible mesh and static collision; qualifier adds a physical bowl.
- `marble.gd`: common legal physics body, impulse, contact sound, rolling resistance and safe reset in `_integrate_forces`.
- `gesture.gd`: one-pointer drag/release, maximum power, cancellation and no shot outside the shooter hit area. The controller unprojects its screen guide onto the launch plane so perspective diagonals remain accurate.
- `art.gd` / `geometry.gd`: original continuous hand meshes, decorative meshes and a distant landmark matte painting. The matte is a flat image behind the actual 3D playable environment; no physics parameters depend on cosmetics.
- `locale.gd`: four languages and explicit RTL flag, bundled OFL fonts.
- `main.gd`: local lifecycle, tutorial cards, qualifier, handoff, AI planning and results. Async lifecycle tokens prevent an old shot callback from mutating a new match.

The AI commits direction and power before its shot, integrates the known resistance along a path and applies difficulty-specific error. Hard can aim at an opponent near the wall. It uses the same rigid body and impulse limits. It is **an early heuristic**, not yet a full multi-candidate forward physics planner with robust rebound optimization.

## Future online authority — not implemented

Use a separately deployed **headless Godot match simulation**, pinned to the same engine/match/terrain versions. Client messages contain only participant identity, match ID, monotonically increasing command ID, expected turn, direction and power. The server validates finite values, normalization, power range, turn/phase, rate limits and version. It never accepts client scores or settled coordinates.

The server simulates shots and sends motion samples plus authoritative final states. Clients render/interpolate these; they do not assume cross-device floating-point determinism. Maintain command deduplication, reconnection tokens, monotonic state sequence, turn timer, disconnect grace period, forfeits, human-only ranked results and explicit unranked bot fallback after a configurable queue timeout.

Cloudflare static hosting can serve the web build, but it does **not** run the native headless physics engine. A suitable simulation host must be selected and tested before calling online mode functional. No paid host has been purchased, and no local simulation is labeled online multiplayer.

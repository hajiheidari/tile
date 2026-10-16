# Validation — 2026-10-17 (Asia/Tehran)

## Executed

- Godot **4.5.1**, Windows desktop, built-in GodotPhysics3D, Compatibility/ANGLE on Intel HD Graphics 4600.
- Engine import/parse and runtime startup.
- **96 checks passed** in the rules/physics/localization suite: independent wall categories, contact/handspan boundaries, ties, radius-correct distance, second-shot displacement scoring, five-round totals, paired overtime, full-square exits, capture deduplication, turn consumption, gesture direction/power/cancel, all four-language key coverage, ground support, stopping resistance, physical opponent displacement, soft vs hard travel, cross-slope deflection, wall rebound, recovery and physical qualifying bowl.
- **10 integration checks passed** in the actual controller: square turn handoff, out-of-bounds recovery, ten physical shots of a wall match, match/overtime resolution, a labeled AI shot and paired qualifying shots.
- Actual WebAssembly export succeeded and served HTTP 200 using the local server. Browser was opened, Persian UI/RTL observed, qualifying tutorial started and drag/release fired a real shot. No browser error/warning logs at the observed point.
- Native rendered screenshots captured for menu, square, wall and Persian UI; initial lighting/line rendering issues were found and corrected.
- Windows x86_64 embedded-PCK export succeeded.

## Limits / remaining work

- This is a physical gameplay prototype with early offline features. Final authored character/landmark meshes, polished glass/refraction, final audio, terrain texture art, visual tutorials and mobile performance tuning remain.
- Six destinations are registered previews with procedural landmark blockouts and are explicitly blocked from starting a match; only Isfahan dirt is in the tested slice.
- Localization key coverage is not linguistic approval. Persian/Arabic/Hindi fonts are bundled, but native-speaker review and more device-size/RTL visual checks remain.
- Native shutdown can log an ObjectDB leak warning from pending async/UI resources in test teardown; investigate before release. Tests reported no remaining assertion failures.
- No complete manual AI match, exhaustive phone gestures, real touch/haptics, Android, iOS, TestFlight, production deployment, online authority or reconnect tests have been completed.
- No final production graphics or App Store readiness is claimed.

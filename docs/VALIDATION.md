# Validation — 2026-10-17 (Asia/Tehran)

## Executed

- Godot **4.5.1**, Windows desktop, built-in GodotPhysics3D, Compatibility/ANGLE on Intel HD Graphics 4600.
- Engine import/parse and runtime startup.
- **96 checks passed** in the rules/physics/localization suite: independent wall categories, contact/handspan boundaries, ties, radius-correct distance, second-shot displacement scoring, five-round totals, paired overtime, full-square exits, capture deduplication, turn consumption, gesture direction/power/cancel, all four-language key coverage, ground support, stopping resistance, physical opponent displacement, soft vs hard travel, cross-slope deflection, wall rebound, recovery and physical qualifying bowl.
- **13 integration checks passed** in the actual controller: square turn handoff, out-of-bounds recovery, ten physical shots of a wall match, match/overtime resolution, a labeled AI shot, paired qualifying shots and a complete planner-driven square match with legal scoring. In the Windows reference run that square match collected all six targets in 75 shots (5:1). This slow completion makes AI tuning a known next-milestone task, not a production-ready feature.
- Actual WebAssembly export succeeded and served HTTP 200 using the local server. Browser was opened, Persian UI/RTL observed, qualifying tutorial started and drag/release fired a real shot. No browser error/warning logs at the observed point.
- Native rendered screenshots captured for menu, square, wall, Persian, Arabic and Hindi UI; initial lighting/line rendering issues and an Arabic minimum-width overflow were found and corrected. Final phone/device review remains.
- Windows x86_64 embedded-PCK export succeeded and the exported executable passed a headless startup smoke check.

## Limits / remaining work

- This is a physical gameplay prototype with early offline features. Final authored character/landmark meshes, polished glass/refraction, final audio, terrain texture art, visual tutorials and mobile performance tuning remain.
- Six destinations are registered previews with procedural landmark blockouts and are explicitly blocked from starting a match; only Isfahan dirt is in the tested slice.
- Localization key coverage is not linguistic approval. Persian/Arabic/Hindi fonts are bundled, but native-speaker review and more device-size/RTL visual checks remain.
- A looping-audio resource warning in headless test teardown was resolved by not starting an audio loop on the headless driver. The final integration run exited without that warning or assertion failures.
- The complete planner-driven match was automated in the real engine; it is not a manual human-vs-AI playtest. No exhaustive phone gestures, real touch/haptics, Android, iOS, TestFlight, production deployment, online authority or reconnect tests have been completed.
- No final production graphics or App Store readiness is claimed.

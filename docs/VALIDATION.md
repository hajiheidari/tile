# v0.4 — hand removed; explicit placement confirmation

- Removed the hand geometry, hand animation and hand customization UI from the active project.
- Human turns start in placement mode; mouse motion and touch drag reposition continuously. Only the confirmation button enters aiming. Gesture-level and controller-level guards reject accidental shots during placement. A smaller 65-pixel aiming hit area prevents distant touches from starting a shot.
- Placement tests cover default state, blocked shot, continuous drag, no automatic mode transition, bounds/overlap, stationary placement and launch after confirmation.
- Power is displayed by two circular contact markers and a growing power arc; there is no hand or slingshot graphic.

---

# v0.3 — variable ground and placement (2026-10-17)

- A fresh nonzero seed is generated when starting each new match through the qualifying flow. It remains fixed through that match, shared by both players. There is no random impulse or aim error. Eighteen broad bumps/depressions change mesh vertices and the actual collision surface, with local soil resistance from the same seed. The height offsets are millimetres over 10–26 cm patches, not decorative shader displacement.
- Same 1.2 m/s shot on six fixed seeds produced endpoints up to **12.69 cm** apart. Repeating a seed is tested separately for consistent outcomes. This demonstrates variation, not that every possible power/position is equally difficult.
- Launch placement works in both modes inside x = ±0.65 m, z = 0.72–1.07 m. Qualifying placement stays on the one-metre line with a finger-size snap zone. Overlaps and outside clicks are rejected. Placement consumes no shot. Active marble is held still while choosing/aiming, then participates in ordinary physics when released.
- **99** rules/locale/physics checks, **17** controller checks and **8** placement/terrain assertions passed on Windows Jolt. Six-seed physical variation test passed. Existing seven-lane test describes the seed-zero calibration surface, not the live randomized ground.
- Soil coloration now follows the local resistance field; surface detail is reduced for a more illustrated look. **The user has rejected the current overall graphics. That issue is still open.** These material changes do not constitute a completed replacement for the hand, environment art and animation.
- Web preview is rebuilt locally. Phone touch/haptics and production mobile performance remain untested.

---

# Validation — 2026-10-17 (Asia/Tehran)

## Executed

- Godot **4.5.1**, Windows desktop, built-in **Jolt Physics** for v0.2, Compatibility/ANGLE on Intel HD Graphics 4600. The archived v0.1 reference used GodotPhysics3D.
- Engine import/parse and runtime startup.
- **96 checks passed** in the rules/physics/localization suite: independent wall categories, contact/handspan boundaries, ties, radius-correct distance, second-shot displacement scoring, five-round totals, paired overtime, full-square exits, capture deduplication, turn consumption, gesture direction/power/cancel, all four-language key coverage, ground support, stopping resistance, physical opponent displacement, soft vs hard travel, cross-slope deflection, wall rebound, recovery and physical qualifying bowl.
- **17 integration checks passed** in the actual controller, including four perspective guide/direction checks, square turn handoff, out-of-bounds recovery, ten physical shots of a wall match, a labeled AI shot and paired qualifying shots. The same seeded complete square simulation that needed 75 shots in v0.1 collected all six targets in **13 shots (3:3)** in v0.2. This automated scenario is not a broad human-vs-AI skill evaluation.
- **7 straight-shot lane checks passed**: 1.2 m/s launch, same sphere, six seconds simulated settling, each lane evaluated separately. Maximum lateral deviation decreased from **24.72 cm to 1.70 cm**. Revised forward travel across lanes was **83.51–86.97 cm**. The mild soft-vs-hard patch scenario differed by **2.81 cm**. Regression limit is 2 cm lateral deviation; do not relax it to hide a failure.
- Actual WebAssembly export succeeded and served HTTP 200 using the local server. Browser was opened, Persian UI/RTL observed, qualifying tutorial started and drag/release fired a real shot. No browser error/warning logs at the observed point.
- Native rendered screenshots captured for menu, square, wall, Persian, Arabic and Hindi UI; initial lighting/line rendering issues and an Arabic minimum-width overflow were found and corrected. Final phone/device review remains.
- Windows x86_64 embedded-PCK export succeeded and the exported executable passed a headless startup smoke check.

## Limits / remaining work

- This is a gameplay/visual revision with early offline features. It now uses a modeled near field with an explicit 2D distant landmark painting and textured soil. Full 3D landmark assets, final hand anatomy/animation, final audio, visual tutorials and mobile performance tuning remain. It is not claimed to match the approved concept's final production quality.
- Six destinations are registered previews with procedural landmark blockouts and are explicitly blocked from starting a match; only Isfahan dirt is in the tested slice.
- Localization key coverage is not linguistic approval. Persian/Arabic/Hindi fonts are bundled, but native-speaker review and more device-size/RTL visual checks remain.
- A looping-audio resource warning in headless test teardown was resolved by not starting an audio loop on the headless driver. The final integration run exited without that warning or assertion failures.
- The complete planner-driven match was automated in the real engine; it is not a manual human-vs-AI playtest. No exhaustive phone gestures, real touch/haptics, Android, iOS, TestFlight, production deployment, online authority or reconnect tests have been completed.
- No final production graphics or App Store readiness is claimed.

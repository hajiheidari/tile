# Rules — offline-v2

Owner-approved launch scope is **Wall precision and Square knockout only**. Triangle, hole course and the uncertain two-marble collection variant are deferred. Do not reintroduce coin toss or rock-paper-scissors.

## Common

Exactly two participants. Each cosmetic is visual only: every marble uses the same radius, mass, friction and maximum impulse. One shot per turn. Actual gravity, terrain contacts and marble collisions determine outcomes. There is no random steering or post-release AI correction.

World units are metres. Prototype marble radius is **0.025 m**, mass **0.020 kg**; the slightly oversized silhouette is a tunable readability choice, not a claim of final real-world proportions. Maximum launch speed is **3.3 m/s**.

All marbles settle below 0.025 m/s for 0.65 seconds before results are evaluated. The timeout is 14 simulated seconds. Boundaries are x ±1.16 m, z ±1.40 m. A shot that sends **any marble** out of bounds, or times out, consumes the turn and restores the entire pre-shot position snapshot; no captures are awarded. This whole-shot rollback is a provisional anti-exploit extension of the requested shooter recovery rule.

## First player

A real hole with a 9 cm rim radius and 4.5 cm depth is formed in the terrain. Each player shoots from the marked one-metre line. Distances are measured after both settle, using final positions including displacement. Closest outer surface to the hole edge starts. Marbles resting within the opening have zero distance; ties within 2 mm replay with alternate qualifying starter. Qualified marbles are cleared before the main match.

The 16 cm line is drawn as a reference mark only; its further purpose was not confirmed. Hole radius/depth, distance convention, collision treatment and tie handling here are explicit provisional digital defaults. They are not additional playable hole-course rules.

## Wall

Wall playing surface z = −1.0 m. Launch line z = +1.0 m. Each participant shoots once per round. Both shots and all movement finish before scoring; the second shot can change the first player's final position.

- Surface-to-wall distance ≤ 3 mm: 3 points.
- Otherwise distance ≤ 20 cm: 2 points.
- Each participant earns these categories independently; never 3+2.
- Only when both are farther than 20 cm does the closer marble earn 1 point and the other 0.
- Far-distance ties within 2 mm give both 1 point.

Marbles reset each round. The starter alternates. Highest total after five rounds wins; equal totals continue in complete paired-shot rounds until unequal.

## Square

Each player contributes three marbles to the initial six-marble square; each has a separate shooter. Square half-width is 0.32 m. A target is collectible only after it settles with its entire sphere outside at least one edge; touching/overlapping the chalk line is insufficient. Collected IDs cannot score twice. Transient exits that return inside before settling do not score.

Collected targets belong to the person who made the shot, regardless of initial contribution. The separate shooters cannot be collected. Shooter/opponent collisions remain enabled. Before a square turn the current shooter's marble returns to a marked launch spot; the opponent's shooter remains on the field. This shooter placement and the 0.94 m launch z are provisional digital rules.

A successful shot still passes the turn. Empty square ends the match; most collected wins, equal totals draw. To recover a stalled game, an explicit provisional cap of 80 turns compares collected totals and allows a draw. The cap will need playtesting before ranked play.

## Surfaces and locations

The first playable map is handcrafted `isfahan-packed-dirt-v2`: a packed, gently shaped patch with a maximum analytic gradient around 0.065 degrees. Terrain affects control subtly: the soft patch increases modeled rolling resistance by at most 12%, and the hard patch reduces it by at most 6%. The launch regression measures physical lateral drift across seven lanes and requires each to remain within 2 cm. Visual fine-grain texture is surface detail, not a collection of large hidden bumps. The qualifying bowl remains a real depression. Identical conditions apply to both participants. Other six locations are registered previews and cannot start a match in this milestone.

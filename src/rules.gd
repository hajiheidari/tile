extends RefCounted
## Pure match rules. World units are metres; distances use sphere surfaces.
const RADIUS: float = 0.025
const HANDSPAN: float = 0.20
const CONTACT_TOLERANCE: float = 0.003
const TIE_TOLERANCE: float = 0.002
const WALL_Z: float = -1.0
const SQUARE_HALF: float = 0.32
const MAX_SHOT_SPEED: float = 3.3
const TERRAIN_VERSION: String = "isfahan-dirt-v1"
const MATCH_VERSION: String = "offline-v1"

var mode: String = "square"
var scores: Array[int] = [0, 0]
var round_number: int = 1
var starter: int = 0
var current: int = 0
var shots_in_round: int = 0
var total_shots: int = 0
var finished: bool = false
var winner: int = -1
var captured_ids: Array[int] = []

func start(game_mode: String, first: int = 0) -> void:
	mode = game_mode
	scores = [0, 0]
	round_number = 1
	starter = first
	current = first
	shots_in_round = 0
	total_shots = 0
	finished = false
	winner = -1
	captured_ids.clear()

static func wall_distance(center: Vector3) -> float:
	return maxf(0.0, center.z - WALL_Z - RADIUS)

static func wall_points(distances: Array) -> Array[int]:
	var result: Array[int] = [0, 0]
	for p in range(2):
		if distances[p] <= CONTACT_TOLERANCE:
			result[p] = 3
		elif distances[p] <= HANDSPAN:
			result[p] = 2
	if distances[0] > HANDSPAN and distances[1] > HANDSPAN:
		if absf(distances[0] - distances[1]) <= TIE_TOLERANCE:
			result = [1, 1]
		elif distances[0] < distances[1]:
			result[0] = 1
		else:
			result[1] = 1
	return result

static func completely_outside_square(pos: Vector3) -> bool:
	return absf(pos.x) - RADIUS > SQUARE_HALF or absf(pos.z) - RADIUS > SQUARE_HALF

static func out_of_bounds(pos: Vector3) -> bool:
	return absf(pos.x) > 1.16 or pos.z > 1.40 or pos.z < -1.40 or pos.y < -0.30

func finish_wall_shot(final_positions: Array) -> Dictionary:
	if finished:
		return {}
	total_shots += 1
	shots_in_round += 1
	if shots_in_round < 2:
		current = 1 - current
		return {"round_complete": false}
	var distances: Array = [wall_distance(final_positions[0]), wall_distance(final_positions[1])]
	var points: Array[int] = wall_points(distances)
	scores[0] += points[0]
	scores[1] += points[1]
	if round_number >= 5 and scores[0] != scores[1]:
		finished = true
		winner = 0 if scores[0] > scores[1] else 1
	var result := {"round_complete": true, "distances": distances, "points": points, "round": round_number}
	if not finished:
		round_number += 1
		starter = 1 - starter
		current = starter
		shots_in_round = 0
	return result

func finish_square_shot(exited_ids: Array[int], remaining: int) -> int:
	if finished:
		return 0
	var gained: int = 0
	for id in exited_ids:
		if id not in captured_ids:
			captured_ids.append(id)
			gained += 1
	scores[current] += gained
	total_shots += 1
	# Explicit safety cap: 80 shots then compare captured counts; equal scores draw.
	if remaining == 0 or total_shots >= 80:
		finished = true
		winner = -1 if scores[0] == scores[1] else (0 if scores[0] > scores[1] else 1)
	else:
		current = 1 - current
	return gained

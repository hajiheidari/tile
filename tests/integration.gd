extends SceneTree
const Main = preload("res://src/main.gd")
var game: Node3D
var failures: int = 0
var checks: int = 0

func check(value: bool, message: String) -> void:
	checks+=1
	if not value:
		failures+=1
		push_error("FAIL: "+message)
	else: print("PASS: ",message)

func _initialize() -> void:
	run.call_deferred()

func frames(n: int) -> void:
	for i in range(n): await physics_frame

func wait_for_shot() -> void:
	for i in range(2200):
		await physics_frame
		if game.phase in ["handoff","result","finished"]: return
	check(false,"shot reaches a visible result before its timeout")

func run() -> void:
	game=Main.new()
	root.add_child(game)
	game.sound.enabled=false
	game.against_ai=false
	game.selected_mode="square"
	game.start_match(0)
	await frames(30)
	check(game.phase=="aim","square match enters aiming state")
	game.human_shot(Vector2(0,-1),0.40)
	await wait_for_shot()
	check(game.rules.total_shots==1 and game.rules.current==1,"real square shot settles and passes turn to opponent")
	check(game.phase=="handoff","same-device handoff is visible")
	game.prepare_turn()
	await frames(30)
	game.human_shot(Vector2(1,0),1.0)
	await wait_for_shot()
	check(game.rules.total_shots==2 and game.rules.current==0,"out-of-bounds shot consumes exactly one turn")
	check(game.shooters[1].position.z>0.85 and absf(game.shooters[1].position.x)<0.2,"out-of-bounds shot restores launch position")
	game.selected_mode="wall"
	game.start_match(0)
	await frames(30)
	for i in range(10):
		if game.phase != "aim": game.prepare_turn()
		await frames(5)
		game.human_shot(Vector2(0,-1),0.23 if i%2==0 else 0.03)
		await wait_for_shot()
		if i%2==1 and not game.rules.finished:
			game.reset_wall_round()
			await frames(4)
	check(game.rules.total_shots==10,"complete wall match physically executes ten shots")
	check(game.rules.finished or game.rules.round_number==6,"five physical rounds finish or correctly enter extra time")
	game.against_ai=true
	game.start_match(1)
	await wait_for_shot()
	check(game.rules.total_shots==1 and game.rules.current==0,"labeled computer opponent performs a real legal shot")
	game.against_ai=false
	game.start_qualifier()
	game.prepare_turn()
	await frames(10)
	game.human_shot(Vector2(0,-1),0.15)
	await wait_for_shot()
	check(game.qualifier_shots==1,"first-player qualifier uses a real shot")
	game.prepare_turn()
	await frames(10)
	game.human_shot(Vector2(0,-1),0.03)
	await wait_for_shot()
	check(game.qualifier_shots==2 and game.phase=="result","qualifier resolves only after paired shots")
	print("INTEGRATION RESULT: ",checks," checks, ",failures," failures")
	await frames(120)
	game.queue_free()
	await frames(3)
	quit(1 if failures else 0)

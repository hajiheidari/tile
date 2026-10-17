extends SceneTree
const Main=preload("res://src/main.gd")
const Terrain=preload("res://src/terrain.gd")
var failures: int=0
func _initialize() -> void: run.call_deferred()
func check(ok: bool,message: String) -> void:
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures+=1
func frames(n: int) -> void:
	for i in range(n): await physics_frame
func run() -> void:
	var a=Terrain.new()
	var b=Terrain.new()
	a.configure(12345)
	b.configure(12345)
	var difference: float=0
	var spread: float=0
	for x in range(-10,11):
		for z in range(-10,11):
			check_same(a.ground_height(x*0.1,z*0.1)==b.ground_height(x*0.1,z*0.1))
	b.configure(67890)
	for x in range(-10,11):
		for z in range(-10,11):
			difference=maxf(difference,absf(a.ground_height(x*0.1,z*0.1)-b.ground_height(x*0.1,z*0.1)))
			spread=maxf(spread,absf(a.ground_height(x*0.1,z*0.1)))
	check(difference>0.002,"new seed changes real terrain by millimetres")
	check(spread>0.002 and spread<0.02,"surface has bounded physical relief")
	a.free()
	b.free()
	var game=Main.new()
	root.add_child(game)
	game.against_ai=false
	game.sound.enabled=false
	game.match_seed=12345
	game.start_match(0)
	await frames(30)
	var shots: int=game.rules.total_shots
	game.toggle_placement()
	var target:=Vector3(-0.40,0,0.84)
	game.place_shooter(game.camera.unproject_position(target))
	await frames(10)
	check(Vector2(game.shooters[0].position.x,game.shooters[0].position.z).distance_to(Vector2(-0.40,0.84))<0.01,"player can choose a launch position")
	var before: Vector3=game.shooters[0].position
	game.place_shooter(game.camera.unproject_position(Vector3(0,0,0)))
	check(game.shooters[0].position.distance_to(before)<0.001,"placement outside launch area rejected")
	game.place_shooter(game.camera.unproject_position(Vector3(game.shooters[1].position.x,0,game.shooters[1].position.z)))
	check(game.shooters[0].position.distance_to(before)<0.001,"placement on another marble rejected")
	await frames(120)
	check(game.shooters[0].position.distance_to(before)<0.001,"selected marble stays still before launch")
	check(game.rules.total_shots==shots,"placement consumes no shot")
	game.toggle_placement()
	game.human_shot(Vector2(0,-1),0.5)
	await frames(100)
	check(game.shooters[0].position.distance_to(before)>0.1,"release launches from selected position")
	game.queue_free()
	await frames(5)
	quit(1 if failures else 0)
func check_same(ok: bool) -> void:
	if not ok: failures+=1

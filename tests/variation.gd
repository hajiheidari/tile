extends SceneTree
const Terrain=preload("res://src/terrain.gd")
const Marble=preload("res://src/marble.gd")
var results: Array[Vector3]=[]
func _initialize() -> void: run.call_deferred()
func frames(n: int) -> void:
	for i in range(n): await physics_frame
func run() -> void:
	for seed_value in [101,202,303,404,505,606,101]:
		var world:=Node3D.new()
		root.add_child(world)
		var terrain=Terrain.new()
		terrain.configure(seed_value)
		world.add_child(terrain)
		var marble=Marble.new()
		marble.ground=terrain
		marble.position=Vector3(-0.10,terrain.height(-0.10,0.94)+0.027,0.94)
		world.add_child(marble)
		await frames(60)
		marble.apply_central_impulse(Vector3(0,0,-1.2)*marble.mass)
		await frames(720)
		results.append(marble.position)
		print("SEED ",seed_value," endpoint ",marble.position)
		world.queue_free()
		await frames(3)
	var spread: float=0
	for a in results:
		for b in results: spread=maxf(spread,Vector2(a.x,a.z).distance_to(Vector2(b.x,b.z)))
	print("SAME SHOT DIFFERENT GROUNDS spread metres=",spread)
	var repeat_error: float=results[0].distance_to(results[-1])
	print("REPEAT SAME SEED error metres=",repeat_error)
	quit(0 if spread>0.015 and spread<0.50 and repeat_error<0.001 else 1)

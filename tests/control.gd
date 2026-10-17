extends SceneTree
const Terrain=preload("res://src/terrain.gd")
const Marble=preload("res://src/marble.gd")
var failed: bool=false
var checks: int=0
var maximum_drift: float=0
var shortest_range: float=INF
var longest_range: float=0

func _initialize() -> void:
	run.call_deferred()

func frames(n: int) -> void:
	for i in range(n): await physics_frame

func run() -> void:
	for lane in [-0.75,-0.50,-0.25,0.0,0.25,0.50,0.75]:
		var world:=Node3D.new()
		root.add_child(world)
		var terrain=Terrain.new()
		world.add_child(terrain)
		var marble=Marble.new()
		marble.position=Vector3(lane,Terrain.height_at(lane,0.8)+0.027,0.8)
		world.add_child(marble)
		await frames(60)
		var start: Vector3=marble.position
		marble.apply_central_impulse(Vector3(0,0,-1.2)*marble.mass)
		await frames(720)
		var drift: float=absf(marble.position.x-start.x)
		var distance: float=start.z-marble.position.z
		maximum_drift=maxf(maximum_drift,drift)
		shortest_range=minf(shortest_range,distance)
		longest_range=maxf(longest_range,distance)
		checks+=1
		var valid: bool=drift<=0.02 and distance>0.60 and distance<1.70 and marble.linear_velocity.length()<0.03
		failed=failed or not valid
		print("CONTROL lane=",lane," drift_cm=",snappedf(drift*100,0.01)," range_cm=",snappedf(distance*100,0.01)," ","PASS" if valid else "FAIL")
		world.queue_free()
		await frames(3)
	print("CONTROL RESULT: ",checks," lanes; max drift_cm=",snappedf(maximum_drift*100,0.01)," range_cm=",snappedf(shortest_range*100,0.01),"..",snappedf(longest_range*100,0.01))
	quit(1 if failed else 0)

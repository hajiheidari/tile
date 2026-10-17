extends SceneTree
const Rules = preload("res://src/rules.gd")
const Terrain = preload("res://src/terrain.gd")
const Marble = preload("res://src/marble.gd")
const Gesture = preload("res://src/gesture.gd")
const Locale = preload("res://src/locale.gd")
var failures: int = 0
var checks: int = 0
var world: Node3D

func check(condition: bool, message: String) -> void:
	checks+=1
	if not condition:
		failures+=1
		push_error("FAIL: "+message)
	else:
		print("PASS: ",message)

func _initialize() -> void:
	run.call_deferred()

func frames(n: int) -> void:
	for i in range(n): await physics_frame

func reset_world(hole: bool = false) -> void:
	if is_instance_valid(world):
		root.remove_child(world)
		world.queue_free()
	world=Node3D.new()
	root.add_child(world)
	var terrain = Terrain.new()
	terrain.qualifying=hole
	world.add_child(terrain)

func marble(pos: Vector3) -> RigidBody3D:
	var m = Marble.new()
	m.position=pos
	world.add_child(m)
	return m

func run() -> void:
	check(Rules.wall_points([0.0,0.10])==[3,2],"exclusive contact and handspan categories")
	check(Rules.wall_points([0.0,0.0])==[3,3],"independent wall contact")
	check(Rules.wall_points([0.20,0.18])==[2,2],"independent handspan, inclusive 20 cm")
	check(Rules.wall_points([0.19,0.50])==[2,0],"no closer bonus when one inside handspan")
	check(Rules.wall_points([0.40,0.50])==[1,0],"both far: nearer wins one")
	check(Rules.wall_points([0.60,0.50])==[0,1],"both far: other player nearer")
	check(Rules.wall_points([0.50,0.501])==[1,1],"equal-distance tie tolerance")
	check(is_equal_approx(Rules.wall_distance(Vector3(0,0,-0.875)),0.1),"wall distance subtracts marble radius")
	check(Rules.wall_points([0.003,0.201])==[3,0],"documented contact tolerance")
	var rules = Rules.new()
	rules.start("wall")
	var first: Dictionary = rules.finish_wall_shot([Vector3(0,0,-0.97),Vector3(0,0,0.8)])
	check(not first.round_complete and rules.scores==[0,0],"no scoring after only one shot")
	var result: Dictionary = rules.finish_wall_shot([Vector3(0,0,-0.50),Vector3(0,0,-0.97)])
	check(result.points==[0,2] and rules.scores==[0,2],"second shot displacement uses both FINAL positions")
	check(rules.current==1 and rules.round_number==2,"alternate round starter")
	for i in range(8): rules.finish_wall_shot([Vector3(0,0,-0.97),Vector3(0,0,-0.70)])
	check(rules.finished and rules.total_shots==10,"five rounds complete after ten shots")
	rules.start("wall")
	for i in range(10): rules.finish_wall_shot([Vector3(0,0,-0.70),Vector3(0,0,-0.70)])
	check(not rules.finished and rules.round_number==6,"tied match gets extra round")
	rules.finish_wall_shot([Vector3(0,0,-0.97),Vector3(0,0,-0.70)])
	check(not rules.finished,"extra round cannot finish before paired second shot")
	rules.finish_wall_shot([Vector3(0,0,-0.97),Vector3(0,0,-0.70)])
	check(rules.finished and rules.winner==0,"paired extra round resolves winner")
	check(not Rules.completely_outside_square(Vector3(0.33,0,0)),"touching line not collected")
	check(Rules.completely_outside_square(Vector3(0.35,0,0)),"fully outside line is collected")
	rules.start("square")
	var ids: Array[int] = [1,2]
	rules.finish_square_shot(ids,4)
	check(rules.scores==[2,0] and rules.current==1,"successful square shot still consumes turn")
	rules.finish_square_shot(ids,4)
	check(rules.scores==[2,0],"captured IDs never score twice")
	var ids2: Array[int] = [3,4,5,6]
	rules.finish_square_shot(ids2,0)
	check(rules.finished and rules.winner==0,"empty square ends match")
	check(Rules.out_of_bounds(Vector3(1.2,0,0)),"visible boundary detects exit")
	check(not Rules.out_of_bounds(Vector3(0.8,0,0.9)),"valid play area stays legal")
	var gesture = Gesture.new()
	root.add_child(gesture)
	gesture.set_anchors_preset(Control.PRESET_TOP_LEFT)
	gesture.size=Vector2(720,1200)
	gesture.enabled=true
	gesture.shooter_screen=Vector2(360,700)
	var shots: Array = []
	gesture.shot.connect(func(v: Vector2,p: float): shots.append([v,p]))
	gesture.begin(Vector2(360,700),0)
	gesture.release(Vector2(360,840))
	check(shots.size()==1 and shots[0][0].y<0 and is_equal_approx(shots[0][1],0.7),"drag backward maps to forward shot and proportional power")
	gesture.begin(Vector2(360,700),0)
	gesture.release(gesture.cancel_center())
	check(shots.size()==1,"cancel zone releases no shot")
	gesture.begin(Vector2(100,300),0)
	check(not gesture.dragging,"camera-area touch cannot fire")
	gesture.queue_free()
	for key in Locale.DATA:
		check(Locale.DATA[key].size()==4 and not Locale.DATA[key].has(""),"four-language coverage: "+key)
	await physics_scenarios()
	print("RESULT: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func physics_scenarios() -> void:
	reset_world()
	var a: RigidBody3D = marble(Vector3(0,0.06,0.6))
	await frames(60)
	check(a.position.y>0.01 and a.position.y<0.06,"visible terrain supports the physical marble")
	a.apply_central_impulse(Vector3(0,0,-0.025))
	await frames(180)
	check(a.position.z<0.25,"real impulse moves marble along uneven terrain")
	await frames(360)
	check(a.linear_velocity.length()<0.035,"dirt rolling resistance settles a shot")
	reset_world()
	a=marble(Vector3(0,0.05,0.25))
	var b: RigidBody3D = marble(Vector3(0,0.05,0.05))
	await frames(60)
	var before: Vector3 = b.position
	a.apply_central_impulse(Vector3(0,0,-0.03))
	await frames(180)
	check(b.position.distance_to(before)>0.10,"legal marble collision displaces opponent")
	reset_world()
	var soft: RigidBody3D = marble(Vector3(-0.55,0.06,0.3))
	var hard: RigidBody3D = marble(Vector3(0.55,0.06,0.3))
	await frames(60)
	soft.apply_central_impulse(Vector3(0,0,-0.015))
	hard.apply_central_impulse(Vector3(0,0,-0.015))
	await frames(300)
	var patch_difference: float=soft.position.z-hard.position.z
	print("PATCH difference_cm=",snappedf(patch_difference*100,0.01))
	check(patch_difference>0.003 and patch_difference<0.06,"soft ground has a mild, bounded effect on stopping distance")
	reset_world()
	a=marble(Vector3(0.2,0.06,0.5))
	await frames(60)
	var start_x: float = a.position.x
	a.apply_central_impulse(Vector3(0,0,-0.018))
	await frames(240)
	check(absf(a.position.x-start_x)<0.02,"gentle cross-slope preserves aiming within two centimetres")
	reset_world()
	var wall := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size=Vector3(2,0.4,0.1)
	shape.shape=box
	wall.add_child(shape)
	wall.position=Vector3(0,0.15,-0.65)
	var pm := PhysicsMaterial.new()
	pm.bounce=0.7
	wall.physics_material_override=pm
	world.add_child(wall)
	a=marble(Vector3(0,0.06,-0.2))
	await frames(60)
	a.apply_central_impulse(Vector3(0,0,-0.04))
	var rebound: bool = false
	for i in range(180):
		await physics_frame
		if a.linear_velocity.z>0.15: rebound=true
	check(rebound,"wall contact physically rebounds a marble")
	var restore: Vector3 = Vector3(0.1,0.04,0.3)
	a.teleport(restore)
	await frames(2)
	check(a.position.distance_to(restore)<0.025 and a.linear_velocity.length()<0.20,"recovery restores valid pre-shot position")
	reset_world(true)
	a=marble(Vector3(0,0.05,-0.5))
	await frames(180)
	check(a.position.y<0.01,"qualifying hole has a real physical bottom")
	reset_world()

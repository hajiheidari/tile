extends Node3D
## Original procedural art blockout. Replace with authored meshes after art review.
var thumb: Node3D
var hand_root: Node3D
var landmark: Node3D
var materials: Dictionary = {}

func mat(hex: String, rough: float = 0.75) -> StandardMaterial3D:
	var key: String = hex + str(rough)
	if not materials.has(key):
		var m := StandardMaterial3D.new()
		m.albedo_color = Color(hex)
		m.roughness = rough
		materials[key] = m
	return materials[key]

func box(parent: Node3D, pos: Vector3, size: Vector3, color: String) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = size
	m.mesh = shape
	m.material_override = mat(color)
	parent.add_child(m)
	m.position = pos
	return m

func ball(parent: Node3D, pos: Vector3, size: Vector3, color: String) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var shape := SphereMesh.new()
	shape.radius = 0.5
	shape.height = 1.0
	shape.radial_segments = 24
	shape.rings = 12
	m.mesh = shape
	m.material_override = mat(color)
	parent.add_child(m)
	m.position = pos
	m.scale = size
	return m

func cylinder(parent: Node3D, pos: Vector3, radius: float, height: float, color: String, top: float = -1.0) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var shape := CylinderMesh.new()
	shape.bottom_radius = radius
	shape.top_radius = radius if top < 0 else top
	shape.height = height
	shape.radial_segments = 24
	m.mesh = shape
	m.material_override = mat(color)
	parent.add_child(m)
	m.position = pos
	return m

func segment(parent: Node3D, a: Vector3, b: Vector3, radius: float, color: String) -> MeshInstance3D:
	var m: MeshInstance3D = cylinder(parent, (a+b)*0.5, radius, a.distance_to(b), color)
	var up: Vector3 = (b-a).normalized()
	var right: Vector3 = Vector3.FORWARD.cross(up).normalized()
	if right.length_squared() < 0.01:
		right = Vector3.RIGHT
	m.basis = Basis(right, up, right.cross(up).normalized())
	ball(parent, a, Vector3.ONE * radius * 2, color)
	ball(parent, b, Vector3.ONE * radius * 2, color)
	return m

func tree(parent: Node3D, pos: Vector3, s: float = 1.0) -> void:
	cylinder(parent, pos+Vector3(0,0.35*s,0), 0.045*s, 0.7*s, "91664b")
	ball(parent, pos+Vector3(0,0.85*s,0), Vector3(0.65,0.80,0.65)*s, "6c963f")
	ball(parent, pos+Vector3(-0.18,0.70,0.06)*s, Vector3.ONE*0.48*s, "83aa4c")
	ball(parent, pos+Vector3(0.20,0.80,0.05)*s, Vector3.ONE*0.42*s, "a0b959")

func arch(parent: Node3D, x: float, z: float, w: float, h: float, color: String) -> void:
	box(parent, Vector3(x,h*0.4,z), Vector3(w,h*0.8,0.12), color)
	ball(parent, Vector3(x,h*0.79,z), Vector3(w,w,0.12), color)

func isfahan(parent: Node3D) -> void:
	box(parent, Vector3(0,0.42,-4.0), Vector3(7,0.84,0.38), "e4bc80")
	for i in range(17):
		arch(parent, -3.2+i*0.4, -3.78, 0.26, 0.56, "b0784f")
		arch(parent, -3.2+i*0.4, -3.70, 0.20, 0.49, "705c49")
	box(parent, Vector3(-0.10,0.75,-3.55), Vector3(1.0,1.5,0.20), "259caa")
	arch(parent, -0.10, -3.40, 0.65, 1.22, "174c64")
	arch(parent, -0.10, -3.32, 0.48, 1.05, "c28b5d")
	for x in [-0.66,0.46]:
		cylinder(parent, Vector3(x,1.04,-3.55), 0.065, 2.08, "e7bc7a")
		cylinder(parent, Vector3(x,1.65,-3.55), 0.07, 0.28, "299caa")
		cylinder(parent, Vector3(x,2.07,-3.55), 0.09, 0.10, "e9c584")
		ball(parent, Vector3(x,2.17,-3.55), Vector3(0.12,0.18,0.12), "249dab")
	cylinder(parent, Vector3(1.05,0.74,-4.15), 0.49, 0.68, "2aafb6")
	ball(parent, Vector3(1.05,1.21,-4.15), Vector3(1.04,0.92,1.04), "28adbb")
	cylinder(parent, Vector3(1.05,1.75,-4.15), 0.025, 0.18, "e6bc66", 0.0)
	# Repeated geometric tile details read as stylized Persian ornament.
	for i in range(13):
		var a: float = i * TAU / 13
		ball(parent, Vector3(1.05+cos(a)*0.49,1.23,-4.15+sin(a)*0.49), Vector3(0.055,0.10,0.055), "f5d086")

func build_location(index: int) -> void:
	if is_instance_valid(landmark):
		landmark.queue_free()
	landmark = Node3D.new()
	add_child(landmark)
	box(landmark, Vector3(0,-0.10,-3.1), Vector3(18,0.12,6), "e2bb83")
	match index:
		0:
			isfahan(landmark)
		1:
			# Jam: tapering brick minaret and rocky valley silhouettes.
			for i in range(5):
				cylinder(landmark, Vector3(0.2,0.30+i*0.48,-4),0.29-i*0.035,0.48,"be8959",0.25-i*0.035)
				cylinder(landmark, Vector3(0.2,0.53+i*0.48,-4),0.30-i*0.035,0.05,"dfae73")
			for x in [-3.0,-1.8,2.0,3.5]:
				ball(landmark,Vector3(x,0.6,-5),Vector3(2.0,2.8,1.8),"bb8868")
		2:
			box(landmark,Vector3(0,0.55,-4),Vector3(4,1.1,1),"f8e4bd")
			for x in [-1.8,-1.2,-0.6,0.0,0.6,1.2,1.8]:
				cylinder(landmark,Vector3(x,0.55,-3.4),0.065,1.1,"fff1d2")
			ball(landmark,Vector3(0,1.3,-4),Vector3(1.5,0.9,1.2),"29a7b6")
			box(landmark,Vector3(0,1.07,-3.35),Vector3(4.3,0.15,0.3),"d9b47c")
		3:
			box(landmark,Vector3(0,0.4,-4),Vector3(8,0.8,0.6),"bca58a")
			for i in range(25):
				box(landmark,Vector3(-3.8+i*0.32,0.92,-3.8),Vector3(0.19,0.25,0.36),"c9b496")
			for x in [-2.5,1.6]:
				box(landmark,Vector3(x,0.9,-4),Vector3(0.85,1.8,0.9),"b4a18a")
				box(landmark,Vector3(x,1.9,-4),Vector3(1.1,0.22,1.1),"6c7074")
		4:
			box(landmark,Vector3(0,-0.07,-4),Vector3(18,0.04,6),"42baca")
			var sail: MeshInstance3D = ball(landmark,Vector3(0.7,1.15,-4),Vector3(0.85,2.6,0.34),"f2f0dc")
			sail.rotation.z = -0.12
			box(landmark,Vector3(0.5,1.15,-3.80),Vector3(0.24,1.95,0.04),"4396aa")
			cylinder(landmark,Vector3(0.6,2.45,-4),0.018,0.8,"edf1da")
		5:
			for s in [-1.0,1.0]:
				segment(landmark,Vector3(s*0.72,0,-3.5),Vector3(s*0.18,1.8,-3.5),0.07,"8b6c52")
				segment(landmark,Vector3(s*0.18,1.8,-3.5),Vector3(0,2.85,-3.5),0.04,"8b6c52")
				for i in range(6):
					segment(landmark,Vector3(s*(0.65-i*0.075),0.16+i*0.23,-3.5),Vector3(-s*(0.57-i*0.075),0.39+i*0.23,-3.5),0.014,"9d7c5b")
			box(landmark,Vector3(0,0.8,-3.5),Vector3(1.0,0.12,0.36),"a68b69")
			box(landmark,Vector3(0,1.8,-3.5),Vector3(0.55,0.10,0.30),"a68b69")
		6:
			box(landmark,Vector3(0,0.45,-4),Vector3(2.6,0.9,0.8),"fff1d5")
			arch(landmark,0,-3.55,0.48,0.78,"bba58f")
			ball(landmark,Vector3(0,1.13,-4),Vector3(0.9,0.95,0.9),"fff3da")
			cylinder(landmark,Vector3(0,1.7,-4),0.02,0.26,"d7b669",0)
			for x in [-1.65,1.65]:
				cylinder(landmark,Vector3(x,0.72,-3.7),0.075,1.44,"fff1d7",0.055)
				ball(landmark,Vector3(x,1.48,-3.7),Vector3(0.20,0.18,0.20),"f4e0bd")
	for x in [-2.3,-1.6,1.9,2.7]:
		tree(landmark,Vector3(x,0,-2.4),0.7)
	landmark.scale=Vector3.ONE*0.72
	landmark.position.z=-0.7
	# Decorative pebbles stay outside the playable rectangle.
	var rng := RandomNumberGenerator.new()
	rng.seed = 12017
	for i in range(60):
		var p := Vector3(rng.randf_range(-3,3),0,rng.randf_range(-2.5,1.3))
		if absf(p.x) > 1.23 or p.z < -1.5:
			ball(landmark,p,Vector3(0.05,0.025,0.04),"bf9363")

func build_hand(tone: int = 1, style: int = 0) -> void:
	if is_instance_valid(hand_root):
		hand_root.queue_free()
	hand_root = Node3D.new()
	add_child(hand_root)
	var skin: String = ["f2caa2","c88d60","8d583e"][tone]
	ball(hand_root,Vector3(0.14,0.12,0.07),Vector3(0.15,0.095,0.19),skin)
	segment(hand_root,Vector3(0.18,0.13,0.13),Vector3(0.28,0.16,0.29),0.052,"236e74" if style == 0 else "b77784")
	# Middle fingertip is the sole ground contact; other fingers remain raised.
	segment(hand_root,Vector3(0.08,0.12,0.02),Vector3(0.07,0.065,-0.015),0.015,skin)
	segment(hand_root,Vector3(0.07,0.065,-0.015),Vector3(0.065,0.015,0.005),0.014,skin)
	for i in range(3):
		var x: float = 0.11+i*0.024
		segment(hand_root,Vector3(x,0.125,0.005),Vector3(x,0.085,-0.035+i*0.012),0.012,skin)
		segment(hand_root,Vector3(x,0.085,-0.035+i*0.012),Vector3(x,0.065,0.005),0.011,skin)
	thumb = Node3D.new()
	hand_root.add_child(thumb)
	thumb.position = Vector3(0.10,0.095,0.06)
	segment(thumb,Vector3.ZERO,Vector3(-0.045,-0.005,-0.035),0.018,skin)
	segment(thumb,Vector3(-0.045,-0.005,-0.035),Vector3(-0.065,-0.015,-0.065),0.015,skin)

func shot_animation(release: Callable) -> Tween:
	var tween: Tween = create_tween()
	tween.tween_property(thumb,"rotation:x",-0.65,0.11)
	tween.tween_callback(release)
	tween.tween_property(thumb,"rotation:x",0.45,0.06)
	return tween

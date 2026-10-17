extends Node3D
## Original stylized 3D art; mesh profiles and tile patterns are source controlled.
const Geo=preload("res://src/geometry.gd")
var thumb: Node3D
var hand_root: Node3D
var landmark: Node3D
var materials: Dictionary = {}

func tile_material(repeats: Vector3 = Vector3(2,3,1)) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture=load("res://assets/tiles.svg")
	m.uv1_scale=repeats
	m.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	m.roughness=0.43
	return m

func mat(hex: String, rough: float = 0.75) -> StandardMaterial3D:
	var key: String = hex + str(rough)
	if not materials.has(key):
		var m := StandardMaterial3D.new()
		m.albedo_color = Color(hex)
		m.roughness = rough
		m.diffuse_mode=BaseMaterial3D.DIFFUSE_BURLEY
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
	# Efficient distant matte painting; all near-field play, trees and pool remain 3D.
	var backdrop:=QuadMesh.new()
	backdrop.size=Vector2(7.70,2.5667)
	var material:=StandardMaterial3D.new()
	material.albedo_texture=load("res://assets/isfahan-landmark.png")
	material.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.alpha_scissor_threshold=0.85
	material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	material.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var painting: MeshInstance3D=Geo.instance(parent,backdrop,material,Vector3(0,1.28335,-6.70))
	painting.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	box(parent,Vector3(0,0.38,-6.76),Vector3(7.7,0.76,0.02),"534638")
	# A modeled terrace and reflecting pool join the playable dirt patch to the view.
	box(parent,Vector3(0,-0.03,-3.3),Vector3(7.6,0.12,1.4),"bda27b")
	var water: MeshInstance3D=box(parent,Vector3(0,0.035,-3.3),Vector3(4.4,0.025,0.80),"287b86")
	var water_material:=StandardMaterial3D.new()
	water_material.albedo_color=Color("427e84")
	water_material.roughness=0.12
	water_material.metallic=0.18
	water.material_override=water_material
	for z in [-3.75,-2.85]:
		box(parent,Vector3(0,0.06,z),Vector3(4.8,0.10,0.12),"cfb792")
	for x in [-2.35,2.35]:
		box(parent,Vector3(x,0.06,-3.3),Vector3(0.12,0.10,1.0),"cfb792")
	for i in range(20):
		box(parent,Vector3(-4.7+i*0.5,0.025,-2.45),Vector3(0.48,0.06,0.55),"cdb08b" if i%2==0 else "c4a782")

func isfahan_mesh(parent: Node3D) -> void:
	# A real colonnade of pointed arch openings, with recessed shadowed interiors.
	box(parent,Vector3(0,0.52,-5.10),Vector3(10.8,1.04,0.28),"bf9366")
	box(parent,Vector3(0,1.05,-4.94),Vector3(11.0,0.13,0.55),"d8b388")
	box(parent,Vector3(0,0.10,-4.60),Vector3(11.3,0.20,0.9),"c5a27a")
	var arcade_mesh: ArrayMesh = Geo.arch_mesh(0.38,0.78,0.085,0.30)
	for i in range(21):
		var x: float = -5.0+i*0.5
		box(parent,Vector3(x,0.37,-4.90),Vector3(0.40,0.74,0.05),"665341")
		Geo.instance(parent,arcade_mesh,mat("deb383"),Vector3(x,0.20,-4.51))
		box(parent,Vector3(x,0.97,-4.47),Vector3(0.42,0.045,0.04),"e3c99c")
	# Tall tiled iwan: nested pointed arch trim and deep dark opening.
	box(parent,Vector3(-0.40,0.88,-4.65),Vector3(1.28,1.76,0.32),"245e70").material_override=tile_material(Vector3(12,16,1))
	Geo.instance(parent,Geo.arch_mesh(0.82,1.48,0.15,0.29),mat("d4b16c"),Vector3(-0.40,0.15,-4.40))
	Geo.instance(parent,Geo.arch_mesh(0.72,1.38,0.06,0.22),tile_material(Vector3(4,6,1)),Vector3(-0.40,0.15,-4.34))
	box(parent,Vector3(-0.40,0.69,-4.54),Vector3(0.70,1.04,0.02),"173c4a")
	box(parent,Vector3(-0.40,1.77,-4.44),Vector3(1.36,0.08,0.41),"e0bb78")
	var tower_profile: Array[Vector2] = [Vector2(0.07,0),Vector2(0.07,0.2),Vector2(0.059,0.8),Vector2(0.052,1.55),Vector2(0.083,1.58),Vector2(0.083,1.65),Vector2(0.049,1.68),Vector2(0.049,1.91),Vector2(0.07,1.93),Vector2(0.07,1.98),Vector2(0.04,2.01),Vector2(0.025,2.10),Vector2(0,2.15)]
	for x in [-1.12,0.32]:
		Geo.instance(parent,Geo.lathe(tower_profile,40),tile_material(Vector3(3,10,1)),Vector3(x,0.10,-4.50))
		for y in [0.25,1.20,1.70,2.05]:
			cylinder(parent,Vector3(x,y,-4.50),0.082,0.035,"e2bc70")
	# Curved dome profile, with a tiled drum and a metal finial.
	var profile: Array[Vector2] = [Vector2(0.46,0),Vector2(0.48,0.10),Vector2(0.54,0.19),Vector2(0.58,0.32),Vector2(0.58,0.43),Vector2(0.54,0.56),Vector2(0.46,0.70),Vector2(0.34,0.83),Vector2(0.18,0.95),Vector2(0.055,1.03),Vector2(0,1.07)]
	box(parent,Vector3(1.10,0.50,-5.12),Vector3(1.50,1.0,1.1),"d8b284")
	cylinder(parent,Vector3(1.10,0.98,-5.12),0.47,0.32,"32a3ac").material_override=tile_material(Vector3(7,2,1))
	Geo.instance(parent,Geo.lathe(profile),tile_material(Vector3(5,3,1)),Vector3(1.10,1.08,-5.12))
	cylinder(parent,Vector3(1.10,2.22,-5.12),0.015,0.24,"c4a356",0.0)
	ball(parent,Vector3(1.10,2.34,-5.12),Vector3.ONE*0.045,"e6c881")
	# Foreground of the landmark: framed pool, paving and plantings.
	box(parent,Vector3(0,-0.03,-3.3),Vector3(7.6,0.12,1.4),"bda27b")
	box(parent,Vector3(0,0.035,-3.3),Vector3(4.4,0.025,0.80),"287b86")
	for z in [-3.75,-2.85]:
		box(parent,Vector3(0,0.06,z),Vector3(4.8,0.10,0.12),"cfb792")
	for x in [-2.35,2.35]:
		box(parent,Vector3(x,0.06,-3.3),Vector3(0.12,0.10,1.0),"cfb792")
	for i in range(20):
		box(parent,Vector3(-4.7+i*0.5,0.025,-2.45),Vector3(0.48,0.06,0.55),"cdb08b" if i%2==0 else "c4a782")

func build_location(index: int) -> void:
	if is_instance_valid(landmark):
		landmark.queue_free()
	landmark = Node3D.new()
	add_child(landmark)
	var earth := PlaneMesh.new()
	earth.size=Vector2(30,30)
	var earth_material := ShaderMaterial.new()
	earth_material.shader=load("res://assets/shaders/earth.gdshader")
	earth_material.set_shader_parameter("soil_tex",load("res://assets/packed-dirt.png"))
	earth_material.set_shader_parameter("background_ground",true)
	Geo.instance(landmark,earth,earth_material,Vector3(0,-0.012,0))
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
	for x in [-2.4,-1.9,2.7,3.6]:
		tree(landmark,Vector3(x,0,-3.8),0.85 if absf(x)<3 else 1.15)
	landmark.scale=Vector3.ONE*0.70
	landmark.position.z=-0.7
	# Decorative pebbles stay outside the playable rectangle.
	var rng := RandomNumberGenerator.new()
	rng.seed = 12017
	for i in range(60):
		var p := Vector3(rng.randf_range(-5,5),0,rng.randf_range(-2.5,3))
		var wp: Vector3=p*0.70+Vector3(0,0,-0.7)
		if absf(wp.x) > 1.23 or wp.z < -1.5 or wp.z>1.5:
			ball(landmark,p,Vector3(0.05,0.025,0.04),"bf9363")
	grass_border(landmark)

func grass_border(parent: Node3D) -> void:
	var st:=SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rng:=RandomNumberGenerator.new()
	rng.seed=719
	for side in [-1,1]:
		for i in range(18):
			var world:=Vector3(side*rng.randf_range(1.25,1.40),0,rng.randf_range(-1.3,1.5))
			var center: Vector3=(world-Vector3(0,0,-0.7))/0.70
			for blade in range(5):
				var a: float=rng.randf()*TAU
				var right:=Vector3(cos(a),0,sin(a))*0.010
				var tip:=center+Vector3(rng.randf_range(-0.04,0.04),rng.randf_range(0.08,0.17),rng.randf_range(-0.04,0.04))
				for p in [center-right,center+right,tip]:
					st.set_normal(Vector3.UP)
					st.set_color(Color("a3a452") if p==tip else Color("5c783c"))
					st.add_vertex(p)
	var material:=StandardMaterial3D.new()
	material.vertex_color_use_as_albedo=true
	material.vertex_color_is_srgb=true
	material.cull_mode=BaseMaterial3D.CULL_DISABLED
	material.roughness=0.9
	Geo.instance(parent,st.commit(),material)

func build_hand(tone: int = 1, style: int = 0) -> void:
	if is_instance_valid(hand_root):
		hand_root.queue_free()
	hand_root = Node3D.new()
	add_child(hand_root)
	var skin: String = ["f2caa2","c88d60","8d583e"][tone]
	var skin_mat: StandardMaterial3D = mat(skin,0.57)
	var palm: Array[Vector3] = [Vector3(0.135,0.080,0.17),Vector3(0.125,0.082,0.13),Vector3(0.111,0.087,0.085),Vector3(0.098,0.082,0.045),Vector3(0.092,0.076,0.026)]
	var palm_radii: Array[Vector2] = [Vector2(0.023,0.020),Vector2(0.033,0.025),Vector2(0.047,0.029),Vector2(0.046,0.027),Vector2(0.020,0.015)]
	Geo.instance(hand_root,Geo.tube(palm,palm_radii,24),skin_mat)
	var wrist: Array[Vector3] = [Vector3(0.136,0.080,0.151),Vector3(0.145,0.083,0.18),Vector3(0.167,0.090,0.235),Vector3(0.185,0.097,0.27),Vector3(0.29,0.12,0.47),Vector3(0.90,0.16,1.15)]
	var wrist_radii: Array[Vector2] = [Vector2(0.026,0.023),Vector2(0.028,0.024),Vector2(0.032,0.026),Vector2(0.033,0.026),Vector2(0.042,0.033),Vector2(0.048,0.040)]
	Geo.instance(hand_root,Geo.tube(wrist,wrist_radii,24),mat("266b75" if style==0 else "b67b88",0.9))
	# A bent middle finger is the ONLY support. Palm and other fingertips stay raised.
	var middle: Array[Vector3] = [Vector3(0.084,0.081,0.040),Vector3(0.071,0.068,0.010),Vector3(0.060,0.037,0.010),Vector3(0.056,0.013,0.026),Vector3(0.055,0.011,0.039)]
	var finger_radii: Array[Vector2] = [Vector2(0.013,0.014),Vector2(0.013,0.014),Vector2(0.011,0.012),Vector2(0.009,0.010),Vector2(0.001,0.001)]
	Geo.instance(hand_root,Geo.tube(middle,finger_radii),skin_mat)
	for i in range(3):
		var x: float = 0.104+i*0.020
		var finger: Array[Vector3] = [Vector3(x,0.084,0.040+i*0.006),Vector3(x+0.002,0.071,0.013+i*0.006),Vector3(x+0.004,0.050,0.020+i*0.006),Vector3(x,0.047,0.043+i*0.006)]
		var radii: Array[Vector2] = [Vector2(0.010,0.011),Vector2(0.011,0.012),Vector2(0.009,0.010),Vector2(0.001,0.001)]
		Geo.instance(hand_root,Geo.tube(finger,radii),skin_mat)
	thumb = Node3D.new()
	hand_root.add_child(thumb)
	thumb.position = Vector3(0.074,0.065,0.034)
	var thumb_points: Array[Vector3] = [Vector3(0.008,0.0,0.006),Vector3(-0.011,-0.002,-0.011),Vector3(-0.033,-0.012,-0.025),Vector3(-0.050,-0.019,-0.035),Vector3(-0.060,-0.023,-0.042)]
	var thumb_radii: Array[Vector2] = [Vector2(0.019,0.019),Vector2(0.017,0.017),Vector2(0.014,0.014),Vector2(0.012,0.012),Vector2(0.001,0.001)]
	Geo.instance(thumb,Geo.tube(thumb_points,thumb_radii,20),skin_mat)
	var nail: MeshInstance3D = ball(thumb,Vector3(-0.047,-0.011,-0.034),Vector3(0.017,0.004,0.020),["f4d7bd","d5ab88","ad7d63"][tone])
	nail.rotation.z=-0.25

func shot_animation(release: Callable) -> Tween:
	var tween: Tween = create_tween()
	tween.tween_property(thumb,"rotation:x",-0.65,0.11)
	tween.tween_callback(release)
	tween.tween_property(thumb,"rotation:x",0.45,0.06)
	return tween

extends RigidBody3D
const Rules = preload("res://src/rules.gd")
const Terrain = preload("res://src/terrain.gd")
signal impact(speed: float)
var marble_id: int = -1
var is_target: bool = false
var surface_multiplier: float = 1.0
var tint: Color = Color("14b7ce")
var last_speed: float = 0.0
var reset_position: Vector3
var pending_reset: bool = false

func _ready() -> void:
	mass = 0.02
	continuous_cd = true
	contact_monitor = true
	max_contacts_reported = 6
	linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	angular_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	linear_damp = 0.12
	angular_damp = 0.35
	var material := PhysicsMaterial.new()
	material.friction = 0.42
	material.bounce = 0.48
	physics_material_override = material
	var collider := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = Rules.RADIUS
	collider.shape = sphere
	add_child(collider)
	var mesh := SphereMesh.new()
	mesh.radius = Rules.RADIUS
	mesh.height = Rules.RADIUS * 2
	mesh.radial_segments = 32
	mesh.rings = 16
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(tint.r, tint.g, tint.b, 0.42)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.roughness = 0.09
	glass.metallic = 0.18
	glass.rim_enabled = true
	glass.rim = 0.8
	glass.clearcoat_enabled = true
	glass.clearcoat = 1.0
	visual.material_override = glass
	add_child(visual)
	# Original procedural inner swirls, not a flat opaque ball texture.
	for strand in range(3):
		var path := SurfaceTool.new()
		path.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
		for i in range(25):
			var t: float = float(i) / 24.0
			var a: float = t * TAU * 1.15 + strand * TAU / 3.0
			var radial: float = sin(t * PI) * Rules.RADIUS * 0.72
			var pos := Vector3(cos(a)*radial, (t-0.5)*Rules.RADIUS*1.65, sin(a)*radial)
			path.add_vertex(pos + Vector3(0.004, 0, 0))
			path.add_vertex(pos - Vector3(0.004, 0, 0))
		var ribbon := MeshInstance3D.new()
		ribbon.mesh = path.commit()
		var ribbon_mat := StandardMaterial3D.new()
		ribbon_mat.albedo_color = tint if strand != 1 else Color("fff2ce")
		ribbon_mat.roughness = 0.2
		ribbon_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		ribbon.material_override = ribbon_mat
		add_child(ribbon)
	body_entered.connect(func(_body: Node): impact.emit(last_speed))

func teleport(pos: Vector3) -> void:
	reset_position = pos
	pending_reset = true
	sleeping = false

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if pending_reset:
		state.transform.origin = reset_position
		state.linear_velocity = Vector3.ZERO
		state.angular_velocity = Vector3.ZERO
		pending_reset = false
	last_speed = state.linear_velocity.length()
	if state.get_contact_count() > 0:
		var pos: Vector3 = state.transform.origin
		var resistance: float = 0.34 * Terrain.softness_at(pos.x, pos.z) * surface_multiplier
		# Rolling resistance opposes velocity only; slopes and impacts use the solver.
		var flat := Vector3(state.linear_velocity.x, 0, state.linear_velocity.z)
		if flat.length() > 0.001:
			var dv: Vector3 = flat.normalized() * minf(flat.length(), resistance * state.step)
			state.linear_velocity -= dv
		state.angular_velocity *= exp(-resistance * state.step * 2.0)

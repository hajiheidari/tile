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
var contact_shadow: MeshInstance3D

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
	mesh.radial_segments = 48
	mesh.rings = 24
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	var glass := ShaderMaterial.new()
	glass.shader=load("res://assets/shaders/marble.gdshader")
	glass.set_shader_parameter("tint",tint)
	visual.material_override = glass
	add_child(visual)
	contact_shadow=MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size=Vector2.ONE*Rules.RADIUS*3.6
	contact_shadow.mesh=plane
	var shadow_material := ShaderMaterial.new()
	shadow_material.shader=load("res://assets/shaders/contact.gdshader")
	contact_shadow.material_override=shadow_material
	contact_shadow.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(contact_shadow)
	contact_shadow.top_level=true
	body_entered.connect(func(_body: Node): impact.emit(last_speed))

func _process(_dt: float) -> void:
	if is_instance_valid(contact_shadow):
		contact_shadow.global_position=Vector3(global_position.x,Terrain.height_at(global_position.x,global_position.z)+0.0008,global_position.z)
		contact_shadow.visible=global_position.y>0.012 and global_position.y<0.065

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

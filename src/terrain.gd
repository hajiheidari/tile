extends StaticBody3D
## Visible triangle mesh IS the collision surface. No invisible steering.
const EXTENT: float = 1.6
const GRID: int = 80
var surface_multiplier: float = 1.0
var visual: MeshInstance3D
var qualifying: bool = false

func height(x: float, z: float) -> float:
	var value: float = height_at(x,z)
	if qualifying:
		var distance: float = Vector2(x,z+0.5).length()
		if distance < 0.09:
			value -= 0.045 * (0.5 + 0.5*cos(PI*distance/0.09))
	return value

static func height_at(x: float, z: float) -> float:
	return 0.006 * sin(x * 4.1) * cos(z * 3.3) + 0.003 * sin(x * 10.0 + z * 5.0) + 0.004 * x

static func softness_at(x: float, z: float) -> float:
	# Versioned visible soft patch on the left and hard patch on the right.
	var soft: float = exp(-((x + 0.55) ** 2 + (z - 0.10) ** 2) / 0.065)
	var hard: float = exp(-((x - 0.55) ** 2 + (z + 0.20) ** 2) / 0.08)
	return 1.0 + 1.3 * soft - 0.30 * hard

func _ready() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for iz in range(GRID):
		for ix in range(GRID):
			var x: float = -EXTENT + ix * EXTENT * 2.0 / GRID
			var z: float = -EXTENT + iz * EXTENT * 2.0 / GRID
			var d: float = EXTENT * 2.0 / GRID
			for p in [Vector2(x,z), Vector2(x+d,z), Vector2(x,z+d), Vector2(x+d,z), Vector2(x+d,z+d), Vector2(x,z+d)]:
				var s: float = softness_at(p.x, p.y)
				var tint: Color = Color("d9a366").lerp(Color("b77f4f"), clampf((s-1.0)/1.5, 0, 1))
				tint = tint.lightened(0.025 * sin(p.x * 62 + p.y * 31))
				st.set_color(tint)
				st.add_vertex(Vector3(p.x, height(p.x, p.y), p.y))
	st.generate_normals()
	var mesh: ArrayMesh = st.commit()
	visual = MeshInstance3D.new()
	visual.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.vertex_color_is_srgb = true
	mat.roughness = 0.92
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	visual.material_override = mat
	add_child(visual)
	var collider := CollisionShape3D.new()
	collider.shape = mesh.create_trimesh_shape()
	add_child(collider)
	var material := PhysicsMaterial.new()
	material.friction = 0.5
	material.bounce = 0.08
	physics_material_override = material

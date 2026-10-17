extends StaticBody3D
## Visible triangle mesh IS the collision surface. No invisible steering.
const EXTENT: float = 1.6
const GRID: int = 80
var surface_multiplier: float = 1.0
var visual: MeshInstance3D
var qualifying: bool = false
var layout_seed: int = 0
var bumps: Array[Vector4] = []

func configure(value: int) -> void:
	layout_seed=value
	bumps.clear()
	if value==0: return
	var rng:=RandomNumberGenerator.new()
	rng.seed=value
	for i in range(18):
		bumps.append(Vector4(rng.randf_range(-1.4,1.4),rng.randf_range(-1.35,1.25),rng.randf_range(-0.004,0.004),rng.randf_range(0.10,0.26)))

func ground_height(x: float,z: float) -> float:
	var result: float=height_at(x,z)
	for b in bumps:
		result+=b.z*exp(-Vector2(x-b.x,z-b.y).length_squared()/(b.w*b.w))
	return result

func softness(x: float,z: float) -> float:
	if layout_seed==0: return softness_at(x,z)
	var result: float=1.0
	for i in range(bumps.size()):
		var b: Vector4=bumps[i]
		result+=(0.24 if i%2==0 else -0.10)*exp(-Vector2(x-b.x,z-b.y).length_squared()/(b.w*b.w*2.0))
	return clampf(result,0.80,1.40)

func height(x: float, z: float) -> float:
	var value: float = ground_height(x,z)
	if qualifying:
		var distance: float = Vector2(x,z+0.5).length()
		if distance < 0.09:
			value -= 0.045 * (0.5 + 0.5*cos(PI*distance/0.09))
	return value

static func height_at(x: float, z: float) -> float:
	# Packed play patch, not a miniature hillside. Maximum local slope ~0.065 degrees.
	return 0.00025 * sin(x * 2.5) * cos(z * 2.0) + 0.000075 * sin(x * 6.0 + z * 3.0) + 0.000075 * x

static func softness_at(x: float, z: float) -> float:
	# Versioned visible soft patch on the left and hard patch on the right.
	var soft: float = exp(-((x + 0.55) ** 2 + (z - 0.10) ** 2) / 0.065)
	var hard: float = exp(-((x - 0.55) ** 2 + (z + 0.20) ** 2) / 0.08)
	return 1.0 + 0.12 * soft - 0.06 * hard

func _ready() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for iz in range(GRID):
		for ix in range(GRID):
			var x: float = -EXTENT + ix * EXTENT * 2.0 / GRID
			var z: float = -EXTENT + iz * EXTENT * 2.0 / GRID
			var d: float = EXTENT * 2.0 / GRID
			for p in [Vector2(x,z), Vector2(x+d,z), Vector2(x,z+d), Vector2(x+d,z), Vector2(x+d,z+d), Vector2(x,z+d)]:
				var s: float = softness(p.x, p.y)
				var tint: Color = Color("e8b976").lerp(Color("aa784f"), clampf((s-0.8)/0.6, 0, 1))
				tint = tint.lightened(0.025 * sin(p.x * 62 + p.y * 31))
				st.set_color(tint)
				st.add_vertex(Vector3(p.x, height(p.x, p.y), p.y))
	st.generate_normals()
	var mesh: ArrayMesh = st.commit()
	visual = MeshInstance3D.new()
	visual.mesh = mesh
	var mat := ShaderMaterial.new()
	mat.shader=load("res://assets/shaders/earth.gdshader")
	mat.set_shader_parameter("soil_tex",load("res://assets/packed-dirt.png"))
	mat.set_shader_parameter("use_patch_colors",true)
	visual.material_override = mat
	add_child(visual)
	var collider := CollisionShape3D.new()
	collider.shape = mesh.create_trimesh_shape()
	add_child(collider)
	var material := PhysicsMaterial.new()
	material.friction = 0.5
	material.bounce = 0.02
	physics_material_override = material

extends RefCounted
## Explicit smooth meshes, with stable normals and UVs for authored surfaces.

static func instance(parent: Node3D, mesh: Mesh, material: Material, pos: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh=mesh
	node.material_override=material
	parent.add_child(node)
	node.position=pos
	return node

static func lathe(control: Array[Vector2], slices: int = 64) -> ArrayMesh:
	var profile: Array[Vector2]=[]
	for i in range(control.size()-1):
		for j in range(5):
			var f: float=float(j)/5.0
			var a: Vector2=control[maxi(0,i-1)]
			var b: Vector2=control[i]
			var c: Vector2=control[i+1]
			var d: Vector2=control[mini(control.size()-1,i+2)]
			var p: Vector2=0.5*((2*b)+(-a+c)*f+(2*a-5*b+4*c-d)*f*f+(-a+3*b-3*c+d)*f*f*f)
			p.x=maxf(p.x,0.0001)
			profile.append(p)
	profile.append(control[-1])
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for j in range(profile.size()-1):
		for i in range(slices):
			for corner in [Vector2i(i,j),Vector2i(i+1,j),Vector2i(i,j+1),Vector2i(i+1,j),Vector2i(i+1,j+1),Vector2i(i,j+1)]:
				var a: float = TAU*float(corner.x)/slices
				var p: Vector2 = profile[corner.y]
				var before: Vector2 = profile[maxi(0,corner.y-1)]
				var after: Vector2 = profile[mini(profile.size()-1,corner.y+1)]
				var slope: Vector2 = after-before
				st.set_normal(Vector3(cos(a)*slope.y,-slope.x,sin(a)*slope.y).normalized())
				st.set_uv(Vector2(float(corner.x)/slices,float(corner.y)/(profile.size()-1)))
				st.add_vertex(Vector3(cos(a)*p.x,p.y,sin(a)*p.x))
	return st.commit()

static func arch_outline(width: float, height: float) -> Array[Vector2]:
	var points: Array[Vector2] = [Vector2(-width*0.5,0),Vector2(-width*0.5,height*0.57)]
	for i in range(1,13):
		var t: float = float(i)/12
		var a := Vector2(-width*0.5,height*0.57)
		var b := Vector2(-width*0.38,height*0.91)
		var c := Vector2(0,height)
		points.append(a*(1-t)*(1-t)+b*2*t*(1-t)+c*t*t)
	for i in range(1,13):
		var t: float = float(i)/12
		var a := Vector2(0,height)
		var b := Vector2(width*0.38,height*0.91)
		var c := Vector2(width*0.5,height*0.57)
		points.append(a*(1-t)*(1-t)+b*2*t*(1-t)+c*t*t)
	points.append(Vector2(width*0.5,0))
	return points

static func arch_mesh(width: float, height: float, trim: float, depth: float) -> ArrayMesh:
	var inner: Array[Vector2] = arch_outline(width,height)
	var outer: Array[Vector2] = arch_outline(width+trim*2,height+trim)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(inner.size()-1):
		var a := Vector3(inner[i].x,inner[i].y,0)
		var b := Vector3(inner[i+1].x,inner[i+1].y,0)
		var c := Vector3(outer[i].x,outer[i].y,0)
		var d := Vector3(outer[i+1].x,outer[i+1].y,0)
		for p in [a,c,b,c,d,b]:
			st.set_normal(Vector3.FORWARD*-1)
			st.set_uv(Vector2(p.x/width+0.5,p.y/height))
			st.add_vertex(p)
		var back := Vector3(0,0,-depth)
		for p in [a,b,a+back,b,b+back,a+back]:
			st.set_normal(Vector3(-a.x,0.2,0).normalized())
			st.set_uv(Vector2(p.x/width+0.5,p.y/height))
			st.add_vertex(p)
	return st.commit()

static func tube(points: Array[Vector3], sizes: Array[Vector2], sides: int = 16) -> ArrayMesh:
	var centers: Array[Vector3] = []
	var radii: Array[Vector2] = []
	for i in range(points.size()-1):
		for j in range(7):
			var f: float = float(j)/7.0
			var p0: Vector3 = points[maxi(0,i-1)]
			var p1: Vector3 = points[i]
			var p2: Vector3 = points[i+1]
			var p3: Vector3 = points[mini(points.size()-1,i+2)]
			centers.append(0.5*((2*p1)+(-p0+p2)*f+(2*p0-5*p1+4*p2-p3)*f*f+(-p0+3*p1-3*p2+p3)*f*f*f))
			radii.append(sizes[i].lerp(sizes[i+1],f))
	centers.append(points[-1])
	radii.append(sizes[-1])
	var vertices: Array[Vector3] = []
	var normals: Array[Vector3] = []
	for i in range(centers.size()):
		var tangent: Vector3 = (centers[mini(i+1,centers.size()-1)]-centers[maxi(0,i-1)]).normalized()
		var right: Vector3 = (Vector3.RIGHT-tangent*tangent.dot(Vector3.RIGHT)).normalized()
		if right.length()<0.2: right=Vector3.FORWARD
		var up: Vector3 = tangent.cross(right).normalized()
		for j in range(sides+1):
			var a: float = TAU*float(j)/sides
			vertices.append(centers[i]+right*cos(a)*radii[i].x+up*sin(a)*radii[i].y)
			normals.append((right*cos(a)+up*sin(a)).normalized())
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(centers.size()-1):
		for j in range(sides):
			for k in [i*(sides+1)+j,(i+1)*(sides+1)+j,i*(sides+1)+j+1,i*(sides+1)+j+1,(i+1)*(sides+1)+j,(i+1)*(sides+1)+j+1]:
				st.set_normal(normals[k])
				st.set_uv(Vector2(float(k%(sides+1))/sides,float(k/(sides+1))/(centers.size()-1)))
				st.add_vertex(vertices[k])
	return st.commit()

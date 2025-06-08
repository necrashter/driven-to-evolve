@tool
class_name RoadMesh extends Node3D

@export var road: RoadPath3D
@export var polygon: PackedVector2Array
@export var material: Material
@export var u_increment: float = 0.05
@export var cyclic: bool = false

func _init(road, polygon, material, cyclic):
	self.road = road
	self.polygon = polygon
	self.material = material
	self.cyclic = cyclic

var current_offset = 0
var current_u = 0.0

# PackedVector**Arrays for mesh construction.
var verts = PackedVector3Array()
var uvs = PackedVector2Array()
var normals = PackedVector3Array()
var indices = PackedInt32Array()

func build():
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	# Calculate the step size in each direction
	var columns = len(polygon) - 1
	
	# -1 if first time, 0 otherwise
	# Top of the last row is carried over from previous build
	var rows = -1 if verts.size() == 0 else 0
	
	# Generate vertices, UVs, and normals
	while current_offset < road.road_len:
		rows += 1
		for i in range(len(polygon)):
			var vec = polygon[i]
			var vert = Vector3(vec.x, vec.y, 0)
			var t = road.curve.sample_baked_with_rotation(current_offset, true, true)
			verts.append(t * vert)
			normals.append(t.basis.y)
			var v = i / len(polygon)
			uvs.append(Vector2(current_u, v))
		current_offset += ProceduralRoad.z_step
		current_u += u_increment * ProceduralRoad.z_step
	
	if cyclic:
		current_offset = road.road_len
		current_u += u_increment * (road.road_len-current_u)
		rows += 1
		for i in range(len(polygon)):
			var vec = polygon[i]
			var vert = Vector3(vec.x, vec.y, 0)
			var t = road.curve.sample_baked_with_rotation(current_offset, true, true)
			verts.append(t * vert)
			normals.append(t.basis.y)
			var v = i / len(polygon)
			uvs.append(Vector2(current_u, v))
	
	# Generate indices
	for i in range(rows):
		for j in range(columns):
			var top_left = i * (columns + 1) + j
			var top_right = top_left + 1
			var bottom_left = (i + 1) * (columns + 1) + j
			var bottom_right = bottom_left + 1

			# Two triangles per quad
			indices.append(top_left)
			indices.append(bottom_left)
			indices.append(top_right)

			indices.append(top_right)
			indices.append(bottom_left)
			indices.append(bottom_right)

	
	# Assign arrays to surface array.
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices

	# Create mesh surface from mesh array.
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	var instance = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.create_trimesh_collision()
	
	# Retain the bottom vertices of last row
	var slice_point = verts.size() - (columns + 1)
	verts = verts.slice(slice_point)
	uvs = uvs.slice(slice_point)
	normals = normals.slice(slice_point)
	indices.clear()
	
	return instance

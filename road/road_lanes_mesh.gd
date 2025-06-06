@tool
class_name RoadLanesMesh extends Node3D

@export var road: RoadPath3D
@export var material: Material
@export var width: float = 0.5

# To prevent z-fighting
const LANE_Y: float = 0.08

# Will be set by parent
var lane_offsets = []
var current_offset = 0

# PackedVector**Arrays for mesh construction.
var verts = PackedVector3Array()
var uvs = PackedVector2Array()
var normals = PackedVector3Array()
var indices = PackedInt32Array()

func build():
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	# Calculate the step size in each direction
	var columns = 1
	var x_step = width / columns
	
	# -1 if first time, 0 otherwise
	# Top of the last row is carried over from previous build
	var rows = -1 if verts.size() == 0 else 0
	
	# Generate vertices, UVs, and normals
	while current_offset < road.road_len:
		rows += 1
		for j in range(columns + 1):
			for lane_offset in lane_offsets:
				var x = j * x_step - width * 0.5 + lane_offset
				var vert = Vector3(x, LANE_Y, 0)
				var t = road.curve.sample_baked_with_rotation(current_offset, true, true)
				verts.append(t * vert)
				normals.append(t.basis.y)
				var v = float(j) / columns
				var u = current_offset / 20.0
				uvs.append(Vector2(u, v))
		current_offset += ProceduralRoad.z_step
		
	# Generate indices
	var offsets = len(lane_offsets)
	for i in range(rows):
		for j in range(columns):
			for o in range(offsets):
				var top_left = i * (columns + 1) + j
				var top_right = top_left + 1
				var bottom_left = (i + 1) * (columns + 1) + j
				var bottom_right = bottom_left + 1

				# Two triangles per quad
				indices.append(o + offsets * top_left)
				indices.append(o + offsets * bottom_left)
				indices.append(o + offsets * top_right)

				indices.append(o + offsets * top_right)
				indices.append(o + offsets * bottom_left)
				indices.append(o + offsets * bottom_right)

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
	
	# Retain the bottom vertices of last row
	var slice_point = verts.size() - (columns + 1) * offsets
	verts = verts.slice(slice_point)
	uvs = uvs.slice(slice_point)
	normals = normals.slice(slice_point)
	indices.clear()
	
	return instance

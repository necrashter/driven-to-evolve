extends Node3D

func line(pos1: Vector3, pos2: Vector3, color = Color.WHITE_SMOKE):
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var green_debug_material := ORMMaterial3D.new()
	
	green_debug_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	green_debug_material.albedo_color = Color.GREEN
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	immediate_mesh.surface_add_vertex(pos1)
	immediate_mesh.surface_add_vertex(pos2)
	immediate_mesh.surface_end()
	mesh_instance.material_override = green_debug_material
	mesh_instance.layers = 4

	return mesh_instance

var inputs: NDArray

func _ready():
	for c in get_children():
		c.add_child(line(Vector3.ZERO, c.target_position))

func _physics_process(delta: float) -> void:
	if inputs:
		var i: int = 0
		for c: RayCast3D in get_children():
			c.get_child(0).material_override.albedo_color = Color.GREEN.lerp(Color.RED, inputs.get_float(i)*2.0)
			i += 1

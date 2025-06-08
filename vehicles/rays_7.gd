extends Node3D

func line(pos1: Vector3, pos2: Vector3, color = Color.WHITE_SMOKE):
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	immediate_mesh.surface_add_vertex(pos1)
	immediate_mesh.surface_add_vertex(pos2)
	immediate_mesh.surface_end()
	mesh_instance.material_override = Global.green_debug_material
	mesh_instance.layers = 2

	return mesh_instance

func _ready():
	for c in get_children():
		c.add_child(line(Vector3.ZERO, c.target_position))

func _physics_process(delta: float) -> void:
	for c: RayCast3D in get_children():
		c.get_child(0).material_override = Global.red_debug_material if c.is_colliding() else Global.green_debug_material

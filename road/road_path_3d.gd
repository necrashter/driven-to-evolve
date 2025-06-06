@tool
class_name RoadPath3D extends Path3D

var road_len: float = 0.0

const HORIZONTAL_ANGLE = 0.37 * PI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	curve.clear_points()
	curve.add_point(
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, 0.0, -20.0),
		Vector3(0.0, 0.0, 20.0),
	)
	curve.add_point(
		Vector3(0.0, 0.0, 40.0),
		Vector3(0.0, 0.0, -20.0),
		Vector3(0.0, 0.0, 20.0),
	)
	road_len = curve.get_baked_length()

# Extend path and return the length before extension
# Updates road_len
func extend_road():
	var last_point = curve.point_count - 1
	var last_pos = curve.get_point_position(last_point)
	var last_in = curve.get_point_in(last_point)
	var dir = (-last_in).normalized()
	
	#var new_dir = (dir + Vector3(randf_range(-1, 1), randf_range(-0.2, 0.2), randf_range(-1, 1))).normalized()
	var new_dir = dir.rotated(Vector3.UP, randf_range(-HORIZONTAL_ANGLE, HORIZONTAL_ANGLE))
	var new_pos = last_pos + randf_range(50, 100) * new_dir
	curve.add_point(
		new_pos,
		- 20.0 * new_dir,
		+ 20.0 * new_dir,
	)
	var old_len = road_len
	road_len = curve.get_baked_length()
	return old_len

func cut_first():
	curve.remove_point(0)
	var old_len = road_len
	road_len = curve.get_baked_length()
	return old_len - road_len

extends Node3D

const ARCH_NODE = preload("res://road/arch.tscn")

var path3d
var road_len: float
var built := false

const NEW_ANGLE = 0.25 * PI

# Called when the node enters the scene tree for the first time.
func _ready():
	if not built:
		build()

func build():
	var start_time = Time.get_ticks_msec()

	path3d = $Path3D
	road_len = path3d.curve.get_baked_length()
	for i in range(1):
		extend_road()
	for child in get_children():
		if child.has_method("_update_shape"):
			child._update_shape()

	var end_time = Time.get_ticks_msec()
	var elapsed_time = end_time - start_time
	print("Time taken to build: %d milliseconds" % elapsed_time)
	built=true

func extend_road():
	# Time to add new point
	var last_point = path3d.curve.point_count - 1
	var last_pos = path3d.curve.get_point_position(last_point)
	var last_in = path3d.curve.get_point_in(last_point)
	var dir = (-last_in).normalized()
	
	var new_dir = (dir + Vector3(randf_range(-1, 1), randf_range(-0.2, 0.2), randf_range(-1, 1))).normalized()
	new_dir.y = clamp(new_dir.y, -0.2, 0.2)
	#var new_dir = dir.rotated(Vector3.UP, randf_range(-NEW_ANGLE, NEW_ANGLE))
	var new_pos = last_pos + randf_range(40, 80) * new_dir
	path3d.curve.add_point(
		new_pos,
		- 20.0 * new_dir,
		+ 20.0 * new_dir,
	)
	#path3d.curve.remove_point(0)
	var old_len = road_len
	road_len = path3d.curve.get_baked_length()
	#if randi_range(0, 1) == 0:
		#random_item(old_len)


func random_item(old_len):
	var hand = ARCH_NODE.instantiate()
	hand.transform = path3d.curve.sample_baked_with_rotation(randf_range(old_len, road_len))
	add_child(hand)

class_name RoadSegment
extends Node3D

const ARCH_NODE = preload("res://road/arch.tscn")

const PADDING: float = 2.0

var length = 0.0

func random_item(curve, road_width, old_len, road_len):
	if randf() < 0.25:
		place_arch(curve, road_width, randf_range(old_len, road_len))

func place_arch(curve, road_width, offset):
	var node = ARCH_NODE.instantiate()
	node.transform = curve.sample_baked_with_rotation(offset, true, true)
	# Scale
	node.transform.basis.x *= road_width / 19.0
	add_child(node)

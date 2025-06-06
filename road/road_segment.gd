class_name RoadSegment
extends Node3D

const ARCH_NODE = preload("res://road/arch.tscn")
const COIN_NODE = preload("res://coin/coin.tscn")

const PADDING: float = 2.0

var length = 0.0

var pitch_lookup = [
	1.0,
	9.0 / 8.0,
	6.0 / 5.0,
	4.0 / 3.0,
	3.0 / 2.0,
	8.0 / 5.0,
	9.0 / 5.0,
	2.0,
	18.0 / 8.0,
	12.0 / 5.0,
	8.0 / 3.0,
]

func random_item(curve, road_width, old_len, road_len):
	var r = (road_width / 2.0) - PADDING
	# Coin
	var count = randi_range(1, 10)
	var space = 3.0
	var start_offset = randf_range(old_len, road_len - (count - 1) * space)
	var start_x = randf_range(-r, r)
	var end_x = randf_range(-r, r)
	for i in range(count):
		var node = COIN_NODE.instantiate()
		node.transform = curve.sample_baked_with_rotation(start_offset + space * i, true, true)
		node.position += node.transform.basis.x * lerpf(start_x, end_x, float(i) / count)
		node.get_node("Sound").pitch_scale = pitch_lookup[i] * 0.5
		add_child(node)

	if randf() < 0.25:
		var node = ARCH_NODE.instantiate()
		node.transform = curve.sample_baked_with_rotation(randf_range(old_len, road_len), true, true)
		# Scale
		node.transform.basis.x *= road_width / 19.0
		add_child(node)

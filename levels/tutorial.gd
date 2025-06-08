extends "res://levels/main.gd"

func _ready() -> void:
	super._ready()
	road.segments[0].place_arch(path3d.curve, road.road_width, path3d.road_len - 5)

func reset_road() -> void:
	pass

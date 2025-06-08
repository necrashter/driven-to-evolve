extends "res://levels/main.gd"

func _ready() -> void:
	super._ready()
	road.segments[0].place_block(path3d.curve, road.road_width, 1)
	road.segments[0].place_arch(path3d.curve, road.road_width, path3d.road_len - 5)
	print("road ", path3d.road_len)
	$Monologue.prepare([
		{
			"text": "[center][b]Welcome![/b][/center]\n" +
			"This game simulates evolutoin.",
		},
		{
			"text": "Complete your first objective to continue.",
		},
		{
			"objective": objectives.get_child(0),
		},
		{
			"text": "[center][b]Well Done![/b][/center]\n" +
			"This game simulates evolutoin.",
		},
	])

func reset_road() -> void:
	pass

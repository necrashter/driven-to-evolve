extends MainNode

func _ready() -> void:
	super._ready()
	$Monologue.prepare([
		{
			"text": "[center][b]Level 2[/b][/center]\n" +
			"This time, the network will control the acceleration in addition to the steering. Moreover, the road will be randomized each time you restart.   " +
			"For quickstart, the initial population and money values are higher. Press SPACE to start.",
		},
		{
			"objective": objectives.get_child(1),
		},
		{
			"text": "[center][b]Well Done![/b][/center]\n" +
			"Press OK to continue to the next level.",
			"callback": func():
		Global.best_matrix = matrix.get(best_car_i, null, null)
		Global.best_bias = bias.get(best_car_i, null, null)
		},
		{
			"callback": func():
		Global.last_matrix = matrix
		Global.last_bias = bias
		left_panel.on_end_generation(generation)
		Global.last_top_history = left_panel.top_history
		get_tree().change_scene_to_file("res://levels/drive_level.tscn")
		}
	])
	right_panel.get_node("ScrollContainer/CenterContainer/VBoxContainer/PauseCheckBox").set_pressed.call_deferred(true)

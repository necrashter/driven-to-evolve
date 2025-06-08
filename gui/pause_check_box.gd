extends CheckBox

func _ready() -> void:
	toggled.connect(on_toggled)

func _input(event):
	if event.is_action_pressed(&"pause"):
		button_pressed = not button_pressed

# Currently godot can't toggle visibility of 3D collision shapes at runtime, this is a workaround.
# See https://github.com/godotengine/godot-proposals/issues/2072
func on_toggled(is_on: bool) -> void:
	get_tree().paused = is_on

extends CheckBox

func _ready() -> void:
	toggled.connect(on_toggled)

func _input(event):
	if event.is_action_pressed(&"pause"):
		button_pressed = not button_pressed

func on_toggled(is_on: bool) -> void:
	get_tree().paused = is_on

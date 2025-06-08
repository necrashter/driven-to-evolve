extends CheckBox

func _ready() -> void:
	toggled.connect(on_toggled)

func _input(event):
	if event.is_action_pressed(&"pause"):
		button_pressed = not button_pressed

func on_toggled(is_on: bool) -> void:
	if is_on:
		get_viewport().get_camera_3d().cull_mask |= 2
	else:
		get_viewport().get_camera_3d().cull_mask ^= 2

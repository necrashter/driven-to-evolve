extends CheckBox

func _ready() -> void:
	toggled.connect(on_toggled)

func on_toggled(is_on: bool) -> void:
	if is_on:
		get_viewport().get_camera_3d().cull_mask |= 4
	else:
		get_viewport().get_camera_3d().cull_mask ^= 4

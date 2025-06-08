extends CheckBox

func _ready() -> void:
	toggled.connect(on_toggled)

func on_toggled(is_on: bool) -> void:
	owner.get_parent().visualizer.visible = is_on

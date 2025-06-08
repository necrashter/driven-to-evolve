extends CheckBox

func _ready():
	button_pressed = Global.auto_reset
	toggled.connect(on_toggle)

func on_toggle(i):
	Global.auto_reset = i

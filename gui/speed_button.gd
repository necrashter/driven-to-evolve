extends OptionButton

func _ready():
	Engine.time_scale = 1
	item_selected.connect(on_change)

func on_change(i):
	Engine.time_scale = [1,2,4][i]

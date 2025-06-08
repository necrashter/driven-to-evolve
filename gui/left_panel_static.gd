extends Panel

var table_rows: Array = []
var top_history: Array = []

func _ready():
	top_history = Global.last_top_history
	top_history.sort_custom(func(a, b):
		return a["distance"] > b["distance"]
	)
	top_history = top_history.slice(0, 10)
	
	var container = $ScrollContainer/CenterContainer/VBoxContainer
	for i in range(len(top_history) - len(table_rows)):
		var row = preload("res://gui/table_row.tscn").instantiate()
		table_rows.append(row)
		container.add_child(row)
	for i in range(len(top_history)):
		var h = top_history[i]
		table_rows[i].setup(i+1, h['distance'], h['speed'], h['generation'])

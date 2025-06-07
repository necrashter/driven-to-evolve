extends Panel

var table_rows: Array = []
var top_history: Array = []
var current_distance: float = 0.0
var current_speed: float = 0.0

func update_stats(distance: float, duration: float):
	%DistanceLabel.text = "Distance: %.2f" % distance
	var minutes = int(duration/60)
	var seconds = duration - (minutes * 60)
	if minutes > 0:
		%TimeLabel.text = "Time: %d:%.2f" % [minutes, seconds]
	else:
		%TimeLabel.text = "Time: %.2f" % seconds
	current_distance = distance
	current_speed = distance / duration
	%SpeedLabel.text = "Speed: %.2f" % current_speed

func on_new_generation(generation):
	top_history.append({
		"distance": current_distance,
		"speed": current_speed,
		"generation": generation-1,  # Prev generation
	})
	top_history.sort_custom(func(a, b):
		return a["distance"] > b["distance"]
	)
	top_history = top_history.slice(0, 10)
	var container = $ScrollContainer/CenterContainer/VBoxContainer
	for row in table_rows:
		container.remove_child(row)
		row.queue_free()
	table_rows = []
	for i in len(top_history):
		var h = top_history[i]
		var row = preload("res://gui/table_row.tscn").instantiate()
		row.setup(i+1, h['distance'], h['speed'], h['generation'])
		table_rows.append(row)
		container.add_child(row)

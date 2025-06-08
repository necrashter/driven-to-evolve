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

func on_end_generation(generation):
	for car in get_parent().cars:
		top_history.append({
			"distance": car.distance,
			"speed": car.distance / car.duration,
			"generation": generation,
		})
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

func add_objectives(objectives: Control):
	var container = $ScrollContainer/CenterContainer/VBoxContainer
	container.add_child(objectives)
	container.move_child(objectives, 6)

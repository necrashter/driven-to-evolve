extends Panel

func update_distance(d: float):
	%DistanceLabel.text = "Distance: %.2f" % d

func update_time(duration: float):
	var minutes = int(duration/60)
	var seconds = duration - (minutes * 60)
	%TimeLabel.text = "Time: %d:%.2f" % [minutes, seconds]

extends HBoxContainer

func setup(order: int, distance: float, speed: float, generation: int):
	$Label1.text = str(order) + "."
	$Label2.text = "%.1f" % distance
	$Label3.text = "%.1f" % speed
	tooltip_text = "Ranking: %d\nDistance: %.2f\nSpeed: %.2f\nGeneration: %d" % [order, distance, speed, generation]

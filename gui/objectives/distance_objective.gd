extends ObjectiveLabel

@export var target_distance: float = 100.0

func _ready() -> void:
	text = "Reach distance: %.1f" % target_distance

func _physics_process(delta: float) -> void:
	if button_pressed:
		return
	var main = get_tree().current_scene
	for car in main.cars:
		if car.distance >= target_distance:
			complete_objective()
			break

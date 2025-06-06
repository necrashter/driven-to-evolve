extends Control

@onready var car_body: Player = get_node("../Car")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$ScoreLabel.text = "SCORE: " + str(car_body.score) + "\nCOMBO: " + str(car_body.combo)

func combo_lost():
	$AnimationPlayer.play(&"combo_lost")

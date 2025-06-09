extends Control

var _money: int = 30
var money: int:
	get:
		return _money
	set(value):
		_money = value
		%MoneyLabel.text = "Money: " + str(money)

var next_gen_requested: bool = false
var soft_reset_requested: bool = false

func _ready() -> void:
	pass
	
func on_population_update(population: int, target: int):
	%PopLabel.text = "Population: "+str(population)
	if target > population:
		%PopLabel.text += "+" + str(target - population)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"next_gen"):
		if not %NextButton.disabled:
			_on_next_button_pressed()
	if Input.is_action_just_pressed(&"soft_reset"):
		_on_next_button_2_pressed()

func _on_next_button_pressed() -> void:
	next_gen_requested = true
	%NextButton.disabled = true
	var tween = get_parent().create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(func():
		%NextButton.disabled = false
	)

func _on_next_button_2_pressed() -> void:
	soft_reset_requested = true

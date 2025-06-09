extends "res://levels/main.gd"

func _enter_tree() -> void:
	$RightPanel._money = 5
	$RightPanel.money_dist_div = 50.0

func _ready() -> void:
	super._ready()
	road.segments[0].place_block(path3d.curve, road.road_width, 1)
	road.segments[0].place_arch(path3d.curve, road.road_width, 110.0)
	$Monologue.prepare([
		{
			"text": "[center][b]Welcome![/b][/center]\n" +
			"In this game, you will manage an evolutionary process to train a single-layer neural network (i.e., no hidden layers) to drive a car.",
		},
		{
			"text": "In this level, car accelerates automatically, but steering is controlled by the neural network.\n\nPress SPACE to unpause the game and see what happens.",
		},
		{
			"text": "Since the network is not trained yet, the car doesn't turn.\n\nYou need to harness the power of evolution to overcome this obstacle.",
		},
		{
			"text": "[center][b]Control the Evolution[/b][/center]\n" +
			"On the right panel, you can control the evolution. Hover your mouse to read the description for each setting. You need to spend the in-game currency to unlock some settings.",
		},
		{
			"text": "[center][b]Failure is Progress[/b][/center]\n" +
			"Each time you restart, you will make money, even if you didn't achieve your goal. In evolution, each failure gets you closer to your goal.",
		},
		{
			"text": "[center][b]Evolution 101[/b][/center]\n" +
			"Evolution works by exploring the possibilities and keeping the traits that work. Current top-k setting ensures that only the top 25% cars propagate. However, you need to [b]increase the mutation chance and population[/b].",
		},
		{
			"text": "Complete your first objective to continue.\n\nYour objectives are listed on the left panel.",
		},
		{
			"objective": objectives.get_child(0),
		},
		{
			"text": "[center][b]Well Done![/b][/center]\n" +
			"You have taught the AI how to turn right using evolution!",
		},
		{
			"text": "[center][b]Mechanistic Interpretability[/b][/center]\n" +
			"You can investigate how it works by enabling the raycasts or the network visualization from the right panel. Reverse-engineering neural networks like this is called [i]mechanistic interpretability[/i].",
		},
		{
			"text": "Now try to reach the next objective.",
		},
		{
			"objective": objectives.get_child(1),
		},
		{
			"text": "[center][b]Well Done![/b][/center]\n" +
			"Press OK to continue to the next level.",
		},
		{
			"callback": func(): get_tree().change_scene_to_file("res://levels/level2.tscn")
		}
	])
	right_panel.get_node("ScrollContainer/CenterContainer/VBoxContainer/PauseCheckBox").set_pressed.call_deferred(true)

func reset_road() -> void:
	pass

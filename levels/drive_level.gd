extends Node3D

@export var car_scene: PackedScene = preload("res://vehicles/sports_car_7rays.tscn")

signal end_generation(generation: int)
signal new_generation(generation: int)
signal population_update(population: int, target: int)

var generation: int = 0
@export var init_std: float = 0.1
var duration: float = 0.0
var distance_offset: float = -10.0

@onready var cars_node = $Cars
@onready var right_panel = get_node_or_null("RightPanel")
@onready var left_panel = get_node_or_null("LeftPanel")
@onready var road = get_node_or_null("ProceduralRoad")
@onready var path3d = get_node_or_null("ProceduralRoad/RoadPath3D")
@onready var objectives = get_node_or_null("Objectives")
@onready var visualizer = get_node_or_null("Visualizer")
@onready var player_car = get_node_or_null("PlayerCar")

var cars: Array = []
var input_length: int = 0
var output_length: int = 0
var matrix: NDArray
var bias: NDArray

func _ready():
	reset()
	if right_panel:
		population_update.connect(right_panel.on_population_update)
		right_panel.on_population_update(len(cars), len(cars))
	Global.objective_complete.connect(on_objective_complete)
	if objectives:
		remove_child(objectives)
		left_panel.add_objectives(objectives)
	$Monologue.prepare([
		{
			"text": "[center][b]Reverse Inputs[/b][/center]\n" +
			"Now, you are on the driver's seat! Use arrow keys to drive the car. As you drive the car, " +
			"your AI model is inverted to compute the inputs that would make it give the same control output as you.",
		},
		{
			"text": "[center][b]Reverse Inputs[/b][/center]\n" +
			"Although each network varies, you should generally observe that turning right activates the sensors on the left (since the car would need to turn right if there's an obstacle on the left), and vice-versa.",
		},
		{
			"text": "[center][b]Reverse Inputs[/b][/center]\n" +
			"Another common pattern is the activation of the sensors on the front while driving in reverse. This allows the car to slow down if there's an obstacle up ahead.",
		},
		{
			"text": "[center][b]Reverse Inputs[/b][/center]\n" +
			"Play around with reverse inputs, then press OK to continue.",
		},
		{
			"text": "[center][b]Your AI joins![/b][/center]\n" +
			"Now, your AI (latest generation) from the previous level is added. Note that since its sensors are low-ranged, it drives slowly compared to the top speed of the car.",
			"callback": ai_join,
		},
		{
			"text": "[center][b]Your AI joins![/b][/center]\n" +
			"Have fun driving!",
		},
		{
			"callback": game_end,
		}
	])
	get_tree().paused = false

func _physics_process(delta: float) -> void:
	var soft_reset = false
	if right_panel and right_panel.next_gen_requested:
		right_panel.next_gen_requested = false
		next_gen()
		return
	elif right_panel and right_panel.soft_reset_requested:
		right_panel.soft_reset_requested = false
		soft_reset = true
	
	var player_offset = path3d.curve.get_closest_offset(player_car.position)
	
	var input_matrix: NDArray
	var output: NDArray
	if len(cars) > 0:
		var inputs = []
		for car in cars:
			inputs.append(car.get_ray_inputs())
		input_matrix = nd.reshape(nd.array(inputs), [len(cars), 1, input_length])
		output = nd.add(nd.matmul(input_matrix, matrix), bias)
		for i in len(cars):
			cars[i].set_inputs(output.get(i, 0, null))
	
	process_car(player_car)
	
	# Requires recalculation since the road may be cut in process_car
	player_offset = path3d.curve.get_closest_offset(player_car.position)
	
	for car in cars:
		if soft_reset or (car.position.y - path3d.curve.get_closest_point(car.position).y) < -20.0:
			car.transform = path3d.curve.sample_baked_with_rotation(player_offset, true, true)
			car.reset()
	
	$CameraBase.transform = $CameraBase.transform.interpolate_with(path3d.curve.sample_baked_with_rotation(player_offset, true, true), .125)
	
	var cam_offset = -INF
	var best_car = null
	var best_car_i: int = -1
	for i in len(cars):
		var car = cars[i]
		if car.process_mode != PROCESS_MODE_DISABLED:
			var offset = path3d.curve.get_closest_offset(car.position)
			car.distance = offset + distance_offset
			car.duration = duration
			if offset > cam_offset:
				cam_offset = offset
				best_car = car
				best_car_i = i
	if best_car:
		if visualizer and visualizer.visible:
			visualizer.matrix = matrix.get(best_car_i, null, null)
			visualizer.bias = bias.get(best_car_i, 0, null)
			visualizer.inputs = input_matrix.get(best_car_i, 0, null)
			visualizer.outputs = output.get(best_car_i, 0, null)
			visualizer.queue_redraw()
	duration += delta
	update_rev_rays()
 
func update_rev_rays():
	var output = nd.reshape(nd.array([player_car.acc_input, player_car.steer_input]), [1, 2])
	var inputs = nd.matmul(nd.subtract(output, Global.best_bias), nd.transpose(Global.best_matrix)).get(0, null)
	$RevRayCasts.inputs = inputs
	$RevRayCasts.transform = player_car.transform

func next_gen():
	end_generation.emit(generation)
	generation += 1
	reset()
	new_generation.emit(generation)
	population_update.emit(len(cars), len(cars))

func ai_join():
	matrix = Global.last_matrix
	bias = Global.last_bias
	for i in range(matrix.shape()[0]):
		add_car()
	input_length = cars[0].get_input_length()
	output_length = cars[0].get_output_length()
	var player_offset = path3d.curve.get_closest_offset(player_car.position)
	for car in cars:
		car.reset()
		car.transform = path3d.curve.sample_baked_with_rotation(player_offset, true, true)
	if visualizer:
		visualizer.output_names = cars[0].get_output_names()
	population_update.emit(len(cars), len(cars))

func reset():
	reset_road()
	for car in cars:
		reset_car(car)
	reset_car(player_car)
	duration = 0.0
	distance_offset = -10.0
	$CameraBase.transform = path3d.curve.sample_baked_with_rotation(10.0, true, true)

func reset_road() -> void:
	if road:
		remove_child(road)
		road.queue_free()
	road = preload("res://road/procedural_road.tscn").instantiate()
	path3d = road.get_node("RoadPath3D")
	add_child(road)

func add_car():
	var car = car_scene.instantiate()
	car.name = str($Cars.get_child_count())
	$Cars.add_child(car)
	cars.append(car)

func process_car(car):
	var offset = path3d.curve.get_closest_offset(car.position)
	if offset - road.segments[0].length > 50.0:
		var cut_length = road.extend()
		distance_offset += cut_length

	var closest_point = path3d.curve.get_closest_point(car.position)
	if car.position.y - closest_point.y < -20.0:
		reset_car(car)

func reset_car(car):
	car.transform = path3d.curve.sample_baked_with_rotation(10.0, true, true)
	car.reset()

func on_objective_complete(objective: ObjectiveLabel) -> void:
	var anim = preload("res://gui/text_anim.tscn").instantiate()
	anim.get_node("Sublabel").text = objective.text
	add_child(anim)

func game_end():
	var anim = preload("res://gui/text_anim.tscn").instantiate()
	anim.get_node("Label").text = "Victory!"
	anim.get_node("Sublabel").text = "Game finished!"
	add_child(anim)

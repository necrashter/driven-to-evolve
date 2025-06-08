extends Node3D

@export var car_scene: PackedScene = preload("res://vehicles/sports_car_7rays.tscn")

signal end_generation(generation: int)
signal new_generation(generation: int)
signal population_update(population: int, target: int)

var generation: int = 0
var init_std: float = 0.1
var mutation_std: float = 0.02
var topk = 0.25
var duration: float = 0.0
var distance_offset: float = -10.0

@onready var cars_node = $Cars
@onready var right_panel = get_node_or_null("RightPanel")
@onready var left_panel = get_node_or_null("LeftPanel")
@onready var road = get_node_or_null("ProceduralRoad")
@onready var path3d = get_node_or_null("ProceduralRoad/RoadPath3D")

var cars: Array = []
var pop_target: int = 1
var input_length: int = 0
var matrix: NDArray
var bias: NDArray

func _ready():
	for i in range(pop_target):
		add_car()
	input_length = cars[0].get_input_length()
	var rng = nd.default_rng()
	matrix = nd.multiply(rng.randn([len(cars), input_length, 2]), init_std)
	bias = nd.multiply(rng.randn([len(cars), 1, 2]), init_std)
	reset()
	if right_panel:
		new_generation.connect(right_panel.on_new_generation)
		population_update.connect(right_panel.on_population_update)
		right_panel.on_population_update(len(cars), pop_target)
		right_panel.pop_added.connect(on_pop_added)
		right_panel.change_mutation.connect(on_change_mutation)
		on_change_mutation(right_panel.get_mutation())
		right_panel.change_topk.connect(on_change_topk)
		on_change_topk(right_panel.get_topk())
	if left_panel:
		end_generation.connect(left_panel.on_end_generation)
	Global.objective_complete.connect(on_objective_complete)

func on_change_mutation(mutation: float):
	mutation_std = mutation

func on_change_topk(new_topk: float):
	topk = new_topk

func on_pop_added():
	pop_target += 1
	population_update.emit(len(cars), pop_target)

func _physics_process(delta: float) -> void:
	if right_panel.next_gen_requested:
		right_panel.next_gen_requested = false
		end_generation.emit(generation)
		generation += 1
		selection()
		reset()
		new_generation.emit(generation)
		population_update.emit(len(cars), pop_target)
		return
	
	var inputs = []
	for car in cars:
		inputs.append(car.get_ray_inputs())
	var input_matrix = nd.reshape(nd.array(inputs), [len(cars), 1, input_length])
	
	var output = nd.add(nd.matmul(input_matrix, matrix), bias)
	
	for i in len(cars):
		var car = cars[i]
		car.acc_input = output.get_float(i, 0, 0)
		car.steer_input = output.get_float(i, 0, 1)
	
	for car in cars:
		process_car(car)
	
	var cam_offset = -INF
	var best_car = null
	for car in cars:
		var offset = path3d.curve.get_closest_offset(car.position)
		car.distance = offset + distance_offset
		if car.process_mode != PROCESS_MODE_DISABLED:
			car.duration = duration
		if offset > cam_offset:
			cam_offset = offset
			best_car = car
	$CameraBase.transform = path3d.curve.sample_baked_with_rotation(cam_offset, true, true)
	if left_panel and best_car:
		left_panel.update_stats(best_car.distance, best_car.duration)
	duration += delta

func reset():
	reset_road()
	for car in cars:
		reset_car(car)
	duration = 0.0
	distance_offset = -10.0

func reset_road() -> void:
	if road:
		remove_child(road)
		road.queue_free()
	road = preload("res://road/procedural_road.tscn").instantiate()
	path3d = road.get_node("RoadPath3D")
	add_child(road)

func selection():
	# 1. Sort cars by offset (descending)
	var car_offsets = []
	for car in cars:
		var offset = path3d.curve.get_closest_offset(car.position)
		car_offsets.append({ "car": car, "offset": offset })
	car_offsets.sort_custom(func(a, b): return a["offset"] > b["offset"])
	
	# Determine top-k
	var top_k_int: int
	if typeof(topk) == TYPE_INT:
		top_k_int = topk
	else:
		top_k_int = roundi(topk * len(cars))
		if top_k_int < 1:
			top_k_int = 1
	if len(cars) < top_k_int:
		top_k_int = len(cars)
	
	for i in range(pop_target - len(cars)):
		add_car()
	
	var smatrix = nd.split(matrix, 1)
	var sbias = nd.split(bias, 1)
	var new_matrix = []
	var new_bias = []
	
	# 2. Update matrix and bias
	var rng = nd.default_rng()
	for i in range(pop_target):
		var source_idx = i % top_k_int
		var src_car = car_offsets[source_idx]["car"]
		var src_idx = int(src_car.name)  # since car.name == index
		new_matrix.append(smatrix[src_idx])
		new_bias.append(sbias[src_idx])
	matrix = nd.concatenate(new_matrix, 0)
	bias = nd.concatenate(new_bias, 0)
	if mutation_std > 0.0:
		matrix = nd.add(matrix, nd.multiply(rng.randn(matrix.shape()), mutation_std))
		bias = nd.add(bias, nd.multiply(rng.randn(bias.shape()), mutation_std))

func add_car():
	var car = car_scene.instantiate()
	car.name = str($Cars.get_child_count())
	$Cars.add_child(car)
	cars.append(car)

func process_car(car):
	var offset = path3d.curve.get_closest_offset(car.position)
	if offset - road.segments[0].length > 20.0:
		var cut_length = road.extend()
		distance_offset += cut_length

	var closest_point = path3d.curve.get_closest_point(car.position)
	if car.position.y - closest_point.y < -20.0:
		car.on_fell_down()

func reset_car(car):
	car.transform = path3d.curve.sample_baked_with_rotation(10.0, true, true)
	car.reset()

func on_objective_complete(objective: ObjectiveLabel) -> void:
	var anim = preload("res://gui/text_anim.tscn").instantiate()
	anim.get_node("Sublabel").text = objective.text
	add_child(anim)

extends Node3D

const CAR: PackedScene = preload("res://vehicles/car.tscn")

signal new_generation
signal population_update(population: int, target: int)

var init_std: float = 0.1
var mutation_std: float = 0.02

@onready var cars_node = $Cars
@onready var right_panel = get_node_or_null("RightPanel")
@onready var left_panel = get_node_or_null("LeftPanel")
var path3d = null
var road = null

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

func on_change_mutation(mutation: float):
	mutation_std = mutation
	
func on_pop_added():
	pop_target += 1
	population_update.emit(len(cars), pop_target)

func _physics_process(delta: float) -> void:
	if right_panel.next_gen_requested:
		right_panel.next_gen_requested = false
		selection()
		reset()
		new_generation.emit()
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
	for car in cars:
		cam_offset = max(cam_offset, path3d.curve.get_closest_offset(car.position))
	$CameraBase.transform = path3d.curve.sample_baked_with_rotation(cam_offset, true, true)
	if left_panel:
		left_panel.update_distance(cam_offset)

func reset():
	if road:
		remove_child(road)
		road.queue_free()
	road = preload("res://road/procedural_road.tscn").instantiate()
	path3d = road.get_node("RoadPath3D")
	add_child(road)
	for car in cars:
		reset_car(car)

func selection():
	# 1. Sort cars by offset (descending)
	var car_offsets = []
	for car in cars:
		var offset = path3d.curve.get_closest_offset(car.position)
		car_offsets.append({ "car": car, "offset": offset })
	car_offsets.sort_custom(func(a, b): return b["offset"] <= a["offset"])
	
	for i in range(pop_target - len(cars)):
		add_car()
	
	var smatrix = nd.split(matrix, 1)
	var sbias = nd.split(bias, 1)
	var new_matrix = []
	var new_bias = []
	
	# 2. Update matrix and bias
	var rng = nd.default_rng()
	for i in range(pop_target):
		var source_idx = 0#i % 3  # top-3 cars are at indices 0,1,2
		var src_car = car_offsets[source_idx]["car"]
		var src_idx = int(src_car.name)  # since car.name == index
		var m = nd.add(smatrix[src_idx], nd.multiply(rng.randn([1, input_length, 2]), mutation_std))
		new_matrix.append(m)
		var b = nd.add(sbias[src_idx], nd.multiply(rng.randn([1, 1, 2]), mutation_std))
		new_bias.append(b)
	matrix = nd.concatenate(new_matrix, 0)
	bias = nd.concatenate(new_bias, 0)

func add_car():
	var car = CAR.instantiate()
	car.name = str($Cars.get_child_count())
	$Cars.add_child(car)
	cars.append(car)

func process_car(car):
	var offset = path3d.curve.get_closest_offset(car.position)
	if offset - road.segments[0].length > 20.0:
		road.extend()

	#var closest_point = path3d.curve.get_closest_point(car.position)
	#if car.position.y - closest_point.y < -20.0:
		## Car fell, reset
		#reset_car(car)

func reset_car(car):
	car.transform = path3d.curve.sample_baked_with_rotation(10.0, true, true)
	car.reset()

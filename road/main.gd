extends Node3D

const CAR: PackedScene = preload("res://vehicles/mycar.tscn")

var init_std: float = 0.1
var mutation_std: float = 0.02

@onready var cars_node = $Cars
var path3d = null
var road = null

var cars: Array = []
var input_length: int = 0
var matrix: NDArray
var bias: NDArray

func _ready():
	for i in range(10):
		var car = CAR.instantiate()
		car.name = str(i)
		$Cars.add_child(car)
		cars.append(car)
	input_length = cars[0].get_input_length()
	var rng = nd.default_rng()
	matrix = nd.multiply(rng.randn([len(cars), input_length, 2]), init_std)
	bias = nd.multiply(rng.randn([len(cars), 1, 2]), init_std)
	reset()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("accelerate"):
		selection()
		reset()
		return
	var inputs = []
	for car in cars:
		inputs.append(cars[0].get_ray_inputs())
	var input_matrix = nd.reshape(nd.array(inputs), [len(cars), 1, input_length])
	
	var output = nd.add(nd.matmul(input_matrix, matrix), bias)
	
	for i in len(cars):
		var car = cars[i]
		car.acc_input = output.get_float(i, 0, 0)
		car.steer_input = output.get_float(i, 0, 1)
	
	for car in cars:
		process_car(car)
	
	var avg_offset = 0.0
	for car in cars:
		avg_offset += path3d.curve.get_closest_offset(car.position)
	avg_offset /= len(cars)
	$CameraBase.transform = path3d.curve.sample_baked_with_rotation(avg_offset, true, true)

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
	
	var smatrix = nd.split(matrix, 1)
	var sbias = nd.split(bias, 1)
	var new_matrix = []
	var new_bias = []
	
	# 2. Update matrix and bias
	var rng = nd.default_rng()
	for i in range(len(cars)):
		var source_idx = 0#i % 3  # top-3 cars are at indices 0,1,2
		var src_car = car_offsets[source_idx]["car"]
		var src_idx = int(src_car.name)  # since car.name == index
		var m = nd.add(smatrix[src_idx], nd.multiply(rng.randn([1, input_length, 2]), mutation_std))
		new_matrix.append(m)
		var b = nd.add(sbias[src_idx], nd.multiply(rng.randn([1, 1, 2]), mutation_std))
		new_bias.append(b)
	matrix = nd.concatenate(new_matrix, 0)
	bias = nd.concatenate(new_bias, 0)

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
	car.rotate(car.transform.basis.y, PI)
	car.reset()

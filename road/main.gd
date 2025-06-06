extends Node3D

@onready var car = $Car
@onready var path3d = $Road/RoadPath3D


# Called when the node enters the scene tree for the first time.
#func _ready():
	#await get_tree().create_timer(2).timeout
	#add_child(preload("res://road/threaded_builder.tscn").instantiate())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var offset = path3d.curve.get_closest_offset(car.position)
	if offset - $Road.segments[0].length > 20.0:
		$Road.extend()

	var closest_point = path3d.curve.get_closest_point(car.position)
	if car.position.y - closest_point.y < -20.0:
		# Car fell, reset
		car.transform = path3d.curve.sample_baked_with_rotation(10.0, true, true)
		car.rotate(car.transform.basis.y, PI)
		car.linear_velocity = Vector3.ZERO
		car.angular_velocity = Vector3.ZERO

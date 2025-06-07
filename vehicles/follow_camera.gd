extends Camera3D

# Higher values cause the field of view to increase more at high speeds.
const FOV_SPEED_FACTOR = 60

# Higher values cause the field of view to adapt to speed changes faster.
const FOV_SMOOTH_FACTOR = 0.2

# Don't change FOV if moving below this speed. This prevents shadows from flickering when driving slowly.
const FOV_CHANGE_MIN_SPEED = 0.05

@export var min_distance := 2.0
@export var max_distance := 4.0
@export var angle_v_adjust := 0.0
@export var height := 1.5

var initial_transform := transform

var base_fov := fov

# The field of view to smoothly interpolate to.
var desired_fov := fov

# Position on the last physics frame (used to measure speed).
var previous_position := Vector3.ZERO

func _ready():
	previous_position = global_position


func _physics_process(_delta):
	return
	var target: Vector3 = get_parent().global_transform.origin
	var pos := global_transform.origin

	var from_target := pos - target

	# Check ranges.
	if from_target.length() < min_distance:
		from_target = from_target.normalized() * min_distance
	elif from_target.length() > max_distance:
		from_target = from_target.normalized() * max_distance

	from_target.y = height

	pos = target + from_target

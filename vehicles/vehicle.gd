class_name Player
extends VehicleBody3D

const STEER_SPEED = 1.5
const STEER_LIMIT = 0.4
const BRAKE_STRENGTH = 2.0

@export var engine_force_value := 40.0

var steer_input: float = 0.0
var acc_input: float = 0.0

var previous_velocity := linear_velocity
var _steer_target := 0.0

func _physics_process(delta: float):
	var fwd_mps := (linear_velocity * transform.basis).x

	engine_force = acc_input * engine_force_value
	_steer_target = steer_input * STEER_LIMIT
	
	# Increase engine force at low speeds to make the initial acceleration faster.
	var speed := linear_velocity.length()
	if speed < 5.0 and not is_zero_approx(speed) and not is_zero_approx(engine_force):
		engine_force = sign(engine_force) * clampf(engine_force_value * 5.0 / speed, 0.0, 200.0)
	
	if (linear_velocity - previous_velocity).length() > 1.0:
		# Sudden velocity change, likely due to a collision.
		# Play an impact sound to give audible feedback.
		$ImpactSound.play()
		process_mode = Node.PROCESS_MODE_DISABLED

	steering = move_toward(steering, _steer_target, STEER_SPEED * delta)

	previous_velocity = linear_velocity

func reset():
	process_mode = Node.PROCESS_MODE_INHERIT
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	previous_velocity = Vector3.ZERO
	engine_force = 0.0
	steering = 0.0
	steer_input = 0.0
	acc_input = 0.0

func get_ray_inputs():
	var output = []
	for r: RayCast3D in $RayCasts.get_children():
		output.append(1.0 if r.is_colliding() else 0.0)
	return output

func get_input_length() -> int:
	return $RayCasts.get_child_count()

func on_fell_down():
	process_mode = Node.PROCESS_MODE_DISABLED

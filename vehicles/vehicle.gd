class_name Player
extends VehicleBody3D

const STEER_SPEED = 1.5
const STEER_LIMIT = 0.4
const BRAKE_STRENGTH = 2.0

@export var engine_force_value := 40.0

var steer_input: float = 0.0
var acc_input: float = 0.0

var previous_speed := linear_velocity.length()
var _steer_target := 0.0

signal combo_lost
var score: int = 0
var combo: int = 0

func collect_coin():
	score += 1
	combo += 1

func _physics_process(delta: float):
	var fwd_mps := (linear_velocity * transform.basis).x

	engine_force = acc_input * engine_force_value
	_steer_target = steer_input * STEER_LIMIT
	
	# Increase engine force at low speeds to make the initial acceleration faster.
	var speed := linear_velocity.length()
	if speed < 5.0 and not is_zero_approx(speed) and not is_zero_approx(engine_force):
		engine_force = sign(engine_force) * clampf(engine_force_value * 5.0 / speed, 0.0, 200.0)
	
	if abs(linear_velocity.length() - previous_speed) > 1.0:
		# Sudden velocity change, likely due to a collision. Play an impact sound to give audible feedback,
		# and vibrate for haptic feedback.
		$ImpactSound.play()
		Input.vibrate_handheld(100)
		for joypad in Input.get_connected_joypads():
			Input.start_joy_vibration(joypad, 0.0, 0.5, 0.1)
		# Break combo
		if combo > 0:
			emit_signal(&"combo_lost")
		combo = 0

	steering = move_toward(steering, _steer_target, STEER_SPEED * delta)

	previous_speed = linear_velocity.length()

func get_ray_inputs():
	var output = []
	for r: RayCast3D in $RayCasts.get_children():
		output.append(1.0 if r.is_colliding() else 0.0)
	return output

func get_input_length() -> int:
	return $RayCasts.get_child_count()
